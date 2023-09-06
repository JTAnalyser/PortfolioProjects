SELECT *
FROM SQLPROJECTSSS..CovidDeaths
order by 3,4

--select *
--from SQLPROJECTSSS..CovidVaccinations
--order by 3,4

--select the data that we are going to be using

SELECT location, date, total_cases, new_cases, total_deaths, population
FROM SQLPROJECTSSS..CovidDeaths
order by 1,2

--Looking at the total cases vs the total deaths
--Shows the likelihood of dying if you contract Covid in your country

SELECT location, date, total_cases, total_deaths, (CONVERT(float, total_deaths) / NULLIF(CONVERT(float, total_cases),0))*100 as DeathPercentage
FROM SQLPROJECTSSS..CovidDeaths
order by 1,2

SELECT location, date, total_cases, total_deaths, (CONVERT(float, total_deaths) / NULLIF(CONVERT(float, total_cases),0))*100 as DeathPercentage
FROM SQLPROJECTSSS..CovidDeaths
Where location like '%Kingdom%'
order by 1,2

--Looking at Total cases vs population
--Showing what percentage of population got covid

SELECT location, date, total_cases, population, (CONVERT(float, total_cases) / NULLIF(CONVERT(float, population),0))*100 as CasePercentage
FROM SQLPROJECTSSS..CovidDeaths
Where location like '%Kingdom%'
order by 1,2

--looking at countries with highest infection rates compared to population

SELECT location, MAX(total_cases)as HighestInfectionCount, population, MAX((CONVERT(float, total_cases) / NULLIF(CONVERT(float, population),0)))*100 as CasePercentage
FROM SQLPROJECTSSS..CovidDeaths
--Where location like '%Kingdom%'
Group by location, population
order by CasePercentage DESC

--Showing the countries with the highest death count per population

SELECT location, MAX(cast(total_deaths as int))as HighestDeathCount
FROM SQLPROJECTSSS..CovidDeaths
--Where location like '%Kingdom%'
Where continent > ''
Group by location
order by HighestDeathCount DESC

--Let's break things down by continent

SELECT location, MAX(cast(total_deaths as int))as TotalDeathCount
FROM SQLPROJECTSSS..CovidDeaths
--Where location like '%Kingdom%'
Where continent = '' and location not like '%income%'
Group by location
order by TotalDeathCount DESC

--Showing continents with the highest deaths per population

SELECT continent, MAX(cast(total_deaths as int))as TotalDeathCount
FROM SQLPROJECTSSS..CovidDeaths
--Where location like '%Kingdom%'
Where continent > ''
Group by continent
order by TotalDeathCount DESC


--Global numbers

SELECT SUM(cast(new_cases as bigint)) as totalcases, SUM(cast(new_deaths as bigint)) as totaldeaths, sum(cast(new_deaths as bigint))/SUM(NULLIF (CONVERT(float, new_cases),0)) *100 as DeathPercentage
FROM SQLPROJECTSSS..CovidDeaths
--Where location like '%Kingdom%'
Where continent > ''
--Group by date
order by 1,2

--UK Numbers

SELECT SUM(cast(new_cases as bigint)) as totalcases, SUM(cast(new_deaths as bigint)) as totaldeaths, sum(cast(new_deaths as bigint))/SUM(NULLIF (CONVERT(float, new_cases),0)) *100 as DeathPercentage
FROM SQLPROJECTSSS..CovidDeaths
Where location like '%Kingdom%'
--Group by date
order by 1,2

--Looking at total population vs vaccination
--Looking at the cummulative vaccination

Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, sum(convert(bigint,vac.new_vaccinations)) OVER (Partition by dea.location order by dea.location, dea.date) as CummulativeVaccination
From SQLPROJECTSSS..CovidDeaths dea
Join SQLPROJECTSSS..CovidVaccinations vac
    On dea.location = vac.location
	and dea.date = vac.date
	and dea.continent = vac.continent
where dea.continent > ''
Group by dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
order by 2,3

-- USING CTE

With PopvsCumvac (continent, location, date, population, New_Vaccinations, CummulativeVaccination)
as
(
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, sum(convert(bigint,vac.new_vaccinations)) OVER (Partition by dea.location order by dea.location, dea.date) as CummulativeVaccination
From SQLPROJECTSSS..CovidDeaths dea
Join SQLPROJECTSSS..CovidVaccinations vac
    On dea.location = vac.location
	and dea.date = vac.date
	and dea.continent = vac.continent
where dea.continent > ''
Group by dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
Order by 2,3 OFFSET 0 ROWS
)
select *, (CummulativeVaccination/convert(bigint,population))*100
from PopvsCumvac


--Creating view to store data for later visualization

create view DeathToInfectedRatio as
SELECT SUM(cast(new_cases as bigint)) as totalcases, SUM(cast(new_deaths as bigint)) as totaldeaths, sum(cast(new_deaths as bigint))/SUM(NULLIF (CONVERT(float, new_cases),0)) *100 as DeathPercentage
FROM SQLPROJECTSSS..CovidDeaths
Where location like '%Kingdom%'
--Group by date
--order by 1,2
