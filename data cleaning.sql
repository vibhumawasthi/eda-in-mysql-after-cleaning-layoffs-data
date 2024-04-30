SELECT *
FROM layoffs;

-- 1. Remove Duplicates
-- 2. Standardize data
-- 3. Null values or Blank Values
-- 4. Remove Columns or Rows which are unnecessary


CREATE TABLE layoffs_staging
LIKE layoffs;

INSERT layoffs_staging
SELECT *
FROM layoffs;

SELECT *
FROM layoffs_staging;

SELECT *,
row_number() OVER(PARTITION BY company, location, industry, total_laid_off, percentage_laid_off, 'date', stage, country, funds_raised_millions) AS row_num
FROM layoffs_staging;

WITH duplicate_cte AS
( SELECT *,
row_number() OVER(PARTITION BY company, location, industry, total_laid_off, percentage_laid_off, 'date', stage, country, funds_raised_millions) AS row_num
FROM layoffs_staging
)
SELECT *
FROM duplicate_cte 
WHERE row_num>1;

SELECT *
FROM layoffs_staging
WHERE company = 'Casper';

CREATE TABLE `layoffs_staging_2` (
  `company` text,
  `location` text,
  `industry` text,
  `total_laid_off` int DEFAULT NULL,
  `percentage_laid_off` text,
  `date` text,
  `stage` text,
  `country` text,
  `funds_raised_millions` int DEFAULT NULL,
  row_num INT
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;


INSERT INTO layoffs_staging_2
SELECT *,
row_number() OVER(PARTITION BY company, location, industry, total_laid_off, percentage_laid_off, 'date', stage, country, funds_raised_millions) AS row_num
FROM layoffs_staging;

SELECT *
FROM layoffs_staging_2
WHERE row_num > 1;

DELETE
FROM layoffs_staging_2
WHERE row_num > 1;

SELECT *
FROM layoffs_staging_2;

-- Standardizing Data

SELECT company, (TRIM(company))
FROM layoffs_staging_2;

UPDATE layoffs_staging_2
SET company = (TRIM(company));

SELECT DISTINCT industry
FROM layoffs_staging_2
ORDER BY 1;


SELECT *
FROM layoffs_staging_2
WHERE industry like 'Crypto%';

UPDATE layoffs_staging_2
SET industry = 'Crypto'
Where industry like 'Crypto%';

SELECT DISTINCT location
FROM layoffs_staging_2
order by 1;

SELECT DISTINCT country
FROM layoffs_staging_2
order by 1;

SELECT country, trim(Trailing '.' from country)
FROM layoffs_staging_2;

UPDATE layoffs_staging_2
SET country = trim(trailing '.' from country)
Where country like 'United States%';

SELECT date, str_to_date(date, '%m/%d/%Y')
FROM layoffs_staging_2;

UPDATE layoffs_staging_2
SET date =  str_to_date(date, '%m/%d/%Y')

ALTER TABLE layoffs_staging_2
modify column 'date' DATE;

SELECT *
FROM layoffs_staging_2
WHERE total_laid_off IS NULL
AND percentage_laid_off IS NULL;

SELECT *
FROM layoffs_staging_2
WHERE industry IS NULL or industry = '';

SELECT *
FROM layoffs_staging_2
WHERE company is 'Airbnb';

SELECT *
FROM layoffs_staging_2 t1
JOIN layoffs_staging_2 t2
	ON t1.company = t2.company
    AND t1.location = t2.location
WHERE (t1.industry is null or t1.industry = '')
AND t2.industry is not null;

UPDATE layoffs_staging_2
SET industry = NULL
where industry = '';


UPDATE layoffs_staging_2 t1
JOIN layoffs_staging_2 t2
	ON t1.company = t2.company
SET t1.industry = t2.industry
WHERE t1.industry is null
AND t2.industry is not null;


DELETE
FROM layoffs_staging_2
WHERE total_laid_off IS NULL
AND percentage_laid_off IS NULL;

SELECT *
FROM layoffs_staging_2;

ALTER table layoffs_staging_2
DROP column row_num;