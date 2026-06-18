create database new_port
use new_port

-- gerenal check for null and columns count 
SELECT COUNT(*) FROM orders
SELECT COUNT(*) FROM website_sessions
SELECT COUNT(*) FROM order_items
SELECT COUNT(*) FROM order_item_refunds

SELECT 
    SUM(CASE WHEN price_usd IS NULL THEN 1 ELSE 0 END) AS null_price,
    SUM(CASE WHEN order_id IS NULL THEN 1 ELSE 0 END) AS null_order_id,
    SUM(CASE WHEN website_session_id IS NULL THEN 1 ELSE 0 END) AS null_session
FROM orders


--Section 1 — Traffic & Sessions
--null checking 

select * from [dbo].[website_sessions]
where 
[utm_content] = 'NULL'

-- this have null but sql fail to detect

--Analyzed website traffic to measure total sessions, repeat sessions, and customer return rate.

select *, sum(sessions)  over() as total_sessions ,
concat(sessions *100 / sum(sessions)  over(),'%') as percentage
from (
select  [is_repeat_session] ,count([is_repeat_session]) as sessions from 
[dbo].[website_sessions]
group by [is_repeat_session])t

-- output 

is_repeat_session	sessions	total_sessions	percentage
1	78553	472871	16%
0	394318	472871	83%

--only 16% repeat customers  out of 100%

--2. Identified the UTM source that generated the highest volume of website traffic
--and calculated its contribution percentage to total sessions.

select * , sum(customers) over() as total_customers ,
 concat(customers* 100 / sum(customers) over() , '%')as percentage
from (
select count(*) as customers  ,
case 
	when [utm_source] = 'NULL' then 'organic'
	else [utm_source]
	end utm_source_clean
	from [dbo].[website_sessions]
group by [utm_source])t

order by customers DESC

here output 
--customers	utm_source_clean	total_customers	percentage
316035	gsearch	472871	66%
83328	organic	472871	17%
62823	bsearch	472871	13%
10685	socialbook	472871	2%

--[gsearch] was the leading traffic acquisition channel, 
--contributing 66% of total website sessions.
--our repeation and organic is almost same 17 and 16 it may be becuase we heavly depend 
--on gsearch 

--3.Identified the dominant device type driving website traffic and measured its share of total sessions.

select *,sum(customers) over() as total_customers,
concat(customers *100 / sum(customers) over(),'%') as percentage 
from(
select [device_type],count(*) as customers  from [dbo].[website_sessions]
group by [device_type]) t

output 
--we have more desktop(327027)(69%) users than mobile(145844)30% 

--4.Determined which device type had the highest proportion of returning customers 
--and quantified its percentage contribution.

select *,sum(customers)over(partition by [device_type]) as total_customer_per_device,
concat(customers*100 / sum(customers)over(partition by [device_type]),'%') as percentage
from(
select [is_repeat_session],[device_type],count(*) as customers  from [dbo].[website_sessions]
group by [device_type],[is_repeat_session])t

-- depite having more customers desktop(15%) have less percentage of return customers 
-- than mobile users (19%)

--5.Which UTM campaign generated the highest website traffic, 
--and what percentage of total tracked campaign sessions did it contribute


select * , sum(customers) over() as total_customers,
concat(customers *100 / sum(customers) over(), '%') as percentage
from (
select 
case 
when  [utm_campaign] = 'NULL' then 'Organic / Direct'
else [utm_campaign]
end utm_campaign_cl
,count(*) as customers 
from [dbo].[website_sessions] 

group by [utm_campaign])t
order by customers DESC

--The nonbrand campaign was the most effective traffic-driving campaign, 
--generating 337,615 sessions, 
--which contributed approximately 86.7% of all tracked campaign sessions.