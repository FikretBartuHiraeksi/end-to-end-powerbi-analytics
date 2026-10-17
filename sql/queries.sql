set search_path to vaeolara;



-- Customer LTV Value by Acquisition Channel and  Loyalty Tier--
with customer_ltv as(
	select
		dc.customer_key,
		dc.loyalty_tier,
		dc.acquisition_channel,
		sum(fs.line_total) as total_customer_spend
	from dim_customer dc 
	left join fact_sales fs on dc.customer_key = fs.customer_key 
	group by 
		dc.customer_key,
		dc.loyalty_tier,
		dc.acquisition_channel)
		
select
	loyalty_tier,
	acquisition_channel,
	count(customer_key) as total_customers,
	round(avg(total_customer_spend), 2) as avg_customer_ltv
from customer_ltv
group by 1, 2
order by 4 desc;



-- Products With The Best Profit Margin -- 
select
	dp.product_id,
	dp.product_name,
	dp.brand,
	sum(fs.quantity) as total_amount_sold,
	round(sum(fs.line_total - (fs.quantity * dp.unit_cost)), 2) as total_profit,
	round((sum(fs.line_total - (fs.quantity * dp.unit_cost)) / nullif(sum(fs.line_total), 0)) * 100, 2) as profit_margin 
from dim_product dp 
join fact_sales fs on fs.product_key = dp.product_key
group by 1, 2, 3
order by 6 desc
limit 10;



-- Best Stores of Every Region --
with stores as(
	select
		ds.region,
		ds.store_id,
		ds.store_name,
		ds.store_type,
		count(distinct fs.order_id) as total_orders,
		round(sum(fs.line_total), 2) as total_revenue,
		round(sum(fs.line_total), 2) / nullif(count(distinct fs.order_id), 0) as aov,
		row_number() over(partition by ds.region order by sum(fs.line_total) desc) as region_rnk
	from dim_store ds
	join fact_sales fs on ds.store_key = fs.store_key
	where ds.store_name != 'Online Store'
	group by 1, 2, 3, 4)
	
select
	region,
	store_name,
	store_type,
	total_orders,
	total_revenue,
	aov as average_order_value
from stores 
where region_rnk = 1
order by total_revenue desc;



-- Campaign Performance and Top-Selling Product per Campaign --
with campaign_totals as (
    select
        c.campaign_name,
        count(distinct fs.customer_key) as unique_customers,
        count(distinct fs.order_id) as total_orders,
        sum(fs.quantity) as total_sold,
        round(sum(fs.line_total), 2) as total_revenue
    from fact_sales fs
    join dim_campaign c on fs.campaign_key = c.campaign_key
    group by c.campaign_name
),
top_products as (
    select
        c.campaign_name,
        dp.product_key,
        dp.product_name,
        dp.brand,
        row_number() over(partition by c.campaign_name order by sum(fs.quantity) desc, dp.product_key) as rnk
    from fact_sales fs
    join dim_campaign c on fs.campaign_key = c.campaign_key
    join dim_product dp on fs.product_key = dp.product_key
    group by c.campaign_name, dp.product_key, dp.product_name, dp.brand
)
select
    ct.campaign_name,
    tp.product_name || ' (' || tp.brand || ')' as top_selling_product,
    ct.unique_customers,
    ct.total_orders,
    ct.total_sold sold,
    ct.total_revenue
from campaign_totals ct
join top_products tp on ct.campaign_name = tp.campaign_name
where tp.rnk = 1 and ct.campaign_name != 'No Campaign'
order by ct.total_revenue desc;



-- Acquisition Channel Performance -- 
select
	dc.acquisition_channel,
	count(distinct fs.customer_key) as unique_customers,
	count(distinct fs.order_id) as total_orders,
	sum(fs.quantity) as total_sold,
	round(sum(fs.line_total), 2) as total_revenue
from fact_sales fs 
join dim_customer dc on fs.customer_key = dc.customer_key
group by 1 
order by 2 desc;



-- Online vs In Store -- 
select 
	fs.channel,
	count(distinct fs.order_id) as total_orders,
	sum(fs.quantity) as total_units,
	round(sum(fs.line_total), 2) as total_revenue,
	round(sum(fs.line_total) / count(distinct fs.order_id), 2) as avg_order_value 
from fact_sales fs  
group by 1 
order by 4 desc;



-- Loyalty Tier Performance -- 
select
    dc.loyalty_tier,
    count(distinct dc.customer_key) as unique_customers,
    sum(fs.quantity) as total_units,
    round(sum(fs.line_total), 2) as total_revenue,
    round(sum(fs.line_total) / count(distinct fs.order_id), 2) as avg_order_value,
    round(sum(fs.line_total) / count(distinct dc.customer_key), 2) as avg_revenue_per_customer,
    round(count(distinct fs.order_id)::numeric / count(distinct dc.customer_key), 2) as avg_orders_per_customer
from dim_customer dc
left join fact_sales fs on dc.customer_key = fs.customer_key
group by 1
order by 6 desc; 