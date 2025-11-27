parties <- read_csv("https://voteview.com/static/data/out/parties/HSall_parties.csv") |> 
  select(party_code, party_name) |> 
  distinct() |> 
  arrange(party_code)

mem <- read_csv("https://voteview.com/static/data/out/members/Hall_members.csv") |>
        left_join(parties, by = "party_code")

stateabb2statename <- state.name
names(stateabb2statename) <- state.abb

list.files("GeoJson", "geojson$", full.name = TRUE) |> 
  map(function(fn) {
    capture.output(shp <- st_read(fn))
    state <- shp$statename[1]
    startcong <- shp$startcong[1]
    endcong <- shp$endcong[1]
    cat(sprintf("Working on %s from %i to %i.\n", 
                state, startcong, endcong))
    mem |> 
      filter(congress >= startcong,
             congress <= endcong, 
             stateabb2statename[state_abbrev] == state) |> 
      select(congress, district_code, icpsr, bioname, party_name) |> 
      arrange(icpsr, congress) |>
      nest(data = c(bioname, party_name, district_code)) |> 
      as.list() |>
      rjson::toJSON() |> 
      print()
  })