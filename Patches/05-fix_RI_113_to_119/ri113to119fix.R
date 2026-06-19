# Cleans up issues with recent RI districts.  

library("tidyverse")
library("tidycensus")
library("tigris")
library("sf")
library("ggthemes")
library("ggspatial")

sf_use_s2(FALSE)
my_cache_dir <- file.path(tempdir(), "osm_tiles_cache")

ri119 <- congressional_districts(year = 2024, cb = TRUE, resolution = "500k") |>
  filter(STATEFP == "44")

ri118 <- congressional_districts(year = 2022, cb = TRUE, resolution = "500k") |>
  filter(STATEFP == "44")

ri116 <- congressional_districts(year = 2020, cb = TRUE, resolution = "500k") |>
  filter(STATEFP == "44")

ri115 <- congressional_districts(year = 2016, cb = TRUE, resolution = "500k") |>
  filter(STATEFP == "44")

res <- ri119 |>
  st_transform(6568) |> 
  st_buffer(-100) |> 
  mutate(a119 = st_area(geometry)) |>
  st_intersection(ri118 |>
                    st_transform(6568) |> 
                    st_buffer(-100) |> 
                    mutate(a118 = st_area(geometry))) |>
  st_intersection(ri116|>
                    st_transform(6568) |> 
                    st_buffer(-100) |> 
                    mutate(a116 = st_area(geometry))) |>
  st_intersection(ri115|>
                    st_transform(6568) |> 
                    st_buffer(-100) |> 
                    mutate(a115 = st_area(geometry))) |>
  mutate(area = st_area(geometry),
         pct = area/a119) |> 
  select(matches("^CD\\d"), starts_with("area"), pct, geometry) |> 
  rowwise() |> 
  filter(n_distinct(c_across(matches("^CD\\d"))) != 1) |>
  ungroup()  |> 
  filter(as.numeric(pct) > 1e-5)


## A very small change in the boundary was made following 2020 census
ggplot(data = res) + 
  annotation_map_tile(type = "cartolight", 
                      zoom = 12,
                      cachedir = my_cache_dir,
                      progress = "none")  +
  geom_sf(aes(col = paste(CD115FP, CD116FP, CD118FP, CD119FP),
              fill = paste(CD115FP, CD116FP, CD118FP, CD119FP))) +
  theme_map() 



ri113 <- congressional_districts(year = 2020, cb = TRUE, resolution = "500k") |>
  filter(STATEFP == "44") |>
  transmute(STATEFP = STATEFP,
            DISTRICT = CD116FP, 
            STARTCONG = 113,
            ENDCONG = 119,
            NOTE = "From `tigris` using year = 2020.",
            geometry = geometry)
unlink("Rhode%20Island_113_to_117.geojson")
st_write(ri119, "Rhode%20Island_113_to_117.geojson", append=FALSE)


ri119 <- congressional_districts(year = 2024, cb = TRUE, resolution = "500k") |>
  filter(STATEFP == "44") |>
  transmute(STATEFP = STATEFP,
            DISTRICT = CD119FP, 
            STARTCONG = 118,
            ENDCONG = 119,
            NOTE = "From `tigris` using year = 2024.",
            geometry = geometry)
unlink("Rhode%20Island_118_to_119.geojson")
st_write(ri119, "Rhode%20Island_118_to_119.geojson", append=FALSE)
