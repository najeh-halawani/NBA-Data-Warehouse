-- GET the game id/ season id/ the hame and away abbreviation and points scored
SELECT f.game_id,f.season_id, home.abbreviation, f.home_points, away.abbreviation, f.visitor_points
FROM fact_game f
JOIN dim_team AS home ON f.home_team_id = home.team_id
JOIN dim_team AS away ON f.visitor_team_id = away.team_id
JOIN dim_season s ON f.season_id = s.season_id

-- home team performance per year (performance min sum of the points scored)
SELECT home.abbreviation, d.year, count(*), sum(f.home_points)
FROM fact_game f
JOIN dim_team AS home ON f.home_team_id = home.team_id
JOIN dim_date d ON f.date_id = d.date_id
group by home.abbreviation, d.year
order by d.year

-- nb of games and sum of the points scored by each player in each season
SELECT p.player_id,s.season_id,sum(pp.points) as all_pts_scored, count(*) as nb_of_game_played
FROM dim_player_performance pp
JOIN dim_player_static p ON p.player_id = pp.player_id
JOIN fact_game f ON f.game_id = pp.game_id
JOIN dim_season s ON s.season_id = f.season_id
GROUP BY p.player_id,s.season_id
order by p.player_id,s.season_id

