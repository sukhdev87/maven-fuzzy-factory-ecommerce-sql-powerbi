Section 2 — Conversion & Funnel



select * from [dbo].[website_sessions]

--we have duplicate_website_session_id in orders
select [website_session_id] ,count([website_session_id]) from [dbo].[orders]
group by  [website_session_id]
having count([website_session_id]) > 1


--1.Analyzed website conversion performance by measuring the 
--percentage of sessions that resulted in a completed order.
select 
count(s.[website_session_id])as total_session, 
count(o.[website_session_id]) as total_orders,
concat(cast(count(o.[website_session_id]) * 100.0 / count(s.[website_session_id])as decimal(10,2)),'%')
as conversion_rate
from [dbo].[website_sessions]  s
left join [dbo].[orders] o
on s.[website_session_id] = o.[website_session_id]

output 
--Identified a 6.83% Session-to-Order Conversion Rate,
--with 32,313 orders generated from 472,871 website sessions.


--2.Which UTM source and UTM campaign combination generated the highest 
--Session-to-Order Conversion Rate?


select * ,sum(total_session) over(partition by utm_source_cl) as utm_source_ts ,
sum(total_orders) over(partition by utm_source_cl) as utm_source_to,

concat(cast((sum(total_orders) over(partition by utm_source_cl) *100.0/
sum(total_session) over(partition by utm_source_cl))as decimal(10,2)),'%') as conversion_rate_utm_source
from (
select 
case 
when [utm_source] ='NULL' then 'organic'
else [utm_source]
end utm_source_cl,
case 
when [utm_campaign] ='NULL' then 'organic'
else [utm_campaign]
end utm_campaign_cl,
count(s.[website_session_id])as total_session, 
count(o.[website_session_id]) as total_orders,
concat(cast(count(o.[website_session_id]) *100.0 / 
count(s.[website_session_id])as decimal(10,2)),'%') as conversion_rate
from [dbo].[website_sessions] as s
left join [dbo].[orders] as o
on  s.[website_session_id] = o.[website_session_id]
group by [utm_source], [utm_campaign]
)t

The bsearch–brand campaign delivered the highest Session-to-Order Conversion Rate at 8%, 
outperforming all other traffic source and campaign combinations.

Although bsearch–brand achieved the highest conversion rate (8%), 
gsearch–nonbrand generated the highest order volume (18,822 orders) 
due to significantly higher traffic.