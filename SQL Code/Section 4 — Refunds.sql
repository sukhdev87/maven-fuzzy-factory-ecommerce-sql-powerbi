
--What percentage of purchased items were returned by customers?
select 
count(r.[order_item_id]) as refund_items,
count(i.[order_item_id]) as total_items ,
concat(cast(count(r.[order_item_id]) * 100.0 / count(i.[order_item_id]) as decimal(10,2)),' ','%')
as return_rate
from [dbo].[order_items] i left join 

[dbo].[order_item_refunds] r
on i.[order_item_id] = r.[order_item_id]

--Out of 40,025 items sold, 1,731 items were returned, resulting in an overall Return Rate of 4.32%

--retrun rate based on  orders 
select 
count(r.order_item_id) as refund_items,
count(o.[order_id]) as total_order ,
concat(
    cast(
        count(r.order_item_id) * 100.0 / count(o.[order_id])
        as decimal(10,2)
    ),
' %') as return_rate
from [dbo].[orders] o
left join order_item_refunds r
on o.order_id = r.order_id


-- 5.36


-- Which product had the highest return rate, and how did return rates vary across different products?

select p.[product_name], count([order_item_refund_id]) as product_returns,
count(*) as products_orders,
concat(cast(count([order_item_refund_id]) *100.0 / count(*) as decimal(10,2)),' ','%') as product_return_rate
from [dbo].[order_items] i left join 
[dbo].[products] p
on i.product_id = p.product_id
left join [dbo].[order_item_refunds] r
on i.[order_item_id] = r.[order_item_id]

group by [product_name]
order by product_returns DESC


--The Birthday SugarPanda had the highest return rate at 6.04%, despite having only 4,985 orders, making it the product with the highest proportion of customer returns.
--The Original Mr. Fuzzy recorded the highest number of returns (1,237 returns) and the second-highest return rate (5.11%).
--Although The Original Mr. Fuzzy received approximately 19,000 more orders than the second-best-selling product, it still maintained a relatively high return rate, 
--suggesting that high sales volume did not necessarily translate into lower returns.
--The Forever Love Bear had a moderate return rate of 2.23%, significantly lower than the top two products.
--The Hudson River Mini Bear had the lowest return rate at 1.28%, indicating the strongest product retention among customers.


