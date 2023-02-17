select *
from portfolio..covid_deaths
where continent is not null
order by 3, 4

--select *
--from portfolio..covid_vaccination
--order by 3,4
select location, date, total_cases, new_cases, total_deaths, population
from portfolio..covid_deaths
order by 1,2

--смотрим общее кол-во заболеваний -смертей
--веро€тность смерти если ты заразишьс€ в какой-то стране
select location, date, total_cases, total_deaths, (CAST(total_deaths AS float) / CAST(total_cases AS float)) * 100.0 AS DeathPercentage
from portfolio..covid_deaths
where location like '%armenia%'
order by 1,2


--смотрим общее кол-во случаев заболевани€ по сравнению с населением
--какой процент населени€ заразилс€ ковитдом
select location, date, population, total_cases, (CAST(total_cases AS float) / CAST(population AS float)) * 100.0 AS Percentage_infection_population
from portfolio..covid_deaths
where location like '%armenia%'
order by 1,2


-- смотрим на страны с самым высоким уровнем инфицировани€ч епо сравнению с населением
select location, population, max(total_cases) as higest_infection_count, max((CAST(total_cases AS float) / CAST(population AS float))) * 100.0 AS percentage_infection_population
from portfolio..covid_deaths
--where location like '%armenia%'
group by location, population
order by Percentage_infection_population desc

-- показывает страны с самым высоким кол-вом на душу населени€ 
select location, max(cast(total_deaths as float)) as total_death_count	
from portfolio..covid_deaths
--where location like '%armenia%'
where continent is not null
group by location
order by total_death_count desc

-- -- показываем континенты с самым высоким числом смертей

select continent, max(cast(total_deaths as float)) as total_death_count	
from portfolio..covid_deaths
--where location like '%armenia%'
where continent is not null
group by continent
order by total_death_count desc

-- глобальные цифры 
select sum(cast(new_cases as float)) as new_cases, sum(cast(new_deaths as float)) as total_deaths,SUM(cast(new_deaths as float)) /SUM(cast(New_Cases as float))* 100 as DeathPercentage
from portfolio..covid_deaths
--where location like '%armenia%'
where continent is not null
--group by date
order by 1,2


-- обща€ численность населени€ в сравнении с скольз€щим значинием вакцинированных
with Pop_VS_Vac (continent, location, date,population, new_vaccinations, rolling_people_vacctinated)
as
(
select dea.continent, dea.location, dea.date, population,new_vaccinations
,sum(cast(new_vaccinations as float)) over (partition by dea.location order by dea.location, dea.date) as rolling_people_vacctinated
--,rolling_people_vacctinated/population)*100
from portfolio..covid_vaccination dea
join portfolio..covid_deaths vac
	on dea.location = vac.location
	and dea.date = vac.date
	where dea.continent is not null
	--order by 2,3
	)
select *, (rolling_people_vacctinated/population)*100
from Pop_VS_Vac


-- временна€ таблица
drop table if exists #precent_population_vaccination
create table #precent_population_vaccination
(
continent nvarchar(255),
location nvarchar(255),
date datetime,
population numeric,
new_vaccination numeric,
rolling_people_vaccinated numeric
)

insert into #precent_population_vaccination
select dea.continent, dea.location, dea.date, population,new_vaccinations
,sum(cast(new_vaccinations as float)) over (partition by dea.location order by dea.location, dea.date) as rolling_people_vacctinated
--,rolling_people_vacctinated/population)*100
from portfolio..covid_vaccination dea
join portfolio..covid_deaths vac
	on dea.location = vac.location
	and dea.date = vac.date
	--where dea.continent is not null
	--order by 2,3

	select *, (rolling_people_vaccinated/population)*100
from #precent_population_vaccination


-- —ќ«ƒјƒ»ћ ѕ–≈ƒ—“ј¬Ћ≈Ќ»≈ ƒјЌЌџ’ ƒЋя ѕќ—Ћ≈ƒ”ёў≈… ¬»«”јЋ»«ј÷»»

create VIEW precent_population_vaccination as
select dea.continent, dea.location, dea.date, population,new_vaccinations
,sum(cast(new_vaccinations as float)) over (partition by dea.location order by dea.location, dea.date) as rolling_people_vacctinated
--,rolling_people_vacctinated/population)*100
from portfolio..covid_vaccination dea
join portfolio..covid_deaths vac
	on dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null
--order by 2,3

select *
from precent_population_vaccination