Select *
From Portfolio1..coviddeaths
where continent is not null
Order by 3,4


--Select *
--From Portfolio1..covidvaccs
--Order by 3,4

--Select Data that we aer going to be using

Select location, date, total_cases, new_cases, total_deaths,population
From Portfolio1..coviddeaths
Order by 1,2

--Looking at Total Cases vs Total Deaths

Select location, date, total_cases, total_deaths, (total_deaths/total_cases)*100 as DeathPercentage
From Portfolio1..coviddeaths
Order by 1,2

--Shows of likelihood of dying from covid in the USA

Select location, date, total_cases, total_deaths, (total_deaths/total_cases)*100 as DeathPercentage
From Portfolio1..coviddeaths
Where location like '%states%'
Order by date

--Looking at Total Cases vs Population
--Shows % of population contracted covid
Select location, date, total_cases, population, (total_cases/population)*100 as PopulationContracted
From Portfolio1..coviddeaths
Where location like '%states%'
Order by date

--Looking at countries with hightest infectious rate
Select location, population, MAX(total_cases) as HighestInfectiousCount, MAX((total_cases/population))*100 as HighestPopulationInfected
From Portfolio1..coviddeaths
Group By location, population
Order by HighestPopulationInfected desc

--Showing the countries with the highest death count per population
Select location, MAX(cast(total_deaths as int)) as  TotalDeathCount
From Portfolio1..coviddeaths
Where continent is not null	
Group By location
Order by TotalDeathCount desc

-- Break things down by continent

Select location, MAX(cast(total_deaths as int)) as  TotalDeathCount
From Portfolio1..coviddeaths
Where continent is null	
Group By location
Order by TotalDeathCount desc

--Showing the continents with the highest death count

Select continent, MAX(cast(total_deaths as int)) as  TotalDeathCount
From Portfolio1..coviddeaths
Where continent is not null	
Group By continent
Order by TotalDeathCount desc

--Global Numbers
Select date, sum(new_cases) as Total_Cases, sum(cast(new_deaths as int)) as Total_Deaths, sum(cast(new_deaths as int))/sum(new_cases)*100 as DeathPercentage
From Portfolio1..coviddeaths
Where continent is not null
Group by date
Order by date

Select sum(new_cases) as Total_Cases, sum(cast(new_deaths as int)) as Total_Deaths, sum(cast(new_deaths as int))/sum(new_cases)*100 as DeathPercentage
From Portfolio1..coviddeaths
Where continent is not null
Order by 1

Select *
From Portfolio1..coviddeaths as dea
Join Portfolio1..covidvaccs as va
	on dea.location = va.location
	and dea.date = va.date

--Looking at Total Population vs Vaccination

Select dea.continent, dea.location, dea.date, dea.population, va.new_vaccinations
, SUM(CAST(va.new_vaccinations as int)) OVER (Partition by dea.location Order by dea.location, dea.date) as rolling_vaccinated
From Portfolio1..coviddeaths as dea
Join Portfolio1..covidvaccs as va
	on dea.location = va.location
	and dea.date = va.date
Where dea.continent is not null
Order by 2,3

Select dea.continent, dea.location, dea.date, dea.population, va.new_vaccinations
, SUM(convert(int,va.new_vaccinations)) OVER (Partition by dea.location Order by dea.location, dea.date) as rolling_vaccinated
From Portfolio1..coviddeaths as dea
Join Portfolio1..covidvaccs as va
	on dea.location = va.location
	and dea.date = va.date
Where dea.continent is not null
Order by 2,3

--CTE
with PopsvVacc (continent, location, date, population, new_vaccinations, rolling_vaccinated)
as
(Select dea.continent, dea.location, dea.date, dea.population, va.new_vaccinations
, SUM(CAST(va.new_vaccinations as int)) OVER (Partition by dea.location Order by dea.location, dea.date) as rolling_vaccinated
From Portfolio1..coviddeaths as dea
Join Portfolio1..covidvaccs as va
	on dea.location = va.location
	and dea.date = va.date
Where dea.continent is not null
)
Select *, (rolling_vaccinated/population)*100
From PopsvVacc

--Temp table
Drop table if exists #percentpopulationvaccinated
create table #percentpopulationvaccinated
(
continent nvarchar(255),
location nvarchar(255),
date datetime,
population numeric,
new_vaccinations numeric,
rolling_vaccinated numeric
)

Insert into #percentpopulationvaccinated
Select dea.continent, dea.location, dea.date, dea.population, va.new_vaccinations
, SUM(convert(bigint,va.new_vaccinations)) OVER (Partition by dea.location Order by dea.location, dea.date) as rolling_vaccinated
From Portfolio1..coviddeaths as dea
Join Portfolio1..covidvaccs as va
	on dea.location = va.location
	and dea.date = va.date

Select *, (rolling_vaccinated/population)*100
From #percentpopulationvaccinated