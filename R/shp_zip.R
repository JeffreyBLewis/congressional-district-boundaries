read_shp_zip <- function(zipfn) {
  td <- file.path(tempdir(), "Shape")
  dir.create(td, showWarnings = FALSE)
  unlink(file.path(td, "*"), force = TRUE)
  unzip(zipfn, exdir = td, junkpaths = TRUE)
  shpfn <- list.files(td, pattern = ".shp$")
  print(file.path(td, shpfn))
  st_read(file.path(td, shpfn))
}

source_commit_info <- function() {
  sha <- Sys.getenv("GITHUB_SHA", unset = "")
  if (sha == "") {
    sha <- tryCatch(
      system2("git", c("rev-parse", "HEAD"), stdout = TRUE, stderr = FALSE),
      error = function(e) NA_character_,
      warning = function(w) NA_character_
    )
  }
  date <- tryCatch(
    system2("git", c("log", "-1", "--format=%cI", sha), stdout = TRUE, stderr = FALSE),
    error = function(e) NA_character_,
    warning = function(w) NA_character_
  )
  list(sha = sha, date = date)
}

write_version_txt <- function(dir) {
  info <- source_commit_info()
  writeLines(
    c(
      "Congressional District Boundaries",
      "https://github.com/JeffreyBLewis/congressional-district-boundaries",
      "",
      sprintf("Source GeoJSON commit: %s", info$sha),
      sprintf("Commit date:           %s", info$date),
      sprintf("Shapefile generated:   %s", format(Sys.time(), tz = "UTC", usetz = TRUE))
    ),
    file.path(dir, "VERSION.txt")
  )
}

write_shp_zip <- function(sf, zipfn, .path = "districtShapes") {
  shpfn <- str_replace(basename(zipfn), "\\.zip$", ".shp")
  td <- file.path(tempdir(), .path)
  dir.create(td, showWarnings = FALSE)
  unlink(file.path(td, "*"), force = TRUE)
  st_write(sf, file.path(td, shpfn))
  write_version_txt(td)
  print(list.files(file.path(td)))
  dir.create(dirname(zipfn), showWarnings = FALSE, recursive = TRUE)
  zip(zipfile = zipfn, files = td, flags = "-rj9X")
}

