# Meteo-Velo: Paris Bike Counts & Weather (2019–2024)

This project explores hourly bicycle count data from Paris alongside weather data to understand how temporal, contextual, and environmental factors influence cycling behavior.

The focus is on exploratory analysis, feature design, and preprocessing, with the goal of producing a clean, defensible dataset for later modeling.

The repository documents an in-progress analytical workflow, not a finished report.

Data sources

**Weather**

Open-Meteo [(historical weather API)](https://open-meteo.com/en/docs/historical-weather-api)

Hourly weather data for Paris (2019–2024)

Data are fetched via API and cached locally for reproducibility

**Bike counts**

Open Data Paris [(comptage vélo)](https://opendata.paris.fr/explore/dataset/comptage-velo-historique-donnees-compteurs/information/?utm_source=chatgpt.com)

Hourly counts from fixed counters

Analysis uses a subset of five counters selected for their proximity to recreational cycling routes

Full raw files are large and not included in the repository

## Repository structure

data/
  raw/            # Published source data (not committed)
  external/       # Cached API outputs (not committed)
  reference/      # Lookup tables (weather codes, calendars)
  extracted/      # Subsets extracted from raw data (not committed)
  processed/      # Clean, feature-ready datasets

notebooks/
  01_weather_fetch_and_preprocess.ipynb
  02_bike_data_extraction.ipynb (comming soon)
  03_bike_data_preprocessing.ipynb (rough)


## Notebooks (overview)

01_weather_fetch_and_preprocess

Fetches and caches weather data and maps weather codes to behavioral categories. Provides light-touch data sanity checks, confirming that the data are complete and the values align with the expected ranges.

02_bike_data_extraction

Extract a subset of counter site data from the large raw bike count files. Normalizes data/time variable. Concatenates across years.

03_bike_data_preprocessing (in progress)

Will clean bike count data and adds calendar- and context-based features (weekday, holidays, school calendar, grèves).

## Status

Work in progress.
Structure, features, and datasets may evolve as the analysis develops.

