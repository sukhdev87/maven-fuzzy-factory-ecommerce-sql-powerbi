Section 3 — Revenue & Products


-- understanding the tables 


select count(*) from [dbo].[order_item_refunds]


select * from [dbo].[order_items]

total column 40025


select * from [dbo].[orders]

total column 32313


select count(*) from [dbo].[order_item_refunds]

total column 1731

SELECT 
    o.order_id,
    o.items_purchased,
    COUNT(oi.order_item_id) as items_in_order_items
FROM [dbo].[orders] o
LEFT JOIN [dbo].[order_items] oi
ON o.order_id = oi.order_id
GROUP BY o.order_id, o.items_purchased
HAVING COUNT(oi.order_item_id) > 1
order by o.order_id

select sum([price_usd]) from [dbo].[orders]

select sum([price_usd]) from [dbo].[order_items]

SELECT
    COUNT(*) AS total_refund_rows,
    COUNT(DISTINCT order_id) AS distinct_refund_orders
FROM order_item_refunds;


--1. Total revenue , Total_profit , Net_revenue, Net_profit 

WITH refunds AS (
    SELECT
        order_id,
        SUM(refund_amount_usd) AS total_refund
    FROM order_item_refunds
    GROUP BY order_id
)

SELECT
    CAST(SUM(o.price_usd) AS DECIMAL(10,2)) AS Gross_Revenue,
    CAST(SUM(o.price_usd) - SUM(o.cogs_usd) AS DECIMAL(10,2)) AS Gross_Profit,
    CAST(SUM(o.price_usd) - SUM(ISNULL(r.total_refund,0)) AS DECIMAL(10,2)) AS Net_Revenue,
    CAST(
        SUM(o.price_usd) - SUM(o.cogs_usd) - SUM(ISNULL(r.total_refund,0))
        AS DECIMAL(10,2)
    ) AS Net_Profit
FROM orders o
LEFT JOIN refunds r
ON o.order_id = r.order_id;

Gross_Revenue	Gross_Profit	Net_Revenue	Net_Profit
1938509.75	     1216139.50	    1853171.06	1130800.81


--Which product generated the highest sales volume, 
--and what percentage of total sales did it contribute?

select * , sum(orders) over() as total_orders  ,
concat(cast(orders*100.0 / sum(orders)  over() as decimal(10,2)),'%') as percentage  
from(

select [product_name],count(o.[product_id]) as orders  from [dbo].[order_items]o
left join [dbo].[products] p
on o.product_id = p.product_id
group by [product_name]
)t

--The Original Mr. Fuzzy was the most popular product, 
--purchased by 24,226 customers, representing 60.53% of all customers.


--What is the Average Order Value (AOV) generated per customer order?
SELECT
Concat(CAST(AVG(price_usd) AS DECIMAL(10,2)),' ','$') AS Average_Order_Value
FROM orders;

--The business achieved an Average Order Value (AOV) of $59.99, 
--indicating that customers spent an average of $59.99 per order.

--How are multi-item orders distributed across products,
--and which product contributes the largest share?


select *,sum(Multi_item_orders) over() as total_Multi_item_orders ,
concat(cast((Multi_item_orders * 100.0 / sum(Multi_item_orders) over()) as decimal(10,2)),'%')
as percentage_share
from(
select [product_name]
,count(*) as Multi_item_orders from [dbo].[orders] o
JOIN products p
ON o.primary_product_id = p.product_id
where [items_purchased] > 1
group by [product_name])t
order by Multi_item_orders DESC

--The Original Mr. Fuzzy dominated multi-item purchases, 
--appearing in 5,757 multi-item orders and contributing 74.65% of all multi-item orders.

--What are the year-over-year revenue trends, 
--and which year contributed the largest share of total revenue?

select *,
cast(sum( yearly_revenue) 
over(order by years ROWS BETWEEN UNBOUNDED PRECEDING AND CURRENT ROW)as decimal(10,2))
as running_total,
sum(yearly_revenue) over() as total_revenue,
concat(cast(yearly_revenue *100 / sum(yearly_revenue) over() as decimal(10,2)),'%') as 'contribution %'
from (
SELECT 
    YEAR(created_at) AS years,
    CAST(SUM(price_usd) AS DECIMAL(10,2)) AS yearly_revenue
FROM dbo.orders
GROUP BY YEAR(created_at))t

--Key Findings
--Analyzed annual revenue performance and calculated each year's contribution to total revenue of $1.94M.
--2014 was the strongest revenue year, generating $1.08M and contributing 55.49% of total revenue.
--2013 contributed 20.29% of total revenue, while 2015 contributed 17.56%.
--2012 contributed the smallest share (6.67%), though the dataset contains only 10 months of data for that year.
--Revenue accumulated to $1.94M by March 2015 based on the available dataset.

SELECT DISTINCT
       YEAR(created_at) AS year,
       MONTH(created_at) AS month
FROM dbo.orders
ORDER BY year, month;

--2012 contains data from March–December (10 months).
--2013 and 2014 contain complete 12-month data.
--2015 contains data from January–March (3 months).

--Which year and month generated the highest revenue, 
--and what percentage of total revenue did they contribute?

select * ,sum(yearly_and_monthly_revenue) over() as total_revenue_overall,
sum(yearly_and_monthly_revenue) over(order by years, months rows between UNBOUNDED PRECEDING  and current row)
as running_total_of_ymr,
concat(cast(yearly_and_monthly_revenue *100/ sum(yearly_and_monthly_revenue)over()as decimal(10,2)),' ','%')
as  'ym_contibution %',
sum(yearly_and_monthly_revenue) over(partition by years) as individual_year_months_revenue,
concat(cast(yearly_and_monthly_revenue *100/ sum(yearly_and_monthly_revenue)over(partition by years)as decimal(10,2)),' ','%')
as  'individual_year_month_contibution %'

from(

SELECT 
    YEAR(created_at) AS years,
	month([created_at]) as months,
    CAST(SUM(price_usd) AS DECIMAL(10,2)) AS 'yearly_and_monthly_revenue'

FROM dbo.orders
GROUP BY YEAR(created_at),month([created_at]))t

--Revenue showed a consistent upward trend from 2012 to 2014, with monthly revenue generally increasing over time.
--December 2014 was the highest-revenue month, generating $144,823.02 and contributing 7.47% of total company revenue.
--November and December were consistently among the strongest-performing months, indicating a potential holiday-season sales boost.
--2014 was the best-performing year, contributing 55.49% of total revenue.
--Revenue in Q1 2015 (January–March) was exceptionally strong, with January and February 2015 each contributing more than 6.5% of total revenue despite covering only three months of data.
--The cumulative revenue reached $1.94M by March 2015.

