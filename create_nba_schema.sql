DROP DATABASE IF EXISTS nba_database;
CREATE DATABASE nba_database;
USE nba_database;

DROP TABLE IF EXISTS fact_game;
DROP TABLE IF EXISTS dim_player_performance;
DROP TABLE IF EXISTS dim_ranking;
DROP TABLE IF EXISTS dim_player_dynamic;
DROP TABLE IF EXISTS dim_player_static;
DROP TABLE IF EXISTS dim_team;
DROP TABLE IF EXISTS dim_date;
DROP TABLE IF EXISTS dim_season;



CREATE TABLE dim_player_static (
    player_id PRIMARY KEY,
    player_name VARCHAR(100),
    draft_number INT,
    draft_round INT,
    draft_year INT,
    height VARCHAR(10),
    college VARCHAR(100),
    country VARCHAR(50)
);

CREATE TABLE dim_player_dynamic (
    player_id INT,
    team_id INT,
    season INT,
    weight FLOAT,
    PRIMARY KEY (player_id, team_id, season),
    FOREIGN KEY (player_id) REFERENCES dim_player_static(player_id),
    FOREIGN KEY (team_id) REFERENCES dim_team(team_id),
    FOREIGN KEY (season) REFERENCES dim_season(season_id)
);

CREATE TABLE dim_team (
    team_id SERIAL PRIMARY KEY,
    abbreviation VARCHAR(10),
    nickname VARCHAR(50),
    year_founded INT,
    start_year INT,
    end_year INT,
    city VARCHAR(50),
    arena VARCHAR(100),
    arena_capacity INT,
    conference VARCHAR(10),
    owner VARCHAR(100),
    general_manager VARCHAR(100),
    head_coach VARCHAR(50)
);

CREATE TABLE dim_date (
    date_id SERIAL PRIMARY KEY,
    year INT,
    month INT,
    day INT
);

CREATE TABLE dim_season (
    season_id SERIAL PRIMARY KEY,
    season_year INT
);


CREATE TABLE fact_game (
    game_id SERIAL PRIMARY KEY,
    date_id INT,
    season_id INT,
    home_team_id INT,
    away_team_id INT,
    season INT,
    pts_home INT,
    ast_home INT,
    reb_home INT,
    pts_away INT,
    ast_away INT,
    reb_away INT,
    oreb_home INT,
    oreb_away INT,
    dreb_home INT,
    dreb_away INT,
    block_home INT,
    block_away INT,
    assist_home INT,
    assist_away INT,
    steal_home INT,
    steal_away INT,
    turnover_home INT,
    turnover_away INT,
    personal_foul_home INT,
    personal_foul_away INT,
    FOREIGN KEY (date_id) REFERENCES dim_date(date_id),
    FOREIGN KEY (season_id) REFERENCES dim_season(season_id),
    FOREIGN KEY (home_team_id) REFERENCES dim_team(team_id),
    FOREIGN KEY (away_team_id) REFERENCES dim_team(team_id)
);
CREATE TABLE dim_player_performance (
    performance_id SERIAL PRIMARY KEY,
    game_id INT,
    player_id INT,
    min_played INT,
    field_goal_made INT,
    field_goal_attempt INT,
    free_throw_made INT,
    free_throw_attempt INT,
    field_goal_3_made INT,
    field_goal_3_attempt INT,
    assist INT,
    rebound INT,
    block INT,
    steal INT,
    personal_foul INT,
    FOREIGN KEY (game_id) REFERENCES fact_game(game_id),
    FOREIGN KEY (player_id) REFERENCES dim_player_static(player_id)
);


CREATE TABLE dim_ranking (
    ranking_id SERIAL PRIMARY KEY,
    team_id INT,
    season_id INT,
    conference varchar(10),
    game_played INT,
    wins INT,
    lose INT,
    FOREIGN KEY (team_id) REFERENCES dim_team(team_id),
    FOREIGN KEY (season_id) REFERENCES dim_season(season_id)
);
