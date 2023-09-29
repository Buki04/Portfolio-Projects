-- Data Exploration of Covid 19 data
SELECT
  *
FROM
  portfolio-projects-399621.CovidDeaths.covid_deaths
WHERE
  continent IS NOT NULL
ORDER BY
  3,
  4;
  -- select *
  -- from portfolio-projects-399621.Covidvaccination.Covid_vaccination
  -- order by 3,4

-- Select Data that we are going to be starting with
SELECT
  location,
  date,
  population,
  total_cases,
  new_cases,
  total_deaths
FROM
  portfolio-projects-399621.CovidDeaths.covid_deaths
WHERE
  continent IS NOT NULL
ORDER BY
  1,
  2;
  
-- Total deaths vs. Total cases of each location
-- shows the chances of dying if infected by COVID in each country

SELECT
  location,
  date,
  total_cases,
  total_deaths,
  (total_deaths/total_cases)*100 AS death_percentage
FROM
  portfolio-projects-399621.CovidDeaths.covid_deaths
WHERE
  location = 'Canada'
ORDER BY
  1,
  2;

-- looking at Total cases vs. Population
-- shows the percentage of the population infected by COVID

SELECT
  location,
  date,
  total_cases,
  population,
  (total_cases/population)*100 AS infectedpop_percentage
FROM
  portfolio-projects-399621.CovidDeaths.covid_deaths
WHERE
  location = 'Canada'
  AND continent IS NOT NULL
ORDER BY
  1,
  2;
 
-- Looking at the country with the highest infection rate

SELECT
  location,
  population,
  MAX(total_cases) AS highestinfectioncount,
  MAX((total_cases/population)*100) AS infectedpop_percentage,
  EXTRACT(year
  FROM
    date) AS year
FROM
  portfolio-projects-399621.CovidDeaths.covid_deaths
WHERE
  continent IS NOT NULL
GROUP BY
  population,
  location,
  year
ORDER BY
  infectedpop_percentage DESC;

-- Looking at countries with the highest deaths per population

SELECT
  location,
  MAX(total_deaths) AS highestdeathcount
FROM
  portfolio-projects-399621.CovidDeaths.covid_deaths
WHERE
  continent IS NOT NULL
GROUP BY
  location
ORDER BY
  highestdeathcount DESC;

-- Looking at data Globally
-- Showing the continent with the highest death count

SELECT
  continent,
  MAX(total_deaths) AS highestdeathcount
FROM
  portfolio-projects-399621.CovidDeaths.covid_deaths
WHERE
  continent IS NOT NULL
GROUP BY
  continent
ORDER BY
  highestdeathcount DESC;
 
--Looking at the global numbers
--Showing the death percentage globally

SELECT
  SUM(new_cases) AS totalcases,
  SUM(new_deaths) AS totaldeaths,
  ((SUM(new_deaths))/(SUM(new_cases)))*100 AS deathpercentage
FROM
  portfolio-projects-399621.CovidDeaths.covid_deaths
WHERE
  continent IS NOT NULL
  AND new_cases <> 0
ORDER BY
  1,
  2;
  
--Total vaccination vs Population
--Showing the join of the two data sets to explore total vaccination vs. the population of each location

SELECT
  dea.continent,
  dea.location,
  dea.population,
  dea.date,
  vacc.new_vaccinations,
  SUM(new_vaccinations) OVER (PARTITION BY dea.location ORDER BY dea.location, dea.date) AS Rollingvaccinations
FROM
  portfolio-projects-399621.CovidDeaths.covid_deaths dea
JOIN
  portfolio-projects-399621.Covidvaccination.Covid_vaccination vacc
ON
  dea.location = vacc.location
  AND dea.date = vacc.date
WHERE
  dea.continent IS NOT NULL
ORDER BY
  2,
  4;
 
--create a temp table to continue the exploration of population vs. vaccination
  CREATE TEMP TABLE popvsvacc AS
SELECT
  dea.continent,
  dea.location,
  dea.population,
  dea.date,
  vacc.new_vaccinations,
  SUM(new_vaccinations) OVER (PARTITION BY dea.location ORDER BY dea.location, dea.date) AS Rollingvaccinations
FROM
  portfolio-projects-399621.CovidDeaths.covid_deaths dea
JOIN
  portfolio-projects-399621.Covidvaccination.Covid_vaccination vacc
ON
  dea.location = vacc.location
  AND dea.date = vacc.date
WHERE
  dea.continent IS NOT NULL;

-- Using the temp table as our new dataset
-- Discover the percentage of the population vaccinated per location 

SELECT
  *,
  (Rollingvaccinations/population)*100 AS percent_pop_vaccinated,
FROM
  popvsvacc
ORDER BY
  2,
  4;
