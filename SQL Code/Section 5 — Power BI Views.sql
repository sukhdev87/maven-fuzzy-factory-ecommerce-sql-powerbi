--power views 

CREATE VIEW vw_traffic AS
SELECT 
    [website_session_id],
    [created_at],
    [user_id],
    [is_repeat_session],
    [device_type],
    CASE WHEN [utm_source] = 'NULL' THEN 'organic' 
         ELSE [utm_source] END AS utm_source,
    CASE WHEN [utm_campaign] = 'NULL' THEN 'organic' 
         ELSE [utm_campaign] END AS utm_campaign,
    CASE WHEN [utm_content] = 'NULL' THEN 'organic' 
         ELSE [utm_content] END AS utm_content
FROM [dbo].[website_sessions]

2nd 

CREATE VIEW vw_orders_products AS
SELECT 
    o.[order_id],
    o.[created_at],
    o.[website_session_id],
    o.[user_id],
    o.[items_purchased],
    o.[price_usd] AS order_price,
    o.[cogs_usd] AS order_cogs,
    oi.[order_item_id],
    oi.[product_id],
    oi.[is_primary_item],
    oi.[price_usd] AS item_price,
    oi.[cogs_usd] AS item_cogs,
    p.[product_name]
FROM [dbo].[orders] o
LEFT JOIN [dbo].[order_items] oi
ON o.[order_id] = oi.[order_id]
LEFT JOIN [dbo].[products] p
ON oi.[product_id] = p.[product_id]

3rd

CREATE VIEW vw_refunds AS
SELECT
    [order_item_refund_id],
    [order_item_id],
    [order_id],
    [refund_amount_usd]
FROM [dbo].[order_item_refunds]


--NOte we have duplicates in order_id so for calculate total orders using distinct count and for other uses preffer order_item table 