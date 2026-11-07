# Outputs

Derived files (all in EPSG:3763, one point per municipality, 18 in total):

| File | Description |
|---|---|
| `centroids_geometric.gpkg` | Geometric centroids of the 18 municipalities (fields: `name`, `dtmn`) |
| `centroids_pop.gpkg` | Centroids weighted by resident population (Census 2021 BGRI, `N_INDIVIDUOS`), grouped by municipality code `DTMN21` (QGIS *Mean Coordinate(s)*) |
| `centroids_build.gpkg` | Centroids weighted by number of buildings (Census 2021 BGRI, `N_EDIFICIOS_CLASSICOS`), grouped by `DTMN21` (QGIS *Mean Coordinate(s)*) |
| `centroid_distances.csv` | Distances in metres between the three centroid types, per municipality |

`centroids_geometric.gpkg` and `centroid_distances.csv` are produced by [`../scripts/centroid_distances.R`](../scripts/centroid_distances.R).
