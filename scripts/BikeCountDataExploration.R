setwd("C:/Users/godsi/Projects/git_projects/meteo_velo")

library(dplyr)
library(ggplot2)

# read in 2019 data
#df <- read.csv("./data/raw/2019_comptage-velo-donnees-compteurs.csv", sep = ";")

aa <- read.csv("./data/raw/2019_comptage-velo-donnees-compteurs.csv", sep = ";")
bb <- read.csv("./data/raw/2020_comptage-velo-donnees-compteurs.csv", sep = ";")
cc <- read.csv("./data/raw/2021_comptage-velo-donnees-compteurs.csv", sep = ";")
dd <- read.csv("./data/raw/2022_comptage-velo-donnees-compteurs.csv", sep = ";")
ee <- read.csv("./data/raw/2023_comptage-velo-donnees-compteurs.csv", sep = ";")
ff <- read.csv("./data/raw/2024_comptage-velo-donnees-compteurs.csv", sep = ";")

if(FALSE){
d_lst <- list(y2019 =aa, 
              y2020 =bb, 
              y2021 =cc, 
              y2022 =dd, 
              y2023 =ee, 
              y2024 =ff)

counter_ids <- c("100047547-104047547", "100047547-103047547", "100047546-104047546", 
                 "100047546-103047546", "100056226-104056226", "100056226-103056226", 
                 "100047551-102047551", "100047535-SC", "100047542-103047542", 
                 "100047542-104047542")

site_ids <- unique(aa$Identifiant.du.site.de.comptage[aa$Identifiant.du.compteur %in% counter_ids])

site_ids_char <- c("100047535", "100056226", "100047551", "100047542", "100047547", "100047546")

d_lst2 <- list()

for(i in seq_along(d_lst)){
  
  tmp <- d_lst[[i]]
  tmp$Identifiant.du.site.de.comptage <- paste0(tmp$Identifiant.du.site.de.comptage)
  tmp <- tmp[tmp$Identifiant.du.site.de.comptage %in% site_ids_char,]
  d_lst2[[i]] <- tmp
  
}


for (i in seq_along(d_lst2)) {
  
  tmp2 <- d_lst2[[i]] |>
    dplyr::select(Date.et.heure.de.comptage,
                  Identifiant.du.compteur,
                  Comptage.horaire) |>
    dplyr::mutate(Comptage.horaire = as.numeric(Comptage.horaire)) |>
    dplyr::group_by(Date.et.heure.de.comptage, Identifiant.du.compteur) |>
    dplyr::summarise(Comptage.horaire = sum(Comptage.horaire, na.rm = TRUE),
                     .groups = "drop")
  
  tmp3 <- tidyr::pivot_wider(
    tmp2,
    id_cols = Date.et.heure.de.comptage,
    names_from = Identifiant.du.compteur,
    values_from = Comptage.horaire
  )
  
  bubsr::corrTable(
    input_df = tmp3[-1] |> dplyr::select(where(is.numeric)),
    title = c("2019", "2020", "2021", "2022", "2023", "2024")[i],
    sig_lev = 1
  )
}

first_time <- c()
last_time <- c()

for (i in seq_along(d_lst2)) {
  
  tmp4 <- d_lst2[[i]] 
  tmp4 <- tmp4[order(tmp4$Date.et.heure.de.comptage),]
  first_time[i] <- tmp4$Date.et.heure.de.comptage[i]
  last_time[i] <- tmp4$Date.et.heure.de.comptage[length(tmp4$Date.et.heure.de.comptage)]
  
}

res_df <- data.frame(first_time = first_time, last_time = last_time)

library(dplyr)
library(stringr)
library(lubridate)
normalize_date_time <- function(df){

df2 <- df %>%
  mutate(
    date_time = Date.et.heure.de.comptage %>%
      str_replace(" ", "T") %>%                 # make space format ISO-ish
      str_replace("\\.\\d+", "") %>%            # drop .000
      str_replace(" \\+0100$", "+01:00") %>%    # +0100 -> +01:00
      str_replace("Z$", "+00:00"),
    date_time = ymd_hms(date_time, tz = "Europe/Paris"),
    date_time = floor_date(date_time, "hour")
  )

return(df2)

}

d_lst3 <- list()

for (i in seq_along(d_lst2)) {
  
  d_lst3[[i]] <- normalize_date_time(d_lst2[[i]]) 
  
}




nams_2019 <- c("Identifiant.du.compteur", "Nom.du.compteur", "Identifiant.du.site.de.comptage", 
               "Nom.du.site.de.comptage", "Comptage.horaire", "Date.et.heure.de.comptage", 
               "Date.d.installation.du.site.de.comptage", "Lien.vers.photo.du.site.de.comptage", 
               "Coordonnées.géographiques")

res_lst <- list()

for(i in seq_along(d_lst)){
  
  year <- names(d_lst)[i]
  
  nam_tmp <- names(d_lst[[i]])
  nam_tmp <- nam_tmp[nam_tmp %in% nams_2019]
  
  has_all_nams <- all(nam_tmp %in% nams_2019)
  
  has_nams <- nam_tmp %in% nams_2019
  
  
  
  nam_result <- data.frame(year = year, 
                           nams_2019 = nams_2019, 
                           has_all_nams = has_all_nams,
                           has_this_nam = has_nams)
  
  has_counters_vec <- counter_ids %in% d_lst[[i]]$Identifiant.du.compteur
  counter_result <- data.frame(year = year, counter_ids = has_counters_vec)
  
  has_site_ids <- site_ids %in% d_lst[[i]]$Identifiant.du.site.de.comptage
  site_result <- data.frame(year = year, 
                            site_ids = site_ids,
                            has_site = has_site_ids)
  
  xx <- d_lst[[i]]
  
  counters_of_sites <- unique(xx$Identifiant.du.compteur[xx$Identifiant.du.site.de.comptage %in% site_ids])
  
  coords <- unique(xx$Coordonnées.géographiques[xx$Identifiant.du.site.de.comptage %in% site_ids])
  
  tmp_site_df <- xx[xx$Identifiant.du.site.de.comptage %in% site_ids,]
  
  tbl <- table(tmp_site_df$Identifiant.du.compteur,
               tmp_site_df$Identifiant.du.site.de.comptage)
  
  site_counter_df <- as.data.frame.matrix(tbl)
  site_counter_df[site_counter_df > 0 ] <- 1
  site_counter_df <- colSums(site_counter_df)
  
  tmp_res <- list(nams = nam_result, 
                  counter= counter_result,
                  site = site_result,
                  counters_of_sites = counters_of_sites,
                  coords = coords,
                  site_counter_df = site_counter_df)
  
  
  res_lst[[i]] <- tmp_res
  
}
i = 6
res_lst[[i]]$site_counter_df
res_lst[[i]]$nams
res_lst[[i]]$counter
res_lst[[i]]$site
res_lst[[i]]$counters_of_sites
res_lst[[i]]$coords
res_lst[[i]]$site_counter_df

aa_c

}
# individual counters of interest (2 per site for each direction)
counter_ids <- c("100047547-104047547", "100047547-103047547", "100047546-104047546", 
                 "100047546-103047546", "100056226-104056226", "100056226-103056226", 
                 "100047551-102047551", "100047535-SC", "100047542-103047542", 
                 "100047542-104047542")

# subset
df1 <- df[df$Identifiant.du.compteur %in% counter_ids,]

#unique site id's
unique(df1$Identifiant.du.site.de.comptage) # six values

# table showing correspondence between counter and site ids
tbl1 <- df1 %>%
  group_by(Identifiant.du.compteur, Nom.du.compteur, Identifiant.du.site.de.comptage) %>%
  summarise(Count = sum(Comptage.horaire))

# IMPORTANT: Pont du Garigliano uses two different Identifiant.du.site.de.comptage
# FUTURE MOVE: Aggregate across the tow counters to get the total count (both directions) for each counter

# MAP THE COUNTERS--------------------------------------------------------------

library(sf)
library(maptiles)
library(ggplot2)
library(tidyterra)  

# append latitude and longitude columns
coords_split <- strsplit(trimws(df1$Coordonnées.géographiques), "\\s*,\\s*")
coords_mat   <- do.call(rbind, coords_split)

df1$latitude  <- as.numeric(coords_mat[, 1])
df1$longitude <- as.numeric(coords_mat[, 2])


pts <- st_as_sf(df1, coords = c("longitude", "latitude"), crs = 4326)
tiles <- get_tiles(pts, provider = "CartoDB.Positron", zoom = 13)

ggplot() +
  tidyterra::geom_spatraster_rgb(data = tiles) +
  geom_sf(data = pts, size = 3, color = "darkblue") +
  coord_sf(expand = FALSE) +
  ggtitle("Bike counter locations")+
  theme_void()

ggsave('counter_map.png', height = 6, width = 6)




# exploratory stuff ; messy ; was converted to UTC-8 so loosing French accents

table(df1$Identifiant.du.site.de.comptage)

df1 %>%
  group_by(Identifiant.du.site.de.comptage) %>%
  summarise(Min_Date = min(Date.et.heure.de.comptage),
            Max_Date = max(Date.et.heure.de.comptage))

df1 %>%
  group_by(Identifiant.du.site.de.comptage) %>%
  summarise(Min_Count = min(Comptage.horaire),
            Max_Count = max(Comptage.horaire))

sum(is.na(df1$Comptage.horaire))

ggplot(df1, aes(x = Date.et.heure.de.comptage), y = Comptage.horaire)

ggplot(df1,aes(x = Comptage.horaire))+
  geom_histogram(bins=30)+
  facet_grid(.~Counter_GRP)

ggplot(df1,aes(y = Comptage.horaire, x = Date.et.heure.de.comptage, colour = Counter_GRP, group = Counter_GRP))+
  geom_line()


ggplot(df1,aes(y = Comptage.horaire, x = Date.et.heure.de.comptage, colour = Counter_GRP, group = Counter_GRP))+
  geom_line()+
  facet_grid(~ Counter_GRP)

table(df1$Comptage.horaire == 0, df1$Counter_GRP)



