Use PortfolioProject
Select * From CovidVaccination
order by 3,4 --- doble orden, por el num de columna que tomo como filtro

Select * From CovidDeaths
where continent != 'null'
order by 2 --- el numero indica el num de columna que tomo como filtro

-- Filtro los datos que quiero usar

Select location,date, total_cases,new_cases,total_deaths,population
From CovidDeaths
order by 1,2

-- Ratio Total de Casos Vs Total Muertes (esta fórmula no corre si no son VARCHAR)
Select location,date,total_cases,total_deaths
,CONVERT(DECIMAL(15,2), (CONVERT(DECIMAL(15,2), total_deaths) / CONVERT(DECIMAL(15,2), total_cases))*100) AS Ratio
From CovidDeaths
where (total_deaths != 'null' and location like '%arg%')
--where ( location like '%arg%')
order by 3


-- traer info de mis columnas
SELECT * FROM Information_Schema.COLUMNS
WHERE TABLE_NAME='CovidDeaths'

-- convertir una columna el tipo de datos
ALTER TABLE CovidDeaths ALTER COLUMN total_deaths DECIMAL(15,3);
ALTER TABLE CovidDeaths ALTER COLUMN total_cases DECIMAL(15,3);

Select location,date,total_cases,new_cases, total_deaths, (total_deaths /total_cases)*100 AS Ratio
From CovidDeaths
where location like '%arg%' AND total_deaths IS NOT NULL
order by 3 DESC

-- vuelvo a convertir columnas al tipo de datos original
ALTER TABLE CovidDeaths ALTER COLUMN total_deaths NVARCHAR(255);
ALTER TABLE CovidDeaths ALTER COLUMN total_cases NVARCHAR(255);

-- Veamos el ratio Total de casos Vs Población, en el mundo
ALTER TABLE CovidDeaths ALTER COLUMN new_cases NVARCHAR(255);
Select location, date,new_cases, population, (new_cases/population)*100 AS RatioTotalCasos
From CovidDeaths
where location like '%arg%' AND total_cases IS NOT NULL
order by 5 desc

-- Veamos el ratio Total de casos Vs Población, en el mundo, con sus máximos

Select location, population, MAX(total_cases) AS MaximoCasos, MAX((total_cases/population))*100 AS RatioTotalCasos
From CovidDeaths
Group by location, population
order by 4 Desc 

Select * From CovidDeaths
where continent is null


-- Busco total de casos máximos en el mundo
Select location, population, MAX(total_cases) AS MaximoCasos
From CovidDeaths
--where continent is not null
Group by location,population
--where location not like 'World' and location not like '%High%' and location not like 'Europe' and location not like '%Upper%'
--and location not like 'Asia'
order by 3 Desc 

-- Ver solo Argentina, ranking de día con mayores casos
Select location, date, MAX(CAST (new_cases as decimal)) DíaDeMasCasos From CovidDeaths
where location = 'Argentina'
group by location, date
order by 3 desc

-- Día con mas muertes en el mundo
Select location, MAX(CAST (total_deaths as bigint)) MuertesTotales From CovidDeaths
where continent is not null
group by location
order by 2 desc

-- Ranking muertes por continente (hay que analizar si debo hacer suma de los totales o si ya está contemplado como acumulado)
Select continent, SUM(CAST (new_deaths as decimal)) MuertesTotalesPorContinente From CovidDeaths
where continent is not null
group by continent
order by 2 desc

-- Ranking muertes por continente (trato de ver totales por otro camino, con otras columnas contempladas)
Select continent, MAX(CAST (total_deaths as bigint)) MuertesTotalesPorContinente 
From CovidDeaths
where continent is not null
group by continent
order by 2 desc

-- Vamos a unir tablas (join)
Select top (5) Dea.continent, Dea.location, dea.date, dea.population, Vac.new_vaccinations
From CovidDeaths As Dea
Join CovidVaccination As Vac
ON Dea.date = Vac.date
and Dea.location = Vac.location
Order by 1,2

--para ver solo continentes
Select location, population
From CovidDeaths
where continent is null 
	and location not like '%income%'  
	and location not like'%intern%'
	and location not like '%union%'
group by location, population

--para ver solo continentes
Select continent, MAX(cast(total_deaths as int)) As MuertesTotales
From CovidDeaths
where continent is not null 
group by continent
order by 2 desc

--Showing continents with the higest rate dead count per population 
Select location, population, MAX(total_deaths) As TotalMuertesContinente, 
(MAX(total_deaths)/(CAST (population as decimal))*100) As RatioMuertesPoblacion 
From CovidDeaths
where continent is null 
	and location not like '%income%'  
	and location not like'%intern%'
	and location not like '%union%'
	and location not like '%world%'
group by location, population
order by 3 desc

--Total de casos y muertes por día (y su relación o ratio)
Select date, SUM(CAST (new_cases as decimal)) CasosNuevosPorDia,
SUM(CAST (new_deaths as decimal)) MuertesTotalesPorDia,
SUM(CAST (new_deaths as decimal))/SUM(CAST (new_cases as decimal))*100 As RatioCasosVsMuertes
From CovidDeaths
where continent is not null
group by date
order by 1

--Total de casos y muertes Global (y su relación o ratio)
Select SUM(CAST (new_cases as decimal)) CasosNuevos,
SUM(CAST (new_deaths as decimal)) MuertesTotales,
SUM(CAST (new_deaths as decimal))/SUM(CAST (new_cases as decimal))*100 As RatioCasosVsMuertes
From CovidDeaths
where continent is not null
--group by date
order by 1


Select * 
from PortfolioProject..CovidDeaths As Dea
join PortfolioProject..CovidVaccination As Vac
	on dea.location = vac.location
	AND dea.date = vac.date
--Where total_cases = '5'
order by 3

--Total de vacunados y población (mundial)
Select dea.location, MAX(cast (dea.population as decimal)) As Poblacion, MAX (vac.total_vaccinations) As TotalVacunados,
MAX (vac.total_vaccinations) / MAX(cast (dea.population as decimal))*100 As PorcentajeVacunados
from PortfolioProject..CovidDeaths As Dea
join PortfolioProject..CovidVaccination As Vac
	on dea.location = vac.location
	AND dea.date = vac.date
Where dea.location = 'world'
group by dea.location

--Looking Total Population and Vaccinations for Country
Select Dea.location, dea.date, Dea.population, Vac.new_vaccinations,
SUM(cast(Vac.new_vaccinations as decimal)) OVER (PARTITION BY dea.location order by dea.location, dea.date)  As SumaVacunados
from PortfolioProject..CovidDeaths As Dea
join PortfolioProject..CovidVaccination As Vac
	on dea.location = vac.location
	AND dea.date = vac.date
where dea.continent is not null
group by dea.location,dea.date, dea.population,vac.new_vaccinations
order by 1,2
--OFFSET 1005 ROWS 
--FETCH NEXT 200 ROWS ONLY

/*si quiero mostrar la relacion entre poblacion y la suma de vacunados por pais, 
al ser un calculo adicional, no lo puedo meter en el select --> tengo q calcular en un CTE/temp.table y luego usarlo como columna
tener en cuenta agregar las columnas del CTE!!!!*/

/* Ahora quiero saber Relación Total Vacunados por País Vs Población del mismo,
como la sumatoria del punto anterior es cálculo nuevo, no puedo usarlo directamente en el SELECT, 
entonces pruebo con CTE*/
--PRESTAR a Atencion las columnas que quiero que contenga mi "cálculo CTE o tabla temporal". NO deben tener el prefijo 
--de las tablas originales de donde provienen

WITH CTE_TotalVaccVsPobl (continent,location, date, population, new_vaccinations,
SumatoriaGenteVacunadaPorPais)
AS
(
select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
SUM (convert (decimal, vac.new_vaccinations)) over (partition by dea.location order by dea.location,dea.date) 
As SumatoriaGenteVacunadaPorPais 
from CovidDeaths as Dea
join CovidVaccination as Vac
	ON dea.location = vac.location
	AND dea.date = vac.date
where dea.continent is not null AND dea.location = 'albania' AND vac.new_vaccinations is not null
)
--SELECT * FROM CTE_TotalVaccVsPobl
--Order by 2,3

-- Ahora con el calculo auxiliar CTE si puedo hacer mi nuevo calculo de relacion VAcunados Vs Poblacion
--RECORDAR QUE SIEMPRE DEBO EJECUTAR INCLUYENDO EL CTE
SELECT *, (SumatoriaGenteVacunadaPorPais/population)*100 As RatioVacunPoblacion
FROM CTE_TotalVaccVsPobl
Order by 2,3

-- mismo cálculo pero con Temp Table
DROP TABLE IF EXISTS #temp_TotalVaccVsPobl
CREATE TABLE #temp_TotalVaccVsPobl
(
continent nvarchar (50),
location nvarchar (50),
date datetime,
population numeric,
new_vaccination numeric,
SumatoriaGenteVacunadaPorPais numeric
)

INSERT INTO #temp_TotalVaccVsPobl
select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
SUM (convert (decimal, vac.new_vaccinations)) over (partition by dea.location order by dea.location,dea.date) 
As SumatoriaGenteVacunadaPorPais 
from CovidDeaths as Dea
join CovidVaccination as Vac
	ON dea.location = vac.location
	AND dea.date = vac.date
where dea.continent is not null AND dea.location = 'albania' AND vac.new_vaccinations is not null

 
SELECT *, (SumatoriaGenteVacunadaPorPais/population)*100 As RatioVacunPoblacion
FROM #temp_TotalVaccVsPobl
Order by 2,3

-- Created VIEW to store data for later visualizations (se crea archivo en carpeta VIEW dentro del proyecto para llevarlo a PowerBI
-- o Tableau). Este queda grabado "como" una tabla, ver detalle de esta función.
Create VIEW TotalVaccVsPobl AS
Select dea.continent, Dea.location, dea.date, Dea.population, Vac.new_vaccinations,
SUM(cast(Vac.new_vaccinations as decimal)) OVER (PARTITION BY dea.location order by dea.location, dea.date)  As SumaVacunados
from PortfolioProject..CovidDeaths As Dea
join PortfolioProject..CovidVaccination As Vac
	on dea.location = vac.location
	AND dea.date = vac.date
where dea.continent is not null
--order by 2,3

select *
from TotalVaccVsPobl
