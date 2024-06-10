															-- __EXPLORATORY Data analysis__ --
-- the campagnie withh the total_laid_off
select company,sum(total_laid_off)
from layoff_staging2
group by company
order by 2 desc	;													

-- the industry with the most total_laid_off
select industry, sum(total_laid_off)
from layoff_staging2
group by industry
order by 1 desc;
-- which country
select country, sum(total_laid_off)
from layoff_staging2
group by country
order by 2 desc;


-- by year
select year(`date`),sum(total_laid_off)
from layoff_staging2
group by year(`date`)
order by 2 desc;

-- by stage
select stage,sum(total_laid_off),industry
from layoff_staging2
group by stage,industry
order by 1 desc;
-- by month

select substring(`date`,1,7) as `Month`,sum(total_laid_off)
from layoff_staging2
where substring(`date`,1,7) is not null
group by substring(`date`,1,7)
order by 1 ;

with rolling_total as 
( select substring(`date`,1,7) as `Month`,sum(total_laid_off) as total_laid
from layoff_staging2
where substring(`date`,1,7) is not null
group by `Month`
order by 1
)
select `Month`,total_laid,
sum(total_laid) over (partition by `Month`) as rolling_total
from rolling_total;

select company,year(`date`),sum(total_laid_off) 
from layoff_staging2
group by company,year(`date`)
order by 3 desc  ;

with company_year (company,years,total_laid_off) as (
select company,year(`date`),sum(total_laid_off) 
from layoff_staging2
group by company,year(`date`)
), 
company_Years_rank as (
select *,dense_rank() over (partition by years order by total_laid_off desc) as ranking
from company_year
where years is not null 
 ) 
 select *
 from company_Years_rank
 where ranking>=3;




