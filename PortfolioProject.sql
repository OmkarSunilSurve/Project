create database if not exists PortfolioProject;
use PortfolioProject;

drop table Covid_Death;
CREATE TABLE `Covid_Death` (
	iso_code VARCHAR(40) NOT NULL, 
	continent VARCHAR(40), 
	location VARCHAR(40) NOT NULL, 
	date_p  date, 
	population DECIMAL(38, 0) NOT NULL, 
	total_cases DECIMAL(38, 0), 
	new_cases DECIMAL(38, 0), 
	new_cases_smoothed DECIMAL(38, 3), 
	total_deaths DECIMAL(38, 0), 
	new_deaths DECIMAL(38, 0), 
	new_deaths_smoothed DECIMAL(38, 3), 
	total_cases_per_million DECIMAL(38, 3), 
	new_cases_per_million DECIMAL(38, 3), 
	new_cases_smoothed_per_million DECIMAL(38, 3), 
	total_deaths_per_million DECIMAL(38, 3), 
	new_deaths_per_million DECIMAL(38, 3), 
	new_deaths_smoothed_per_million DECIMAL(38, 3), 
	reproduction_rate DECIMAL(38, 2), 
	icu_patients DECIMAL(38, 0), 
	icu_patients_per_million DECIMAL(38, 3), 
	hosp_patients DECIMAL(38, 0), 
	hosp_patients_per_million DECIMAL(38, 3), 
	weekly_icu_admissions DECIMAL(38, 0), 
	weekly_icu_admissions_per_million DECIMAL(38, 3), 
	weekly_hosp_admissions DECIMAL(38, 0), 
	weekly_hosp_admissions_per_million DECIMAL(38, 3)
);

set session sql_mode = ' ';

LOAD DATA INFILE 
'c:/Covid_Deaths.csv'
into table `Covid_Death`
FIELDS TERMINATED BY ','
ENCLOSED BY '"'
LINES TERMINATED BY '\n'
IGNORE 1 ROWS;

-- select * from Covid_Death limit 10;

select count(*) from Covid_Death;

drop table Covid_Vaccination;
CREATE TABLE Covid_Vaccination (
	iso_code VARCHAR(40) NOT NULL, 
	continent VARCHAR(40), 
	location VARCHAR(40) NOT NULL, 
	Date_p date, 
	total_tests DECIMAL(38, 3), 
	new_tests DECIMAL(38, 3), 
	total_tests_per_thousand DECIMAL(38, 3), 
	new_tests_per_thousand DECIMAL(38, 3), 
	new_tests_smoothed DECIMAL(38, 3), 
	new_tests_smoothed_per_thousand DECIMAL(38, 3), 
	positive_rate DECIMAL(38, 3), 
	tests_per_case DECIMAL(38, 3), 
	tests_units VARCHAR(40), 
	total_vaccinations DECIMAL(38, 3), 
	people_vaccinated DECIMAL(38, 3), 
	people_fully_vaccinated DECIMAL(38, 3), 
	total_boosters DECIMAL(38, 3), 
	new_vaccinations DECIMAL(38, 3), 
	new_vaccinations_smoothed DECIMAL(38, 3), 
	total_vaccinations_per_hundred DECIMAL(38, 3), 
	people_vaccinated_per_hundred DECIMAL(38, 3), 
	people_fully_vaccinated_per_hundred DECIMAL(38, 3), 
	total_boosters_per_hundred DECIMAL(38, 3), 
	new_vaccinations_smoothed_per_million DECIMAL(38, 3), 
	new_people_vaccinated_smoothed DECIMAL(38, 3), 
	new_people_vaccinated_smoothed_per_hundred DECIMAL(38, 3), 
	stringency_index DECIMAL(38, 3), 
	population_density DECIMAL(38, 3), 
	median_age DECIMAL(38, 3), 
	aged_65_older DECIMAL(38, 3), 
	aged_70_older DECIMAL(38, 3), 
	gdp_per_capita DECIMAL(38, 3), 
	extreme_poverty DECIMAL(38, 3), 
	cardiovasc_death_rate DECIMAL(38, 3), 
	diabetes_prevalence DECIMAL(38, 3), 
	female_smokers DECIMAL(38, 3), 
	male_smokers DECIMAL(38, 3), 
	handwashing_facilities DECIMAL(38, 3), 
	hospital_beds_per_thousand DECIMAL(38, 3), 
	life_expectancy DECIMAL(38, 3), 
	human_development_index DECIMAL(38, 3), 
	excess_mortality_cumulative_absolute DECIMAL(38, 3), 
	excess_mortality_cumulative DECIMAL(38, 3), 
	excess_mortality DECIMAL(38, 3), 
	excess_mortality_cumulative_per_million DECIMAL(38, 3)
);

set session sql_mode = ' ';
LOAD DATA INFILE 
'c:/Covid_Vaccination.csv'
into table `Covid_Vaccination`
FIELDS TERMINATED BY ','
ENCLOSED BY '"'
LINES TERMINATED BY '\n'
IGNORE 1 ROWS;

select * from Covid_Vaccination;
select count(*) from Covid_Vaccination;
select location,date_p,total_cases,new_cases,total_deaths,population from Covid_Death order by 1,2;


-- Looking at total cases vs total deaths
-- Show the likelihood of dying if we contract covid
select location,date_p,total_cases,total_deaths,(total_deaths/total_cases)*100 as Death_Percentage
 from Covid_Death where location like 'India' order by 1,2;


-- Looking at total case vs Population
-- Shows % of population infected with Covid
select location,date_p,population,total_cases,(total_cases/population)*100 as Death_Percentage
 from Covid_Death where location like 'India' order by 1,2;
 
 
-- Looking at countries with highest infection rate compared to population

select location,population,max(total_cases) as Highest_infection_count,max((total_cases/population))*100 as Percentage_of_infected_population
 from Covid_Death  group by location , population order by Percentage_of_infected_population desc;

 
 -- setting blank spaces as NULL
 
  select Location,continent from Covid_Death where continent is not NULL ;
 update Covid_Death set continent = nullif(continent,'');
 
 -- Showing highest deathcount per population
 
 select location,max(total_deaths) as Total_death_count
 from Covid_Death where continent is not null group by location  order by Total_death_count desc;
 
 
 -- Break thing by continent
  select Continent,max(total_deaths) as Total_death_count
 from Covid_Death where continent is not null group by continent  order by Total_death_count desc;

 
 -- Showing Continent with highest dead count
  select Continent,max(total_deaths) as
  Total_death_count
 from Covid_Death 
 where continent is not null 
 group by continent  
 order by Total_death_count desc;

 
 -- Global Numbers
 select sum(new_cases) as Total_Cases ,sum(new_deaths) as Total_Deaths, sum(new_deaths)/sum(new_cases) * 100 as
 Death_Percentage
 from Covid_Death where continent is not null order by 1,2;


-- Looking at total population VS Vaccination  -- Using A CTE

with PoP_VS_VACC (continent,location,date_p,population,new_vaccinations,Cumulative_Vaccinnated_People) as 
(
select dea.continent,dea.location,dea.date_p,dea.population,vac.new_vaccinations,
sum(vac.new_vaccinations) over (Partition by dea.location order by dea.location,dea.date_p) as Cumulative_Vaccinated_People
from Covid_Death dea join
 Covid_Vaccination vac
  on dea.location = vac.location
  and dea.date_p = vac.Date_p
   where dea.continent is not null 
 )
 
 select *,(Cumulative_Vaccinnated_People/Population)*100 from PoP_VS_VACC;
 

 -- Temp Table
 drop table if exists Percent_pop_Vac;
 create table Percent_pop_Vac (
 Continent varchar(40)  not NULL,
 Location varchar(40) not NULL ,
 Date_T date ,
 Population decimal(38,4) ,
 New_vaccination decimal(38,3),
 Cumulative_Vaccinated_People decimal(38,3)
 );
 
 set session sql_mode = '';
 
 Insert into Percent_pop_Vac 
select dea.continent,dea.location,dea.date_p,dea.population,vac.new_vaccinations,
sum(vac.new_vaccinations) over (Partition by dea.location order by dea.location,dea.date_p) as Cumulative_Vaccinated_People
from Covid_Death dea join
 Covid_Vaccination vac
  on dea.location = vac.location
  and dea.date_p = vac.Date_p
   where dea.continent is not null ;
 
 select count(*) from Percent_pop_Vac;
select * from Percent_pop_Vac;
 
 
 -- creating View to store data for later visualization
 
 create View Per_Pop_Vac as
 select dea.continent,dea.location,dea.date_p,dea.population,vac.new_vaccinations,
sum(vac.new_vaccinations) over (Partition by dea.location order by dea.location,dea.date_p) as Cumulative_Vaccinated_People
from Covid_Death dea join
 Covid_Vaccination vac
  on dea.location = vac.location
  and dea.date_p = vac.Date_p
   where dea.continent is not null ;


select * from Per_Pop_Vac;  
 
 
 
 -- Queries for Tableau 
 
 
 -- 1 
 Select SUM(new_cases) as total_cases, SUM(new_deaths) as total_deaths, SUM(new_deaths)/SUM(New_Cases)*100 as DeathPercentage
From Covid_Death
where continent is not null 
order by 1,2 ;
 
 -- 2
 
 Select location, SUM(new_deaths) as TotalDeathCount
From Covid_Death
Where continent is null 
and location not in ('World', 'European Union', 'International','High income','Low income','Upper middle income','Lower middle income')
Group by location
order by TotalDeathCount desc;
 
 
 -- 3
 
Select Location, Population, MAX(total_cases) as HighestInfectionCount,  Max((total_cases/population))*100 as PercentPopulationInfected
From Covid_Death
Group by Location, Population
order by PercentPopulationInfected desc;
 
 
 -- 4
 
 Select Location, Population,date_p, MAX(total_cases) as HighestInfectionCount,  Max((total_cases/population))*100 as PercentPopulationInfected
From Covid_Death
Group by Location, Population, date_p
order by PercentPopulationInfected desc;
-- into outfile 'C:/Program Files/MySQL/MySQL Server 8.0/TT4.txt' FIELDS TERMINATED BY ','  ENCLOSED BY '"' LINES TERMINATED BY '\n';
 
 
 
 