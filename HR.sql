create database if not exists HR;
select * 
from human_resources;

alter table human_resources
change column ï»¿id emp_id varchar(20);

update human_resources
set birthdate = case 
	when birthdate like '%/%' then date_format(str_to_date(birthdate,'%m/%d/%Y'),'%Y-%m-%d')
    when birthdate like '%-%' then date_format(str_to_date(birthdate, '%m-%d-%Y'),'%Y-%m-%d')
    else null
    end;
    
describe human_resources;

alter table human_resources
modify column birthdate date;

update human_resources
set hire_date = case
	when hire_date like '%/%' then date_format(str_to_date(hire_date,'%m/%d/%Y'),'%Y-%m-%d')
    when hire_date like '%-%' then date_format(str_to_date(hire_date,'%m-%d-%Y'),'%Y-%m-%d')
    else null
    end;
    
alter table human_resources
modify column hire_date date;

update human_resources
set termdate = date(str_to_date(termdate, '%Y-%m-%d %H:%i:%s UTC'))
where termdate is not null and termdate !='';

update human_resources
set termdate = null
where termdate = '';

alter table human_resources
add column age int;

update human_resources
set age = timestampdiff(Year,birthdate,curdate());

-- age range --
select min(age), max(age)
from human_resources;

-- gender breakdown of existing employees -- 
select gender, count(*) as cnt_gen
from human_resources
where termdate is null
group by gender;    

-- race breakdown of existing employees --
select race, count(*) as cnt_race
from human_resources
where termdate is null
group by race;

-- age distribution of existing employees --
select 
	case 
		when age>=18 and age<=24 then '18-24'
        when age>=25 and age<=34 then '25-34'
        when age>=35 and age<=44 then '35-44'
        when age>=45 and age<=54 then '45-54'
        when age>=55 and age<=64 then '55-64'
        else '65+'
        end as age_grp,
        count(*) as cnt
from human_resources
where termdate is null
group by age_grp
order by age_grp ;

-- HQ vs remote --
select location, count(*) as cnt_loc
from human_resources
where termdate is null
group by location;

-- avg length of employment for terminated --
select round(avg(year(termdate) - year(hire_date)),0) as length_of_emp
from human_resources
where termdate is not null 
and termdate<= curdate();

-- gender dist across dept and job title --
select department, gender, count(*) as cnt_gen
from human_resources
where termdate is null
group by department, gender
order by department;

select jobtitle, gender, count(*) as cnt_gen
from human_resources
where termdate is null
group by jobtitle, gender
order by jobtitle;

-- dist of job titles --
select jobtitle, count(*) as cnt_job
from human_resources
where termdate is null
group by jobtitle
order by cnt_job desc;

select count(distinct jobtitle)
from human_resources;

-- dept with highest turnover rate --
select department, count(*) as total_cnt,
count(case
	when termdate is not null and termdate <= curdate() then 1
    end) as terminated_count,
round(count(case
			when termdate is not null and termdate <= curdate() then 1
            end)/count(*)*100,2) as termination_rate
from human_resources
group by department
order by termination_rate desc ;

-- dist of employees across location_state --
select location_state, count(*) as cnt_loc
from human_resources
where termdate is null
group by location_state
order by cnt_loc desc;

select location_city, count(*) as cnt_loc
from human_resources
where termdate is null
group by location_city
order by cnt_loc desc;

-- how has employee count changed over time based on hire and termdate --
select year, hires, terminations,
(hires - terminations) as net_change,
(terminations/hires)*100 as change_pct
	from(
		select year(hire_date) as year, count(*) as hires,
		sum(case 
			when termdate is not null and termdate<= curdate() then 1
		end) as terminations
        from human_resources
        group by year(hire_date)) as subquery
group by year
order by year ;

-- tenure dist for each dept --
select department, round(avg(datediff(termdate,hire_date)/365)) as avg_tenure
from human_resources
where termdate is not null and termdate <= curdate()
group by department;

select * 
from human_resources;

