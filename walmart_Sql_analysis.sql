select * from walmart;

select count(*) from walmart;

-- how many diff payment methods we have and which have the highest transaction method 
select payment_method,
count(*) as total_transactions
from walmart 
group by 1  ;

-- how many different no. of stores we have
select
count(Distinct branch) as total_branches 
from walmart;

-- maximum quantity
select max(quantity) from walmart;





-- Real Business Problems 

-- Find different payment method and number of transactions, number of qty sold
select distinct payment_method, 
sum( quantity) as no_qty_sold,
count(*) as no_transactions
from walmart
group by 1;


-- Identify the highest-rated category in each branch, displaying the branch, category, avg rating
select * 
from 
( select branch ,
category,
avg(rating) as avg_rating,
Rank() over(partition by branch order by avg(rating) Desc) as rank
from walmart
group by 1,2
order by 1,3 Desc 
)
where rank =1;


-- Identify the busiest day for each branch  on the number of transactions
select *
from 
(select branch,
to_char(TO_DATE(date, 'DD/MM/YY'),'Day') as day_name,
count(*) as no_transactions,
Rank() over(partition by branch order by count(*) Desc ) as rank
from walmart
group by 1,2
)
where rank =1;

-- calculate the total quantity of items sold par payment method. List payment_method and total_quantity
select payment_method, 
sum( quantity) as no_qty_sold
from walmart
group by 1;

-- Determine the avg,min and max rating of category for each city.
-- List the city, average_rating, min_rating and max_rating
select city,
category,
avg(rating) as avg_rating,
min(rating) as min_rating,
max(rating) as max_rating
from walmart
group by 1,2;

-- calculate the total profit for each category by considering total_profit as (unit_price * quantity *profit_margin)
-- List category and total_profit, ordered from highest to lowest profit
select category,
sum(total) as total_revenue,
sum(unit_price * quantity * profit_margin) as total_profit 
from walmart
group by 1;

-- determine the most common payment method for each branch 
select *
from
(select branch,
payment_method,
count(*) as total_transactions,
rank() over(partition by branch order by count(*) Desc ) as rank
from walmart
group by 1,2
)
where rank=1;

-- categorize sales into 3 groups MORNING, AFTERNOON, EVENING
-- Find out which of the shift and number of invoices
select branch,
case 
	when extract (hour from (time::time)) < 12 then 'Morning'
	when extract (hour from (time::time)) between 12 and 17 then 'Afternoon'
	else 'Evening'
End day_time,
count(*) as total_trans
from walmart 
group by 1,2
order by 1,3 Desc;


-- Identify 5 branch with highest decrease ratio in revenue campare to last year
-- current year 2023 and last year 2022
-- revenue decrease ratio 
-- rdr == last_rev - cr_rev/ ls_rev *100
SELECT *,
       EXTRACT(YEAR FROM TO_DATE(date, 'DD/MM/YY')) AS formatted_year
FROM walmart;

-- 2022 sales
with revenue_2022
as
(
	select branch,
	sum(total) as revenue
	from walmart 
	where Extract(year from to_date(date,'DD/MM/YY')) = 2022
	group by 1
),
revenue_2023
as
(
	select branch,
	sum(total) as revenue
	from walmart 
	where Extract(year from to_date(date,'DD/MM/YY')) = 2023
	group by 1
)
select ls.branch,
ls.revenue as last_year_revenue,
cs.revenue as current_year_revenue,
round((ls.revenue - cs.revenue)::numeric/ ls.revenue::numeric *100,2) as rev_dec_ratio
from revenue_2022 as ls
join revenue_2023 as cs
on ls.branch =cs.branch
where ls.revenue > cs.revenue
order by 4 Desc 
limit 5;
