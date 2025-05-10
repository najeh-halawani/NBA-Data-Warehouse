-- Drop tables if they exist (in reverse order to avoid foreign key issues)
DROP TABLE IF EXISTS dim_player_performance;
DROP TABLE IF EXISTS fact_game;
DROP TABLE IF EXISTS dim_ranking;
DROP TABLE IF EXISTS dim_player_dynamic;
DROP TABLE IF EXISTS dim_player_static;
DROP TABLE IF EXISTS dim_team;
DROP TABLE IF EXISTS dim_date;
DROP TABLE IF EXISTS dim_season;

-- Create dim_season table
CREATE TABLE dim_season (
    season_id INTEGER PRIMARY KEY,
    season_year INTEGER NOT NULL
);

-- Create dim_date table
CREATE TABLE dim_date (
    date_id SERIAL PRIMARY KEY,
    date DATE NOT NULL,
    year INTEGER NOT NULL,
    month INTEGER NOT NULL,
    day INTEGER NOT NULL,
    UNIQUE (date)
);

-- Create dim_team table
CREATE TABLE dim_team (
    team_id INTEGER PRIMARY KEY,
    abbreviation VARCHAR(20),
    nickname VARCHAR(50),
    year_founded INTEGER,
    start_year INTEGER,
    end_year INTEGER,
    city VARCHAR(50),
    arena VARCHAR(100),
    arena_capacity INTEGER,
    owner VARCHAR(100),
    general_manager VARCHAR(100),
    head_coach VARCHAR(100),
    conference VARCHAR(50)
);

-- Create dim_player_static table
CREATE TABLE dim_player_static (
    player_id INTEGER PRIMARY KEY,
    player_name VARCHAR(100) NOT NULL,
    height FLOAT,
    college VARCHAR(100),
    country VARCHAR(100),
    draft_year INTEGER,
    draft_round INTEGER,
    draft_number INTEGER
);

-- Create dim_player_dynamic table
CREATE TABLE dim_player_dynamic (
    player_id INTEGER REFERENCES dim_player_static(player_id),
    team_id INTEGER REFERENCES dim_team(team_id),
    season_id INTEGER REFERENCES dim_season(season_id),
    weight FLOAT,
    PRIMARY KEY (player_id, team_id, season_id)
);

-- Create dim_ranking table
CREATE TABLE dim_ranking (
    ranking_id INTEGER PRIMARY KEY,
    team_id INTEGER REFERENCES dim_team(team_id),
    season_id INTEGER REFERENCES dim_season(season_id),
    conference VARCHAR(50),
    game_played INTEGER,
    wins INTEGER,
    lose INTEGER,
    date_id INTEGER REFERENCES dim_date(date_id)
);

-- Create fact_game table
CREATE TABLE fact_game (
    game_id INTEGER PRIMARY KEY,
    season_id INTEGER REFERENCES dim_season(season_id),
    home_team_id INTEGER REFERENCES dim_team(team_id),
    visitor_team_id INTEGER REFERENCES dim_team(team_id),
    home_points INTEGER,
    home_field_goal_percentage FLOAT,
    home_free_throw_percentage FLOAT,
    home_three_pointer_percentage FLOAT,
    home_assists INTEGER,
    home_rebounds INTEGER,
    visitor_points INTEGER,
    visitor_field_goal_percentage FLOAT,
    visitor_free_throw_percentage FLOAT,
    visitor_three_pointer_percentage FLOAT,
    visitor_assists INTEGER,
    visitor_rebounds INTEGER,
    home_team_wins BOOLEAN,
    date_id INTEGER REFERENCES dim_date(date_id)
);

-- Create dim_player_performance table
CREATE TABLE dim_player_performance (
    performance_id INTEGER PRIMARY KEY,
    game_id INTEGER REFERENCES fact_game(game_id),
    player_id INTEGER REFERENCES dim_player_static(player_id),
    team_id INTEGER REFERENCES dim_team(team_id),
    minutes_played VARCHAR(20),
    field_goals_made INTEGER,
    field_goals_attempted INTEGER,
    field_goal_percentage FLOAT,
    three_pointers_made INTEGER,
    three_pointers_attempted INTEGER,
    three_pointer_percentage FLOAT,
    free_throws_made INTEGER,
    free_throws_attempted INTEGER,
    free_throw_percentage FLOAT,
    offensive_rebounds INTEGER,
    defensive_rebounds INTEGER,
    total_rebounds INTEGER,
    assists INTEGER,
    steals INTEGER,
    blocks INTEGER,
    turnovers INTEGER,
    personal_fouls INTEGER,
    points INTEGER
);