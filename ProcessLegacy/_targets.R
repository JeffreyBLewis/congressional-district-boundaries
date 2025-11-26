library(targets)

SAME_DISTRICT_THRESHOLD <- 0.99

# Set target options:
tar_option_set(
  #controller = crew::crew_controller_local(workers = 5, seconds_idle = 60),
  packages = c("tibble", "sf", "tidycensus", "tigris",
               "dplyr", "purrr", "stringr")
)

tar_source("../R")

list(
  ##
  ## Load legacy shapefiles and build database of current shapes
  ##
  tar_target(
    legacy_baseline_congress,
    1:114
  ),
  tar_target(
    download_baseline,
    {
      url <- sprintf("https://cdmaps.polisci.ucla.edu/shp/districts%03i.zip",
                     legacy_baseline_congress[[1]])
      zipout <- sprintf("LegacyBaseline/districts%03i.zip", 
                     legacy_baseline_congress[[1]])
      download.file(url, zipout)
      zipout
    },
    cue = tar_cue("never"),
    pattern = map(legacy_baseline_congress),
    format = "file"
  ),
  tar_target(
    legacy_baseline_with_dups_sf,
    read_shp_zip(sprintf("LegacyBaseLine/districts%03i.zip", 
                 legacy_baseline_congress[[1]])),
    pattern = map(legacy_baseline_congress)
  ),
  tar_target(
    legacy_baseline_sf,
    legacy_baseline_with_dups_sf |> 
      distinct() |> 
      st_as_sf()
  ),
  ##
  ## Add recent Congresses to legacy shapes
  ##
  tar_target(
    state_fips_codes,
    {
      data(fips_codes)  
      fips_codes |> 
        distinct(state, state_name, state_code)
    }
  ),
  tar_target(
    congresses_115_119_sf,
    bind_rows(
      ## 115th Congress
      congressional_districts(year = 2017, cb = TRUE, resolution = "500k") |>
        transmute(STATEFP = STATEFP,
                  DISTRICT = CD115FP, 
                  STARTCONG = 115,
                  ENDCONG = 115,
                  NOTE = "From `tigris` using year = 2017.",
                  geometry = geometry),
      ## 116th Congress
      congressional_districts(year = 2019, cb = TRUE, resolution = "500k") |>
        transmute(STATEFP = STATEFP,
                  DISTRICT = CD116FP, 
                  STARTCONG = 116,
                  ENDCONG = 116,
                  NOTE = "From `tigris` using year = 2017.",
                  geometry = geometry),
      ## 117th Congress (116th + New NC districts)
      congressional_districts(year = 2019, cb = TRUE, resolution = "500k") |>
        filter(STATEFP != 37) |>
        transmute(STATEFP = STATEFP,
                  DISTRICT = CD116FP, 
                  STARTCONG = 117,
                  ENDCONG = 117,
                  NOTE = "From `tigris` using year = 2017.",
                  geometry = geometry) |> 
        bind_rows(read_shp_zip("RecentCongresses/HB1029 3rd Edition - Shapefile.zip") |> 
                    st_transform("EPSG:4269") |> 
                    transmute(STATEFP = "37",
                              DISTRICT = sprintf("%02i", as.integer(DISTRICT)),
                              STARTCONG = 117,
                              ENDCONG = 117,
                              NOTE = "From https://www.ncleg.gov/redistricting.",
                              geometry = geometry)), 
      ## 118th Congress
      congressional_districts(year = 2022, cb = TRUE, resolution = "500k") |>
        transmute(STATEFP = STATEFP,
                  DISTRICT = CD118FP, 
                  STARTCONG = 118,
                  ENDCONG = 118,
                  NOTE = "From `tigris` using year = 2022.",
                  geometry = geometry),
      ## 118th Congress
      congressional_districts(year = 2024, cb = TRUE, resolution = "500k") |>
        transmute(STATEFP = STATEFP,
                  DISTRICT = CD119FP, 
                  STARTCONG = 119,
                  ENDCONG = 119,
                  NOTE = "From `tigris` using year = 2024.",
                  geometry = geometry),
      
    ) |> 
    filter(STATEFP < 60) |>
    left_join(state_fips_codes, by = c("STATEFP" = "state_code")) |> 
    mutate(STATENAME = state_name,
           .before = 1) |> 
    select(-c(state, state_name)) |> 
    dedup_districts(SAME_DISTRICT_THRESHOLD) |> 
    mutate(LASTCHANGE =  Sys.time())
  ),
  tar_target(
    legacy_001_119_sf,
    {
      statename2fips <- state_fips_codes$state_code
      names(statename2fips) <- state_fips_codes$state_name
      bind_rows(legacy_baseline_sf |> 
                  mutate(STARTCONG = as.numeric(STARTCONG),
                         ENDCONG = as.numeric(ENDCONG),
                         DISTRICT = as.numeric(DISTRICT)),
                congresses_115_119_sf |> 
                  mutate(LASTCHANGE = as.character(LASTCHANGE))) |> 
        dedup_districts() |> 
        mutate(ID = sprintf("%03i%03i%03i%03i",
                            as.integer(statename2fips[STATENAME]), 
                            as.integer(STARTCONG), 
                            as.integer(ENDCONG), 
                            as.integer(DISTRICT)))
    }
  ),
  ##
  ## Write legacy shapes to geojson.  These shapes will be the bedrock
  ## of the collection moving forward.
  ##
  tar_target(
    write_legacy_001_119_geojson,
    {
      legacy_001_119_sf |> 
        st_make_valid() |> 
        group_split(STATENAME, STARTCONG, ENDCONG) |>
        walk(function(state_plan) {
          geojson_fn <- sprintf("../GeoJson/%s_%03i_to_%03i.geojson",
                                state_plan$STATENAME[1],
                                state_plan$STARTCONG[1],
                                state_plan$ENDCONG[1]) 
          st_write(state_plan |> 
                     rename_all(str_to_lower), 
                   geojson_fn, driver = "GeoJSON", delete_dsn = TRUE)
        })
      "ok"
    })
)
