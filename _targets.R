library(targets)

# Set target options:
tar_option_set(
  #controller = crew::crew_controller_local(workers = 5, seconds_idle = 60),
  packages = c("tibble", "sf", "purrr", "stringr", "dplyr") 
)

# Run the R scripts in the R/ folder with your custom functions:
tar_source()

# Replace the target list below with your own:
list(
  tar_target(
    district_geojson_files,
    list.files("GeoJson", pattern = "\\d_to_\\d+.geojson$", full.names = TRUE)
  ),
  tar_target(
    congressional_district_sf,
    st_read(district_geojson_files[[1]]),
    pattern = map(district_geojson_files)
  ),
  tar_target(
    congresses,
    1:max(congressional_district_sf$endcong)
  ),
  tar_target(
    make_congress_by_congress_shapefiles,
    { 
      cng <- congresses[[1]]
      zfn <- sprintf("ShapeFiles/districts%03i.zip", cng)
      congressional_district_sf |> 
            filter(startcong <= cng & endcong >= cng) |> 
            arrange(statename, district) |> 
            rename_with(str_to_upper, .cols = -geometry) |> 
            arrange(STATENAME, DISTRICT) |> 
            glimpse() |> 
            write_shp_zip(zfn)
            zfn
    },
    pattern = map(congresses),
    format = "file"
  )
)
