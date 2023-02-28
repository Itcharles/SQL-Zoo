1.
The example uses a WHERE clause to show the cases in 'Italy' in March 2020.

Modify the query to show data from Spain

SELECT name, DAY(whn),
 confirmed, deaths, recovered
 FROM covid
WHERE name = 'Spain'
AND MONTH(whn) = 3 AND YEAR(whn) = 2020
ORDER BY whn

2.
The LAG function is used to show data from the preceding row or the table. When lining up rows the data is partitioned by country name and ordered by the data whn. That means that only data from Italy is considered.

Modify the query to show confirmed for the day before.

SELECT name, DAY(whn), confirmed,
   LAG(confirmed, 1) OVER (PARTITION BY name ORDER BY whn)
 FROM covid
WHERE name = 'Italy'
AND MONTH(whn) = 3 AND YEAR(whn) = 2020
ORDER BY whn


3.
The number of confirmed case is cumulative - but we can use LAG to recover the number of new cases reported for each day.

Show the number of new cases for each day, for Italy, for March.

SELECT name, DAY(whn), confirmed-
   LAG(confirmed, 1) OVER (PARTITION BY name ORDER BY whn)
 FROM covid
WHERE name = 'Italy'
AND MONTH(whn) = 3 AND YEAR(whn) = 2020
ORDER BY whn

4.
The data gathered are necessarily estimates and are inaccurate. However by taking a longer time span we can mitigate some of the effects.

You can filter the data to view only Monday's figures WHERE WEEKDAY(whn) = 0.

Show the number of new cases in Italy for each week in 2020 - show Monday only.

SELECT name, DATE_FORMAT(whn,'%Y-%m-%d'), confirmed-LAG(confirmed,1) OVER(PARTITION BY name ORDER BY whn) AS new_cases
 FROM covid
WHERE name = 'Italy'
AND WEEKDAY(whn) = 0 AND YEAR(whn) = 2020
ORDER BY whn

5.
Show the number of new cases in Italy for each week - show Monday only.

In the sample query we JOIN this week tw with last week lw using the DATE_ADD function.

SELECT tw.name, DATE_FORMAT(tw.whn,'%Y-%m-%d'), 
 tw.confirmed-lw.confirmed
 FROM covid tw LEFT JOIN covid lw ON 
  DATE_ADD(lw.whn, INTERVAL 1 WEEK) = tw.whn
   AND tw.name=lw.name
WHERE tw.name = 'Italy' AND WEEKDAY(tw.whn) = 0 
ORDER BY tw.whn


RANK()
6.
This query shows the number of confirmed cases together with the world ranking for cases for the date '2020-04-20'. The number of COVID deaths is also shown.

United States has the highest number, Spain is number 2...

Notice that while Spain has the second highest confirmed cases, Italy has the second highest number of deaths due to the virus.

Add a column to show the ranking for the number of deaths due to COVID.

SELECT 
   name,
   confirmed,
   RANK() OVER (ORDER BY confirmed DESC) rc,
   deaths,RANK() OVER (ORDER BY deaths DESC) 
  FROM covid
WHERE whn = '2020-04-20'
ORDER BY confirmed DESC

7. 
This query includes a JOIN t the world table so we can access the total population of each country and calculate infection rates (in cases per 100,000).

Show the infection rate ranking for each country. Only include countries with a population of at least 10 million.

SOME data is still incorrect

SELECT 
   world.name,
   ROUND(100000*confirmed/population,2) AS el, RANK()OVER(ORDER BY el)
  FROM covid JOIN world ON covid.name=world.name
WHERE whn = '2020-04-20' AND population >= 10000000
ORDER BY population DESC


Turning the corner
8.
For each country that has had at last 1000 new cases in a single day, show the date of the peak number of new cases.

WITH table1 AS(
SELECT name, DATE_FORMAT(whn,'%Y-%M-%D')AS date,confirmed- LAG(confirmed,1) OVER(PARTITION BY name ORDER BY whn) AS new_cases
FROM covid
), table2 AS(
SELECT *,RANK()OVER(PARTITION BY name ORDER BY new_cases DESC) AS rank
FROM table1
WHERE new_cases>= '1000'
)
SELECT name, date,new_cases
FROM table2
WHERE rank = 1
ORDER BY date
