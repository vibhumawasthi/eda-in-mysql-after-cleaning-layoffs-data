-- EXPLORATORY DATA ANALYSIS

SELECT *
FROM layoffs_staging_2;

-- seeing max people laid off and max percentage laid off

SELECT MAX(total_laid_off), MAX(percentage_laid_off)
FROM layoffs_staging_2;

-- details of companies who lost all their employees and closed

SELECT * 
FROM layoffs_staging_2
WHERE percentage_laid_off = 1
ORDER BY total_laid_off DESC;

SELECT * 
FROM layoffs_staging_2
WHERE percentage_laid_off = 1
ORDER BY funds_raised_millions DESC;

-- DATA RANGE

SELECT MIN(date), MAX(date)
FROM layoffs_staging_2;

-- companies with max number of people laid off bby company, industry, country, year, stage

SELECT company, SUM(total_laid_off)
FROM layoffs_staging_2
GROUP BY company
ORDER BY 2 DESC;

SELECT industry, SUM(total_laid_off)
FROM layoffs_staging_2
GROUP BY industry
ORDER BY 2 DESC;

SELECT country, SUM(total_laid_off)
FROM layoffs_staging_2
GROUP BY country
ORDER BY 2 DESC;

SELECT year(date), SUM(total_laid_off)
FROM layoffs_staging_2
GROUP BY year(date)
ORDER BY 1 DESC;

SELECT stage, SUM(total_laid_off)
FROM layoffs_staging_2
GROUP BY stage
ORDER BY 2 DESC;


-- MONTHLY LAYOFFS
SELECT substring(date, 1, 7) as "month", sum(total_laid_off)
FROM layoffs_staging_2
WHERE substring(date, 1, 7) is not null
group BY substring(date, 1, 7)
order by 1 ASC;

-- ROLLING LAYOFF

with rolling_total as
(
SELECT substring(date, 1, 7) as mnth, sum(total_laid_off) as total_off
FROM layoffs_staging_2
WHERE substring(date, 1, 7) is not null
group BY substring(date, 1, 7)
order by 1 ASC
)
SELECT mnth, total_off, sum(total_off) OVER(ORDER BY mnth) as rolling_TOTAL
FROM rolling_total; 

-- top 5 LAYOFFS by company by year

SELECT company, YEAR(date), sum(total_laid_off)
FROM layoffs_staging_2
GROUP BY company, YEAR(date)
ORDER BY 3 DESC;

WITH company_year (company, years, total_laid_off) as
(
SELECT company, YEAR(date), sum(total_laid_off)
FROM layoffs_staging_2
GROUP BY company, YEAR(date)
),company_year_rank as 
(SELECT *, 
dense_rank() over (partition by years order by total_laid_off DESC) as ranking
FROM company_year
WHERE years is not NULL
)
SELECT *
FROM company_year_rank
WHERE ranking <=5;