/*
1-the query of building the basic cube
*/
SELECT *
FROM fact_game f
JOIN dim_team AS home ON f.home_team_id = home.team_id
JOIN dim_team AS away ON f.visitor_team_id = away.team_id
JOIN dim_season s ON f.season_id = s.season_id
JOIN dim_date d ON f.date_id = d.date_id


/*
basic cube including the ranking of the teams per season
TO BE CONTINUED (ASK)
*/
SELECT *
FROM fact_game f
JOIN dim_team AS home ON f.home_team_id = home.team_id
JOIN dim_team AS away ON f.visitor_team_id = away.team_id
JOIN dim_season s ON f.season_id = s.season_id
JOIN dim_date d ON f.date_id = d.date_id
JOIN dim_ranking r ON r.team_id = f.home_team_id AND r.season_id = s.season_id


/*
2- Compute the sum the nb of point scored by each team playing at home in each season 
*/
SELECT s.season_year, home.team_id, home.abbreviation, SUM(f.home_points) as home_points, SUM(f.home_assists) as home_assits ,SUM(f.home_rebounds) as home_rebounds
FROM fact_game f
JOIN dim_team AS home ON f.home_team_id = home.team_id
JOIN dim_season s ON f.season_id = s.season_id
GROUP BY s.season_year, home.team_id
ORDER BY home_points DESC

/*
3- Compute the Monthly Home Team Performance This means the sum of the points scored by each team in each month
Here we are performing a roll up session in order to get to the hierarchy of the month (date -> month)
*/
SELECT d.year, d.month, home.team_id,COUNT(*) AS nb_of_home_game_played, SUM(f.home_points) AS total_points
FROM fact_game f 
JOIN dim_team AS home ON f.home_team_id = home.team_id
JOIN dim_date d ON f.date_id = d.date_id
GROUP BY d.year, d.month, home.team_id
ORDER BY d.year, d.month

/*
4- Compute all the matches played by the team cavaliers
here, we are doing the slice olap 
slice: get all the matches played by the team Cavaliers
*/
SELECT f.game_id, s.season_year, d.date, home.abbreviation as home_team, f.home_points, away.abbreviation as away_team, f.visitor_points
FROM fact_game f
JOIN dim_team AS home ON f.home_team_id = home.team_id
JOIN dim_team AS away ON f.visitor_team_id = away.team_id
JOIN dim_season s ON f.season_id = s.season_id
JOIN dim_date d ON f.date_id = d.date_id
WHERE home.abbreviation = 'CLE' OR away.abbreviation = 'CLE'


/*
5-compute the query to get the performance of lebron james played
matches with the Cavaliers team
Slice the data for a specific team
*/
SELECT *
FROM dim_player_performance AS pp
WHERE pp.game_id IN
(SELECT f.game_id
FROM fact_game f 
JOIN dim_team AS home ON f.home_team_id = home.team_id
JOIN dim_team AS away ON f.visitor_team_id = away.team_id
WHERE home.abbreviation = 'CLE' OR away.abbreviation = 'CLE'
)AND pp.player_id IN
(SELECT player_id
FROM dim_player_static
WHERE player_name = 'LeBron James')


/*
6- Compute the query to get all the games in a specific season
slice: setting s.season_year to a specific value
*/
SELECT f.game_id, s.season_year, d.year, f.home_team_id, f.home_points
FROM fact_game f
JOIN dim_team AS home ON f.home_team_id = home.team_id
JOIN dim_date d ON f.date_id = d.date_id
JOIN dim_season s ON f.season_id = s.season_id
WHERE s.season_year = 2021;


/*
7-DICE : filter based on the year and the team abbreviation (ALL game played by 
the Cavaliers in the year 2022)
*/
SELECT f.game_id, d.year, home.team_id, home.abbreviation as home_team, away.team_id as away_team, away.abbreviation,f.home_points, f.visitor_points
FROM fact_game f
JOIN dim_team AS home ON f.home_team_id = home.team_id
JOIN dim_team AS away ON f.visitor_team_id = away.team_id
JOIN dim_date d ON f.date_id = d.date_id
WHERE d.year = 2022 AND (home.abbreviation = 'CLE' OR away.abbreviation = 'CLE');


/*
8-roll up : total wins by a team playing at their field (home) per year
*/
SELECT d.year, home.team_id, home.abbreviation, home.city, home.conference, home.arena, COUNT(*) AS total_home_wins
FROM fact_game f
JOIN dim_team AS home ON f.home_team_id = home.team_id
JOIN dim_date d ON f.date_id = d.date_id
WHERE f.home_team_wins = TRUE
GROUP BY d.year, home.team_id
ORDER BY d.year DESC, home.team_id ;


/*
9- Compute the nb of wins of the teams belonging to the conferences per season and per year
roll up :nb of total wins by teams of the 2 conferences per season
*/
SELECT  s.season_year, home.conference, COUNT(*) AS total_home_wins
FROM fact_game f
JOIN dim_team AS home ON f.home_team_id = home.team_id
JOIN dim_season s ON f.season_id = s.season_id
WHERE f.home_team_wins = TRUE
GROUP BY s.season_id, home.conference
ORDER BY s.season_id, home.conference;
/*
YEAR
*/
SELECT d.year, home.conference, COUNT(*) AS total_home_wins
FROM fact_game f
JOIN dim_team AS home ON f.home_team_id = home.team_id
JOIN dim_date d ON f.date_id = d.date_id
WHERE f.home_team_wins = TRUE
GROUP BY d.year, home.conference
ORDER BY d.year DESC, home.conference;


/*
10- Compute the query to get the average points scored by a team (home or away) in a specific month
roll up: average point per team per months
*/
SELECT d.year,d.month,t.abbreviation,
ROUND(AVG(CASE 
        WHEN f.home_team_id = t.team_id THEN f.home_points
        WHEN f.visitor_team_id = t.team_id THEN f.visitor_points
        ELSE 0
	END
    ),2) AS avg_points_per_game
FROM fact_game f
JOIN dim_team t ON t.team_id IN (f.home_team_id, f.visitor_team_id)
JOIN dim_date d ON f.date_id = d.date_id
WHERE d.year > 2003
GROUP BY d.year, d.month, t.abbreviation
ORDER BY avg_points_per_game DESC;


/*
11-drill down into both month and team performance(points scored) at the same time,
going from a season-level summary to detailed monthly stats for each team.
*/

SELECT s.season_year, d.year, d.month, t.abbreviation, 
SUM(
	CASE 
	WHEN f.home_team_id = t.team_id THEN f.home_points
	WHEN f.visitor_team_id = t.team_id THEN f.visitor_points
	ELSE 0
END) AS total_points
FROM fact_game f
JOIN dim_team t ON t.team_id IN (f.home_team_id, f.visitor_team_id)
JOIN dim_season s ON f.season_id = s.season_id
JOIN dim_date d ON f.date_id = d.date_id
WHERE d.year > 2004
GROUP BY s.season_id, d.year, d.month, t.team_id
ORDER BY s.season_id, d.year, d.month, t.team_id;


/*
12- Compute the query to get the teams per season with a home wins greater than a specific value
compute the count when the home_teams_wins = true and set a condition on the count (Having)
*/
SELECT s.season_id, home.team_id, home.abbreviation,COUNT(*) AS total_wins
FROM fact_game f
JOIN dim_team AS home ON f.home_team_id = home.team_id
JOIN dim_season s ON f.season_id = s.season_id
WHERE f.home_team_wins = TRUE
GROUP BY s.season_id, home.team_id
HAVING COUNT(*) > 35
ORDER BY s.season_id, total_wins DESC;



SELECT s.season_year, away.abbreviation, away.nickname, COUNT(*) AS total_away_wins
FROM fact_game f
JOIN dim_team AS away ON f.visitor_team_id = away.team_id
JOIN dim_season s ON f.season_id = s.season_id
WHERE f.home_team_wins = false
GROUP BY s.season_id, away.team_id
HAVING COUNT(*) > 35
ORDER BY s.season_id, total_away_wins DESC;


/*
13- Compute the game_id and other information, when the home team is Cavaliers
and this teams has win his twenti second win
HERE TO BE FIXED (DUE TO THE URGED TO FIX THE RANKING -> RANKING BASED ON DATE ID)
*/
SELECT f.game_id, f.home_points, f.visitor_points, r.game_played, r.wins
FROM fact_game f
JOIN dim_team t ON t.team_id IN (f.home_team_id, f.visitor_team_id)
JOIN dim_season s ON f.season_id = s.season_id
JOIN dim_date d ON f.date_id = d.date_id
JOIN dim_ranking r ON r.team_id = f.home_team_id AND r.season_id = s.season_id
WHERE r.wins = 22 AND home.abbreviation = 'CLE'



/*
3m nejma3 kl chi he ktirr kbiree SO PLEASE CHECK IT
*/
SELECT *
FROM fact_game f
JOIN dim_team AS home ON f.home_team_id = home.team_id
JOIN dim_team AS away ON f.visitor_team_id = away.team_id
JOIN dim_season s ON f.season_id = s.season_id
JOIN dim_date d ON f.date_id = d.date_id
JOIN dim_ranking r ON r.team_id = f.home_team_id AND r.season_id = s.season_id
JOIN dim_player_dynamic pd ON pd.team_id = f.home_team_id AND pd.season_id = s.season_id
JOIN dim_player_static ps ON pd.player_id = ps.player_id
JOIN dim_player_performance pp ON pp.player_id = pd.player_id AND pp.game_id = f.game_id


/*
15- compute the match id, points and abbreviation of home, points of the away team, and 
LEBRON james performance when lebron james is in the home team
*/
SELECT f.game_id, home.abbreviation AS lebron_team_home,f.home_points, f.visitor_points, pp.points, pp.assists
FROM fact_game f
JOIN dim_team AS home ON f.home_team_id = home.team_id
JOIN dim_team AS away ON f.visitor_team_id = away.team_id
JOIN dim_season s ON f.season_id = s.season_id
JOIN dim_date d ON f.date_id = d.date_id
JOIN dim_player_dynamic pd ON pd.team_id = f.home_team_id AND pd.season_id = s.season_id
JOIN dim_player_static ps ON pd.player_id = ps.player_id
JOIN dim_player_performance pp ON pp.player_id = ps.player_id AND pp.game_id = f.game_id
WHERE ps.player_name = 'LeBron James'


-- compute the match id, points and abbreviation of home, points of the away team, and 
-- LEBRON james performance
SELECT f.game_id, home.abbreviation AS home_team,away.abbreviation AS away_team,f.home_points, f.visitor_points, pp.points as lebron_points, pp.assists as lebron_assists
FROM fact_game f
JOIN dim_team AS home ON f.home_team_id = home.team_id
JOIN dim_team AS away ON f.visitor_team_id = away.team_id
JOIN dim_season s ON f.season_id = s.season_id
JOIN dim_date d ON f.date_id = d.date_id
JOIN dim_player_performance pp ON pp.game_id = f.game_id
JOIN dim_player_static ps ON pp.player_id = ps.player_id
JOIN dim_player_dynamic pd ON pp.player_id = pd.player_id AND pd.season_id = s.season_id
WHERE ps.player_name = 'LeBron James';


/*
16- Compute the query to get the player and the corresponding team name where he scored more than 50 points in a game
*/
SELECT f.game_id, ps.player_name, t.abbreviation AS Team_Player, pp.points, d.date, home.abbreviation AS home_team, away.abbreviation AS away_team
FROM fact_game f 
JOIN dim_team AS home ON f.home_team_id = home.team_id
JOIN dim_team AS away ON f.visitor_team_id = away.team_id
JOIN dim_date d ON f.date_id = d.date_id
JOIN dim_player_performance pp ON  pp.game_id = f.game_id
JOIN dim_player_static ps ON ps.player_id = pp.player_id 
JOIN dim_team t ON t.team_id = pp.team_id
WHERE pp.points > 50

