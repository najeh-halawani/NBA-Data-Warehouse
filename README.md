# 🏀 NBA Data Warehouse Project

## 📌 Overview

This NBA Data Warehouse project integrates multiple datasets related to NBA teams, games, players, players performance, dates, and rankings into a **unified analytical environment**. The goal is to facilitate deep and flexible analysis of NBA performance metrics over time, across cities, seasons, and players.

It supports advanced OLAP querying and can be used with BI tools like Tableau for rich data visualization.



## 📦 Data Sources

Data was collected and transformed from:
- Historical NBA game logs
- Player stats (seasonal and per-game)
- Team details and season rankings

|Dataset Name | Dataset Link  |
|--|--|
| NBA Games Data <br> (Games, Game Details, Teams, Rankings, Players) | [Kaggle Link](https://www.kaggle.com/datasets/nathanlauga/nba-games?resource=download&select=games.csv) |
|NBA Players Details|[Kaggle Link](https://www.kaggle.com/datasets/justinas/nba-players-data)|



## 📐 Dimensional Fact Model (DFM)

### Assuming Fact Game
![DFM](./DFM/DFM_FG.jpg)

### Assuming Fact Player Performance
![DFM](./DFM/DFM_FPP.jpg)

### Assuming 2 Facts
![DFM](./DFM/DFM_FF.jpg)


**Fact Table:**
- `fact_game`: Central table containing game-level statistics for both teams.

**Dimensions:**
- `dim_team`: Teams, locations, coaches, arenas, etc.
- `dim_season`: Season identifiers.
- `dim_date`: Calendar information.
- `dim_ranking`: Team season performance.
- `dim_player_static`: Player identity and background.
- `dim_player_dynamic`: Player info that changes per season (e.g., weight, team).
- `dim_player_performance`: Player performance stats per game.





## 🔁 ETL Process

The ETL (Extract, Transform, Load) process consolidates multiple raw NBA datasets into a clean, unified PostgreSQL data warehouse.

### 🗃️ Extract

* Source: **CSV files** containing raw data for teams, players, games, rankings, and performance.

### 🛠️ Transform

Key transformation steps include:

* **Remove Duplicates**: Eliminate repeated records to ensure data accuracy.
* **Fill Missing Values**: Apply default values where data is incomplete or null.
* **Map Values to IDs**: Convert string fields (e.g., team names) into foreign key references using lookup tables.
* **Reference Mapping Across Sheets**: Ensure consistent linking between related tables (e.g., players to teams, games to dates).
* **Attribute Standardization**: Normalize column names and formats.
* **Surrogate Key Generation**: Create unique primary keys where necessary (e.g., for performance records).
* **Dimension Mapping**: Align entities across dimensions (e.g., player season data to both player and team).
* **Concatenate Values**: Combine multiple attributes into single dimensions when needed.

### 🛢️ Load

* Load cleaned and transformed data into a **PostgreSQL** database.



## 🔀 Hybrid Schema

The data warehouse follows a **Hybrid Star-Snowflake Schema**:
- Core star schema around `fact_game` and `dim_team`, `dim_date`, `dim_season`.
- Snowflake branches to player performance and rankings:
  - `dim_player_dynamic` and `dim_player_static` normalize player history.
  - `dim_ranking` adds a secondary analytical axis (team season performance).

## 📊 OLAP Session Queries

