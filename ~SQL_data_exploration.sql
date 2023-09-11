SELECT * 
FROM PortfoliaProject ..CovidDeaths$
order by 3,4;

--SELECT * 
--FROM PortfoliaProject ..CovidVaccinations$
--order by 3,4;

Select location,date,total_cases,new_cases,total_deaths,population
From PortfoliaProject..CovidDeaths$
order by 1,2;

-- Looking at Total cases and Total Deaths
Select location,date,total_cases,total_deaths,(total_deaths/total_cases)*100 AS death_percentage
From PortfoliaProject..CovidDeaths$
order by 1,2;

--Looking at total cases vs population
Select location,date,total_cases,population,(total_cases/population)*100 As total_cases_percent
From PortfoliaProject..CovidDeaths$
where location = 'Asia'
order by 1,2;

-- Looking at countries with Highest Infection Rate
Select location,population,Max(total_cases) as HighestInfectionCount,Max((total_cases/population))*100 As PercentPopulationInfected
From PortfoliaProject..CovidDeaths$
where continent IS NOT NULL
Group by location,population
order by PercentPopulationInfected desc

--Looking at countries with highest Death Rate
Select location,Max(total_deaths) as TotalDeathCount
From PortfoliaProject..CovidDeaths$
where continent IS NOT NULL
Group by location
order by TotalDeathCount desc

--Looking at continent with highest Death Rate
Select continent,Max(total_deaths) as TotalDeathCount
From PortfoliaProject..CovidDeaths$
where continent IS NOT NULL
Group by continent
order by TotalDeathCount desc

Select *
from PortfoliaProject..CovidDeaths$
where continent IS NOT NULL

--GlOBAL NUMBERS
Select SUM(new_cases) as total_cases,SUM(CAST(new_deaths as int)) as total_deaths,SUM(CAST(new_deaths as int))/SUM(new_cases)*100 AS death_percentage
From PortfoliaProject..CovidDeaths$
where continent IS NOT NULL
--group by date
order by 1,2;

-- Joining two tables
Select * 
from PortfoliaProject..CovidDeaths$ dea
JOIN PortfoliaProject..CovidVaccinations$ vac
ON dea.location = vac.location
and dea.date = vac.date

-- Looking at Total Population vs Total vaccination
Select dea.continent,dea.location,dea.date,dea.population,vac.new_vaccinations
from PortfoliaProject..CovidDeaths$ dea
JOIN PortfoliaProject..CovidVaccinations$ vac
	ON dea.location = vac.location
	and dea.date = vac.date
where dea.continent IS NOT NULL
order by 1,2,3

Select dea.continent,dea.location,dea.date,dea.population,vac.new_vaccinations,
SUM(vac.new_vaccinations) OVER (Partition by dea.location,dea.Date) As RollingPeopleVaccinated
from PortfoliaProject..CovidDeaths$ dea
JOIN PortfoliaProject..CovidVaccinations$ vac
	ON dea.location = vac.location
	and dea.date = vac.date
where dea.continent IS NOT NULL
order by 1,2,3

-- Temp Table

DROP Table if exists #PercentPopulationVaccinated
CREATE Table #PercentPopulationVaccinated
(
Continent nvarchar(255),
Location nvarchar(255),
Date datetime,
Population numeric,
New_vaccinations numeric,
RollingPeopleVaccinated numeric
)

INSERT INTO #PercentPopulationVaccinated
Select dea.continent,dea.location,dea.date,dea.population,vac.new_vaccinations,
SUM(vac.new_vaccinations) OVER (Partition by dea.location,dea.Date) As RollingPeopleVaccinated
from PortfoliaProject..CovidDeaths$ dea
JOIN PortfoliaProject..CovidVaccinations$ vac
	ON dea.location = vac.location
	and dea.date = vac.date

Select * 
FROM #PercentPopulationVaccinated


-- CReating View to store data for later visualization

Create View PercentPopulationVaccinated as
Select dea.continent,dea.location,dea.date,dea.population,vac.new_vaccinations,
SUM(vac.new_vaccinations) OVER (Partition by dea.location,dea.Date) As RollingPeopleVaccinated
from PortfoliaProject..CovidDeaths$ dea
JOIN PortfoliaProject..CovidVaccinations$ vac
	ON dea.location = vac.location
	and dea.date = vac.date
where dea.continent IS NOT NULL
--order by 1,2,3

DROP VIEW PercentPopulationVaccinated

SELECT *
From
PercentPopulationVaccinated



