# Check car-share figures and measure distances between zone centroids.
#
# Usage (from the repository folder):
#   Rscript scripts/centroid_distances.R
#
# Needs data/TRIPSgeo_mun.gpkg and data/TRIPSgeo_freg.gpkg (see data/README.md)
# and outputs/centroids_pop.gpkg, outputs/centroids_build.gpkg (made in QGIS).
# Writes outputs/centroids_geometric.gpkg and outputs/centroid_distances.csv.

library(sf)

crs_pt <- 3763  # ETRS89 / Portugal TM06, metres

mun  <- st_transform(st_read("data/TRIPSgeo_mun.gpkg",  quiet = TRUE), crs_pt)
freg <- st_transform(st_read("data/TRIPSgeo_freg.gpkg", quiet = TRUE), crs_pt)

# 1. Car share = Car / Total * 100
mun$car_share  <- mun$Car  / mun$Total  * 100
freg$car_share <- freg$Car / freg$Total * 100
cat("Municipalities:", nrow(mun), " Parishes:", nrow(freg), "\n")
cat(sprintf("Municipal car share: %.1f-%.1f %%\n", min(mun$car_share), max(mun$car_share)))
cat(sprintf("Parish car share:    %.1f-%.1f %%\n", min(freg$car_share), max(freg$car_share)))
cat("Parishes < 45 %:", sum(freg$car_share < 45), " >= 75 %:", sum(freg$car_share >= 75), "\n")

# 2. Geometric centroids (same as QGIS Vector > Geometry Tools > Centroids)
geo <- mun[, c("name", "dtmn")]
st_agr(geo) <- "constant"
geo <- st_centroid(geo)
st_write(geo, "outputs/centroids_geometric.gpkg", layer = "centroids_geometric",
         delete_dsn = TRUE, quiet = TRUE)

# 3. Weighted centroids made in QGIS (Mean Coordinate(s), grouped by DTMN21)
pop   <- st_transform(st_read("outputs/centroids_pop.gpkg",   quiet = TRUE), crs_pt)
build <- st_transform(st_read("outputs/centroids_build.gpkg", quiet = TRUE), crs_pt)
stopifnot(nrow(pop) == 18, !anyDuplicated(pop$DTMN21),
          nrow(build) == 18, !anyDuplicated(build$DTMN21))

# put all three in the same order (by municipality code)
pop   <- pop[match(geo$dtmn, pop$DTMN21), ]
build <- build[match(geo$dtmn, build$DTMN21), ]
stopifnot(!anyNA(pop$DTMN21), !anyNA(build$DTMN21))

res <- data.frame(
  dtmn            = geo$dtmn,
  municipality    = geo$name,
  geom_to_pop_m   = round(as.numeric(st_distance(geo, pop,   by_element = TRUE))),
  geom_to_build_m = round(as.numeric(st_distance(geo, build, by_element = TRUE))),
  pop_to_build_m  = round(as.numeric(st_distance(pop, build, by_element = TRUE)))
)
res <- res[order(-res$geom_to_pop_m), ]
write.csv(res, "outputs/centroid_distances.csv", row.names = FALSE, fileEncoding = "UTF-8")
print(res, row.names = FALSE)
