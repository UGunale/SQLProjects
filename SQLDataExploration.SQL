Select * from PortfolioProjects..CovidDeaths
order by 3,4

Select  * from PortfolioProjects..CovidVaccinations
order by 3,4

Select location,date,total_cases,new_cases,total_deaths,population 
from PortfolioProjects..CovidDeaths order by 1,2

--looking at total cases vs. Total Deaths
-- Likelihood 
Select location,date,total_cases,total_deaths, (total_deaths/total_cases)*100 as DeathsPercentage
from PortfolioProjects..CovidDeaths 
where location like '%states%'
order by 1,2
-- Looking at Total cases vs population
-- shows that what pecentage of population got covid
Select location,date,population,total_cases, (total_cases/population)*100 as PercentPopulationinfected
from PortfolioProjects..CovidDeaths 
order by 1,2
-- Looking at Countries with highest inefection rate compared to population
Select location,population,max(total_cases) as HighestInfectionCount, max((total_cases/population))*100 as PercentPopulationInfected
from PortfolioProjects..CovidDeaths
group by location,population
order by PercentPopulationInfected desc
---showing countries with highest death count per population
Select location,max(cast(total_deaths as int)) as TotalDeathsCount from PortfolioProjects..CovidDeaths
where continent is not null
group by location
order by TotalDeathsCount desc
--- Break down by continent/showing continents with the highest death count per population
Select continent,max(cast(total_deaths as int)) as TotalDeathsCount from PortfolioProjects..CovidDeaths
where continent is not null
group by continent
order by TotalDeathsCount desc

---Global numbers
select Sum(New_cases) as Total_Cases,Sum(cast(New_deaths as int)) as Total_deaths,
sum(cast(new_deaths as int))/sum(new_cases) * 100 as DeathPercentage
from PortfolioProjects..CovidDeaths
where continent is not null
--group by date
order by 1,2

---looking at Total population vs vacinations
Select Dea.continent,Dea.location,Dea.date,Dea.population,vac.new_vaccinations
,Sum(convert(int,vac.new_vaccinations))over(partition by Dea.location order by Dea.location,Dea.date) as RollingPeopleVacinated
from PortfolioProjects..CovidDeaths as Dea
join PortfolioProjects..CovidVaccinations as vac
on Dea.location=vac.location and
Dea.date=vac.date
where Dea.continent is not null
order by 2,3 
---Using CTE
With PopvsVac(continent,location, date,population,new_vaccinations,RollingPeopleVacinated)
as
(
Select Dea.continent,Dea.location,Dea.date,Dea.population,vac.new_vaccinations
,Sum(convert(int,vac.new_vaccinations))over(partition by Dea.location order by Dea.location,Dea.date) as RollingPeopleVacinated
from PortfolioProjects..CovidDeaths as Dea
join PortfolioProjects..CovidVaccinations as vac
on Dea.location=vac.location and
Dea.date=vac.date
where Dea.continent is not null
--order by 2,3 
)
Select *,(RollingPeopleVacinated/population)*100 
from PopvsVac
----Uisng Temp Table
drop table if exists #PercentPopulationVacinated
Create table #PercentPopulationVacinated
(
 continent nvarchar(255),
 location nvarchar(255),
 date datetime,
 population numeric,
 Newvaccinations numeric,
 RollingPeopleVacinated numeric
 )
 insert into #PercentPopulationVacinated
 Select Dea.continent,Dea.location,Dea.date,Dea.population,vac.new_vaccinations
,Sum(convert(int,vac.new_vaccinations))over(partition by Dea.location order by Dea.location,Dea.date) as RollingPeopleVacinated
from PortfolioProjects..CovidDeaths as Dea
join PortfolioProjects..CovidVaccinations as vac
on Dea.location=vac.location and
Dea.date=vac.date
--where Dea.continent is not null

Select *,(RollingPeopleVacinated/population)*100 
from #PercentPopulationVacinated
--- Create the view
create view vPercentPopulationVacinated as
Select Dea.continent,Dea.location,Dea.date,Dea.population,vac.new_vaccinations
,Sum(convert(int,vac.new_vaccinations))over(partition by Dea.location order by Dea.location,Dea.date) as RollingPeopleVacinated
from PortfolioProjects..CovidDeaths as Dea
join PortfolioProjects..CovidVaccinations as vac
on Dea.location=vac.location and
Dea.date=vac.date
where Dea.continent is not null

Select * from vPercentPopulationVacinated
