dedup_districts <- function(district_sf, .thresh = 0.99) {
  district_sf |> 
    arrange(STATENAME, DISTRICT, STARTCONG) |> 
    mutate(pchng = map2_dbl(geometry, lag(geometry),
                            \(g1, g2) st_area(st_intersection(g1, g2))/
                              st_area(st_union(g1, g2))),
           .by = c(STATENAME, DISTRICT)) |> 
    mutate(any_chng = any(pchng < .thresh),
           .by = c(STATENAME, STARTCONG)) |> 
    mutate(shape_num = 1) |>
    mutate(shape_num = cumsum(any_chng),
           .by = c(STATENAME, DISTRICT)) |> 
    summarize(STARTCONG = min(STARTCONG),
              ENDCONG = max(ENDCONG),
              geometry = geometry[n()],
              across(-c(STARTCONG, ENDCONG, geometry),
                     \(x) paste(sort(unique(x)), collapse = ";")),
              .by = c(STATENAME, DISTRICT, shape_num)) |> 
    mutate(DISTRICT = as.numeric(DISTRICT)) |>
    select(-shape_num, -pchng, -any_chng) |> 
    arrange(STATENAME, STARTCONG, DISTRICT) 
}