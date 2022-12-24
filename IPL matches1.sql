--Title of the Project:- IPL_Database Project
--Created by:- Abhishek Kumar Upadhyay
--Date of Creation- 02/12/2022
--Tools Used- PostgreSQL

/* About IPL_Dataset-
                     1-This a IPL_Database Project for the Portfolio project of SQL.
					 2-The database contains two tables matches and other is deliveries.
					 3-The match table has 816 lines, which contains the data and results of matches played between IPL 2008 and 2020.
					 4-Deliveries table has 1,93,468 rows, where it contains ball by ball data from IPL 2008 to 2020.
*/



-- Here we are going to analysis of IPL 2008-2020 dataset.
-- Firstly we create a Database which is IPL_DB and then we create a table Matches and other is Deliveries in IPL_DB

--Let's create a Table - Matches
CREATE TABLE Matches(
match_id int,
city varchar,
date date,
player_of_match varchar,
venue varchar,
neutral_venue int,
team1 varchar,
team2 varchar,
toss_winner varchar,
toss_decision varchar,
winner varchar,
result varchar,
result_margin int,
eliminator varchar,
method varchar,
umpire1 varchar,
umpire2 varchar
);

-- Let's create a second table Deliveries
drop table deliveries; 
CREATE TABLE deliveries ( 
match_id int,  
inning int,  
over int,  
ball int,  
batsman varchar,  
non_striker varchar,  
bowler varchar,  
batsman_runs int, 
extra_runs int,  
total_runs int, 
non_boundary int, 
is_wicket int,	
dismissal_kind varchar, 
player_dismissed varchar, 
fielder varchar, 
extras_type varchar, 
batting_team varchar,  
bowling_team varchar 
); 

--Import Data from IPL_matches.csv to Both the table 
COPY matches FROM 'C:\Program Files\PostgreSQL\15\data\IPL\IPL_matches.csv' CSV header;
COPY deliveries FROM 'C:\Program Files\PostgreSQL\15\data\IPL\IPL_Ball.csv' CSV header;

--To calculate the row from both the table
SELECT
COUNT(*)AS total_rows FROM Matches;

SELECT
COUNT (*) AS Total_rows FROM deliveries;


--Question(1)- Show both the table data
SELECT * FROM Matches;
SELECT * FROM deliveries;

--Question(2)- Select the top 20 row from Matches table
SELECT * FROM matches
LIMIT 20;

--Question(3)- Select the top 20 row from Delveries table
SELECT * FROM deliveries
LIMIT 20;

--Question(4) Fatched all the data of all matches played on 2nd May 2013
SELECT * FROM matches
WHERE date = '2008-04-30';

--Question(5)- Fetch data of all the matches where the margin of victory is more than 100 runs

--For this question we need to changes something in our data
/* When you see your raw csv data of result_margin column consist numeric & text both values, but the data type of column is varchar. 
Due to which we can't use aggregate functions.
You need to modify before copying this data into table is that to change the tect data into '0' and then copy.
Or you need to Update and alter the table after copying*/
--Here I'm already modify the data before copying and below are the query

--Answer of this question 
SELECT * FROM matches
WHERE result_margin > 100;

--And if you copy data before modifying then what will do is below are the query
/* So in order to fix this, we will update the result_margin column and change 'NA' value to 0
	
	UPDATE 	matches
	SET 	result_margin = 0
	WHERE 	result_margin = 'NA'


-- Now, we will change the data type of the result_margin column from varchar to integer
	
	ALTER TABLE 	matches
	ALTER COLUMN 	result_margin Type int Using result_margin :: integer 
	
-- Then run above answer of the question	*/

--Question(6)- Fatch data of all the matches where the result mode is 'runs' and margin of victory is more than 100 runs.
SELECT * FROM matches 
   WHERE result = 'runs'
    AND result_margin > 100;

--Question(7)- Fetch data of all the matches where the final scores of both teams tied and order it in descending order of the date
SELECT * FROM matches
  WHERE result = 'tie'
   ORDER BY date DESC;

--Question(8)- Get the count of cities that have hosted an IPL match.
SELECT COUNT(DISTINCT city)
FROM matches;
--Note- Another method is- 
SELECT COUNT(Distinct(City))
FROM matches;

/* Queston(8)- Create a tabel deliveries_v02 with all the column of the table  'deliveries' and an additional column ball_result 
containing values boundary, dot or other depending on the total_run */

CREATE TABLE deliveries_v02 AS
    SELECT *,
     CASE WHEN total_runs >= 4 THEN 'Boundary'
       WHEN total_runs =0 THEN 'Dot'
     ELSE 'Other'
    END AS Ball_Result
FROM deliveries;

-- To view this table 
SELECT * FROM deliveries_v02;

--Question(9)- Write a query to fetch the total number of boundaries, dot balls and other from the deliveries_v02 table.
--We can solve this question with 2 method
--1-With creating the the another table deliveries_v02 as above created
--2-Without creating additional table of deliveries_v02 using only deliveries table 

--Trick no-1 With support of additional table deliveries_v02 as above created
SELECT ball_result, COUNT(*) FROM deliveries_v02
WHERE ball_result IN ('Boundary', 'Dot', 'Other')
GROUP BY ball_result;

--Trick no-2 With the support of deliveries table
SELECT * 
  FROM
      (SELECT CASE WHEN total_runs >=4 THEN 'Boundary'
	        WHEN total_runs =0 THEN 'Dot'
	            ELSE 'Other'
	          END AS Ball_result,
	       COUNT (*)
	    FROM deliveries
     GROUP BY Ball_result) AS total_no_of_boundary_dot_other_ball 
WHERE Ball_result IN ('Boundary', 'Dot', 'Other');	
	
/* Question(10)-	Write a query to fetch the total no of boundaries scored by each team 
from the deliveries_v02 table and order it in descending order of the no. of boundaries scored. */

--We can write this query with 2 method
-- Trick 1- using deliveries_v02 table
SELECT batting_team,
     COUNT (*)AS total_no_of_boundaries 
       FROM deliveries_v02
       WHERE ball_result = 'Boundary'
     GROUP BY batting_team
ORDER BY total_no_of_boundaries DESC;
 --   *********OR*********
SELECT batting_team,
      COUNT(ball_result) AS Total_no_of_Boundaries
	     FROM deliveries_v02
		 WHERE ball_result = 'Boundary'
	GROUP BY batting_team
	ORDER BY Total_no_of_Boundaries DESC;

--Trick 2- Without using deliveries_v02 table with actual table deliveries
SELECT * 
     FROM 
         (SELECT batting_team, 
	         CASE WHEN total_runs >=4 THEN 'boundary'
	           WHEN total_runs = 0 THEN 'dot' 
	             ELSE 'other'
	               END AS ball_result,
	             COUNT (*) AS total_boundaries
	           FROM deliveries
	         GROUP BY batting_team, ball_result
	      ORDER BY total_boundaries DESC)
	  AS Total_no_of_Boundaries
WHERE ball_result IN ('boundary');	

/* Question(11) Write a query to fetch the total number of dot balls bowled by each team and order it in descending order of the 
total number of dot bowled. */

--We can write this query with 2 method
-- Trick 1- using deliveries_v02 table
SELECT bowling_team, 
COUNT(*) AS Total_no_of_dot_ball
FROM deliveries_v02
WHERE ball_result = 'Dot'
GROUP BY Bowling_team 
ORDER BY Total_no_of_dot_ball DESC;

-- ********OR*********
SELECT bowling_team,
COUNT(ball_result) AS Total_no_of_dot_ball
FROM deliveries_v02
WHERE ball_result ='Dot'
GROUP BY bowling_team
ORDER BY Total_no_of_dot_ball DESC;

--Trick 2- Without using deliveries_v02 table with actual table deliveries
SELECT * 
        FROM
		     (SELECT bowling_team,
			     CASE WHEN total_runs >=4 THEN 'boundary'
			       WHEN total_runs =0 THEN 'dot'
			         ELSE 'other'
			          END AS ball_result,
			         COUNT(*) AS total_dot
			       FROM deliveries
			    GROUP BY bowling_team, ball_result
			  ORDER BY total_dot DESC)
	     AS total_no_of_dots
WHERE ball_result IN ('dot');
			 
-- Question(12)-Write a query to fetch the total no. of dismissals by dismissal kinds where dismissal kind is not known
-- We can write query for the above with just 2 method
--Trick 1- With the use of 'NOT' function
SELECT dismissal_kind, COUNT(dismissal_kind) AS Total_No_of_dismissal_kinds
     FROM deliveries
        WHERE NOT dismissal_kind = 'NA'
     GROUP BY dismissal_kind
ORDER BY Total_No_of_dismissal_kinds DESC;

--Trick 2- Without 'NOT' function
SELECT dismissal_kind, COUNT(dismissal_kind) AS Total_No_of_dismissal_kinds
      FROM deliveries
         WHERE dismissal_kind <> 'NA'
      GROUP BY dismissal_kind
ORDER BY Total_No_of_dismissal_kinds DESC;

--Question(13)-Write a query to get the top 5 bowlers who conceded maximum extra runs from the deliveries table.
SELECT bowler, 
   SUM(extra_runs) AS MAX_Extra_Run
       FROM Deliveries
         GROUP BY bowler
      ORDER BY Max_Extra_Run DESC
   LIMIT 5;
	 
/* Question(14)- Write a query to create a table named deliveries_v03 with all the column of deliveries_v02 table and two 
additional column named venue and match_date of venue and date from table matches */

CREATE TABLE deliveries_v03 AS 
        SELECT a.*,
		b.venue,
		b.date
	FROM deliveries_v02 AS a
LEFT JOIN matches AS b
ON a.match_id = b.match_id
ORDER BY match_id;

--To view this table write a below query
SELECT * FROM deliveries_v03;

/* Question(15)- Write a query to fetch the total runs scored for each venue and order it in the descending order of total runs scored.*/
--We can write query for the above with just 2 method

--Trick 1- With deliveries_v03 table
SELECT venue, 
SUM(Total_runs) AS total_scored
FROM deliveries_v03
GROUP BY venue
ORDER BY total_scored DESC;

--Trick 2- Without deliveries_v03 table using the actual table 'matches' and 'deliveries' table
SELECT a.venue,
  SUM(b.total_runs) AS Total_scored
  FROM deliveries AS b
  INNER JOIN matches AS a
  ON a.match_id = b.match_id
  GROUP BY venue
  ORDER BY Total_scored DESC;
  
/* Question(16) Write a query to fetch the year wise total runs scored at Eden Gardens and order it in the descending order to 
total runs scored. */

--We can write query for the above with just 2 method

--Trick 1- With deliveries_v03 table
SELECT EXTRACT(YEAR FROM date) AS IPL_match_year,
         SUM(total_runs) AS Total_runs_scored
		 FROM deliveries_v03
		 WHERE venue = 'Eden Gardens'
		 GROUP BY IPL_match_year
		 ORDER BY Total_runs_scored DESC;
		 
--Trick 2- Without deliveries_v03 table using the actual table 'matches' and 'deliveries' table		
SELECT EXTRACT(YEAR FROM b.date) AS IPL_match_year,
SUM(total_runs)AS Total_runs_scored
FROM deliveries AS a
INNER JOIN matches AS b
ON a.match_id = b.match_id
WHERE venue = 'Eden Gardens'
GROUP BY IPL_match_year
ORDER BY Total_runs_scored DESC;
   
/* Question(17) Create a new table deliveries_v04 with the first column as ball_id containing information 
of match_id, inning, over and ball seperated by '-' (For ex. 335982-1-0-1 match_id-inning-over-ball) and rest of the columns same 
as deliveries_v03 */
 	CREATE TABLE deliveries_v04 AS
	SELECT concat(match_id, '-',inning,'-',over, '-', ball) AS ball_id, *
	FROM deliveries;
	
--To view this table below are the query
SELECT * FROM deliveries_v04;
   
/* Question(18) Compare the total count of rows and the total count of distinct ball_id in deliveries_v04 */
SELECT COUNT(*)AS total_row, 
COUNT(DISTINCT ball_id) AS Distinct_Ball_id
FROM deliveries_v04;

/* Question(18) Create table deliveries_v05 with all columns of deliveries_v04 and an additional column for row number partiton over 
ball_id. (HINT : Syntax to add along with other columns, row_number() over (partition by ball_id) as r_num) */

CREATE TABLE deliveries_v05 AS 
SELECT *, row_number() OVER (PARTITION BY ball_id) AS r_num
FROM deliveries_v04;

-- To view this table below are the query
SELECT * FROM deliveries_v05;

/* Question(19) Use the r_num created in deliveries_v05 to identify instances where ball_id is repeating. 
(HINT: SELECT * FROM deliveries_v05 WHERE r_num=2;)*/

SELECT * FROM deliveries_v05 
WHERE r_num =2;

/* Question(20) Use the subquery to fetch data of all the ball_id which are repeating. */

SELECT * FROM deliveries_v05
WHERE ball_id IN(SELECT ball_id
				  FROM deliveries_v05
				    WHERE r_num = 2)
	ORDER BY ball_id;

  Select Count(*)as total from matches;

