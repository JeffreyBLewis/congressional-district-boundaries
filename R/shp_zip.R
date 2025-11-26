read_shp_zip <- function(zipfn) {
  td <- file.path(tempdir(), "Shape")
  dir.create(td, showWarnings = FALSE)
  unlink(file.path(td, "*"), force = TRUE)
  unzip(zipfn, exdir = td, junkpaths = TRUE)
  shpfn <- list.files(td, pattern = ".shp$")
  print(file.path(td, shpfn))
  st_read(file.path(td, shpfn))
}

write_shp_zip <- function(sf, zipfn, .path = "districtShapes") {
  shpfn <- str_replace(basename(zipfn), "\\.zip$", ".shp")
  td <- file.path(tempdir(), .path)
  dir.create(td, showWarnings = FALSE)
  unlink(file.path(td, "*"), force = TRUE)
  st_write(sf, file.path(td, shpfn))
  print(list.files(file.path(td)))
  zip(zipfile = zipfn, files = td, flags = "-rj9X")
}

