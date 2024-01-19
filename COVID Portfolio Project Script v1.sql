SELECT *
FROM PortfolioProject..CovidDeaths
where continent is not null
order by 3,4;

SELECT *
FROM PortfolioProject..CovidVaccinations
order by 3,4;

-- Select Data that we are going to be using

Select location, date, total_cases, new_cases, total_deaths, population
From PortfolioProject..CovidDeaths
Order by 1, 2

-- Looking at Total Cases vs Total Deaths
-- Shows likelihood of dying if you contact covid in your country

Select location, date, total_cases, total_deaths, (total_deaths/total_cases)*100 AS DeathPercentage
From PortfolioProject..CovidDeaths
Where location LIKE '%States%' AND date = '2021-04-30'
Order by 1, 2


-- Total Cases vs Population

Select location, date, total_cases, population, (total_cases/population)*100 AS InfectionRate
From PortfolioProject..CovidDeaths
--Where location = 'South Africa'
Order by 1, 2

-- Countries with highest infection rate per population

Select location, population, MAX(total_cases) as HighestInfectionCount, MAX((total_cases)/population)*100 AS InfectionRate
From PortfolioProject..CovidDeaths
--Where location = 'South Africa'
Group by location, population
Order by InfectionRate Desc

-- Countries with highest Death rate per population

Select location, population, MAX(Cast(total_deaths AS INT)) as TotalDeaths, MAX((total_deaths)/population)*100 AS DeathRate
From PortfolioProject..CovidDeaths
where continent is not null
--Where location = 'South Africa'
Group by location, population
Order by TotalDeaths Desc

-- Countries with highest Death rate per cases, with minimum of 1000 cases

Select location, total_cases, MAX(total_deaths) as TotalDeaths, MAX((total_deaths)/total_cases)*100 AS DeathRate
From PortfolioProject..CovidDeaths
--Where location = 'South Africa'
--Where total_cases > 1000
Group by location, total_cases
Order by DeathRate DESC

-- Breaking things down by continent

-- Continents with the highest death toll per population

Select continent, MAX(cast(Total_deaths as int)) as TotalDeathCount
From PortfolioProject..CovidDeaths
Where continent is not null
Group by continent
order by  TotalDeathCount desc

-- GLOBAL NUMBERS

Select  date, SUM(new_cases) as Total_Cases, SUM(cast(new_deaths as int)) as Total_Deaths,
(SUM(cast(new_deaths as int))/SUM(new_cases))*100 as DeathRate
From PortfolioProject..CovidDeaths
Where continent is not null
Group by date
Order by 1, 2

--============================================================================================

--Joining the tables
Select *
From PortfolioProject..CovidDeaths dea
Join PortfolioProject..CovidVaccinations vac
	On dea.location = vac.location
	and dea.date = vac.date

-- Looking at Total Population vs Vaccinations
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
From PortfolioProject..CovidDeaths dea
Join PortfolioProject..CovidVaccinations vac
	On dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null
order by 2,3

-- With Rolling count for total vaccinated
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
SUM(convert(int, vac.new_vaccinations)) OVER (Partition by dea.location order by dea.location, dea.date) as TotalVaccinations
From PortfolioProject..CovidDeaths dea
Join PortfolioProject..CovidVaccinations vac
	On dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null
order by 2,3


-- Total people vaccinated per population for each country
-- Temp Table
Drop Table If Exists #PerPopulationVaccinated
Create Table #PerPopulationVaccinated
(
	Continent nvarchar(255),
	Location nvarchar(225),
	Date datetime,
	Population numeric,
	New_vaccinations numeric,
	RollingPeopleVaccinated numeric

)

Insert Into #PerPopulationVaccinated
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
SUM(convert(int, vac.new_vaccinations)) OVER (Partition by dea.location order by dea.location, dea.date) as TotalVaccinations
From PortfolioProject..CovidDeaths dea
Join PortfolioProject..CovidVaccinations vac
	On dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null

Select *, (RollingPeopleVaccinated/Population)*100
From #PerPopulationVaccinated



-- Creating View to store data for later visualizations

Create View PerPopulationVaccinated as
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
SUM(convert(int, vac.new_vaccinations)) OVER (Partition by dea.location order by dea.location, dea.date) as TotalVaccinations
From PortfolioProject..CovidDeaths dea
Join PortfolioProject..CovidVaccinations vac
	On dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null
--order by 2,3



