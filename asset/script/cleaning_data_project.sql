															-- 		Data cleaning		 --
-- Remove duplicates
-- Standardize the data
-- NULL values and BLANK values
-- remove all unnecesseray columns  

#creation d'une table_essai comme l'original
Create table layoff_staging like layoffs;
# insertion de la table layoffs (original) vers la table layoff_staging (copie)
insert into layoff_staging 
select * from layoffs;

																		#REMOVE DUPLICATE
select *, row_number() over( 
		partition by company,location,industry,total_laid_off,percentage_laid_off,`date`,stage,country,funds_raised_millions ) as row_num
        from layoff_staging;
        
with duplicate_cte as (
						select *, row_number() over( 
						partition by company,location,industry,total_laid_off,percentage_laid_off,`date`,stage,country,funds_raised_millions) as row_num
						from layoff_staging
						)
select * from duplicate_cte
where row_num >1;
#WE can not delete the duplicate with cte(mysql - microsoft sql can do it) we have to create another table and delete it there

#creation de la nouvelle table
CREATE TABLE `layoff_staging2` (
  `company` text,
  `location` text,
  `industry` text,
  `total_laid_off` int DEFAULT NULL,
  `percentage_laid_off` text,
  `date` text,
  `stage` text,
  `country` text,
  `funds_raised_millions` int DEFAULT NULL,
  `row_num` int
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;

#inseret from lay_staging to lay_staging2 and delete  row_num >1 
insert into layoff_staging2
select *, row_number() over( 
						partition by company,location,industry,total_laid_off,percentage_laid_off,`date`,stage,country,funds_raised_millions) as row_num
						from layoff_staging;
		
        select * from layoff_staging2;
delete 
from layoff_staging2
where row_num >1;
select *
from layoff_staging2
where row_num >1;

																-- STANDARDIZING DATA --
                                                                
select company , trim(company)
from layoff_staging2;

update layoff_staging2
set company=  trim(company);

select distinct industry , trim(industry)
from layoff_staging2
order by 1;

select * from layoff_staging2
where industry like 'crypto%';

#standardiser la colonne industry  crypto 
update layoff_staging2
set industry = 'Crypto'
where industry like 'Crypto%';

#standardiser la colonne country United states
select distinct country,trim(trailing '.' from country)
from layoff_staging2
order by 1; 

update layoff_staging2
set country = trim(trailing '.' from country)
where country like 'United States%';

#change la date de text en datetime
select `date`, str_to_date(`date`,'%m/%d/%Y')
from layoff_staging2;

update layoff_staging2
set `date`=str_to_date(`date`,'%m/%d/%Y');

alter table layoff_staging2
modify column `date` DATE;

																-- NULL AND BLANK VALUES --
   #check les colonnes total_laid_off and percentage_laid_off null et vide                                                     
 select * from layoff_staging2                                               
where total_laid_off is null 
and percentage_laid_off is null;
#check dans layoff_staging2 ou l'industry est vide ou null
select * from layoff_staging2
where industry is null
or industry = '';


select * from layoff_staging2
where company='Airbnb';

select *
from layoff_staging2 t1
join layoff_staging2 t2
	on t1.company=t2.company
    and t1.company=t2.company
where ( t1.industry is null or t1.industry='')
and t2.industry is not null;
#changement des valeurs de la colonne industry de vide a null
update layoff_staging2
set industry = null
where industry='';
#update t1 et t2 sur company de layoff(join itself) and charge sur t1 quand la valeur est null et que cette meme valeur n'est pas null sur t2
update layoff_staging2 t1
		join layoff_staging2 t2
			on t1.company=t2.company
		and t1.company=t2.company
	set t1.industry=t2.industry
	where t1.industry is null 
	and t2.industry is not null;


#delete data without total_laid_off and percentage_laid_off

delete 
from layoff_staging2                                               
where total_laid_off is null 
and percentage_laid_off is null;

select * from layoff_staging2;


#suppresion de la colonne row_run
Alter table layoff_staging2
drop column row_num;



 