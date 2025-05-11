-- get the player and the corresponding team name where he scored more than 50 points in a game
SELECT f.game_id, ps.player_name, t.abbreviation AS Team_Player, pp.points, d.date, home.abbreviation AS home_team, away.abbreviation AS away_team
FROM fact_game f 
JOIN dim_team AS home ON f.home_team_id = home.team_id
JOIN dim_team AS away ON f.visitor_team_id = away.team_id
JOIN dim_date d ON f.date_id = d.date_id
JOIN dim_player_performance pp ON  pp.game_id = f.game_id
JOIN dim_player_static ps ON ps.player_id = pp.player_id 
JOIN dim_team t ON t.team_id = pp.team_id
WHERE pp.points > 50



-- identify players with the best shooting percentages (field goals, 3P, and free throw) in a season / over all seasons.

SELECT 
    p.player_name,
	s.season_year,
    ROUND(AVG(pp.field_goal_percentage::numeric), 2) AS avg_fg_pct,
    ROUND(AVG(pp.three_pointer_percentage::numeric), 2) AS avg_3p_pct,
    ROUND(AVG(pp.free_throw_percentage::numeric), 2) AS avg_ft_pct
FROM dim_player_performance pp
JOIN dim_player_static p ON p.player_id = pp.player_id
JOIN fact_game f ON f.game_id = pp.game_id
JOIN dim_season s ON s.season_id = f.season_id
GROUP BY p.player_name,s.season_year
HAVING COUNT(pp.game_id) >= 15
ORDER BY avg_fg_pct DESC


-- returns the most efficient scorers over a season / over all seasons

SELECT 
    s.season_year,
    p.player_name,
    ROUND(AVG(pp.points), 2) AS avg_points_per_game,
    COUNT(DISTINCT pp.game_id) AS games_played
FROM dim_player_performance pp
JOIN dim_player_static p ON p.player_id = pp.player_id
JOIN fact_game f ON f.game_id = pp.game_id
JOIN dim_season s ON s.season_id = f.season_id
WHERE s.season_year = 2022
GROUP BY s.season_year, p.player_name
HAVING COUNT(DISTINCT pp.game_id) >= 10
ORDER BY avg_points_per_game DESC


-- analyze how win rates evolve per month over the seasons for each team

SELECT 
    s.season_year,
    d.month,
    t.nickname,
    COUNT(*) FILTER (WHERE (f.home_team_id = t.team_id AND f.home_team_wins) 
                     OR (f.visitor_team_id = t.team_id AND NOT f.home_team_wins)) AS wins,
    COUNT(*) FILTER (WHERE f.home_team_id = t.team_id OR f.visitor_team_id = t.team_id) AS total_games,
    ROUND(COUNT(*) FILTER (WHERE (f.home_team_id = t.team_id AND f.home_team_wins) 
                           OR (f.visitor_team_id = t.team_id AND NOT f.home_team_wins)) 
          * 100.0 / 
          COUNT(*) FILTER (WHERE f.home_team_id = t.team_id OR f.visitor_team_id = t.team_id), 2) AS win_rate_percentage
FROM fact_game f
JOIN dim_team t ON t.team_id IN (f.home_team_id, f.visitor_team_id)
JOIN dim_date d ON d.date_id = f.date_id
JOIN dim_season s ON s.season_id = f.season_id
GROUP BY s.season_year, d.month, t.nickname
ORDER BY s.season_year, d.month, win_rate_percentage DESC;



--  number of games played by each player over the seasons
SELECT ps.player_name, COUNT(DISTINCT s.season_year) AS season_years, COUNT(*) AS number_of_games 
FROM dim_player_performance pp
JOIN dim_player_static ps on ps.player_id = pp.player_id
JOIN fact_game g on g.game_id = pp.game_id
JOIN dim_season s on s.season_id = g.season_id
GROUP BY ps.player_name
ORDER BY number_of_games DESC


-- analyze team rankings (win percentage) by city and season to identify which cities host the most successful teams.

SELECT 
    ds.season_year,
    dt.city,
    dt.nickname AS team_name,
    SUM(dr.wins) AS total_wins,
    SUM(dr.lose) AS total_losses,
    SUM(dr.game_played) AS games_played,
    ROUND(SUM(dr.wins)::NUMERIC / NULLIF(SUM(dr.game_played), 0), 3) AS win_percentage
FROM dim_ranking dr
JOIN dim_team dt ON dr.team_id = dt.team_id
JOIN dim_season ds ON dr.season_id = ds.season_id
WHERE ds.season_year BETWEEN 2020 AND 2025
GROUP BY ds.season_year, dt.city, dt.nickname
HAVING SUM(dr.game_played) >= 50
ORDER BY ds.season_year, win_percentage DESC;

