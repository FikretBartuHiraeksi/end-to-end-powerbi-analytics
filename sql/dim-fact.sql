create schema if not exists vaeolara;

-- DIM CUSTOMER --
create table vaeolara.dim_customer(
	customer_key int generated always as identity primary key,
	customer_id varchar(10) unique not null,
	first_name varchar(50),
	last_name varchar(50),
	gender varchar(20),
	age_bracket varchar(10),
	state varchar(50),
	city varchar(50),
	signup_date date,
	acquisition_channel varchar(30),
	loyalty_tier varchar(30),
	lifetime_orders int);
	
insert into vaeolara.dim_customer(customer_id, first_name, last_name, gender, age_bracket, state, city, signup_date, acquisition_channel, loyalty_tier, lifetime_orders)
select customer_id, first_name, last_name, gender, age_bracket, state, city, signup_date, acquisition_channel, loyalty_tier, lifetime_orders
from public.customers;


-- DIM PRODUCT -- 
create table vaeolara.dim_product(
	product_key int generated always as identity primary key,
	product_id varchar(10) unique not null,
	product_name varchar(100),
	brand varchar(50),
	category varchar(30),
	subcategory varchar(30),
	unit_cost numeric(10, 2),
	unit_price numeric(10, 2),
	launch_date date, 
	is_active boolean);

insert into vaeolara.dim_product(product_id, product_name, brand, category, subcategory, unit_cost, unit_price, launch_date, is_active)
select product_id, product_name, brand, category, subcategory, unit_cost, unit_price, launch_date, is_active
from public.products;


-- DIM STORE -- 
create table vaeolara.dim_store(
	store_key int generated always as identity primary key,
	store_id varchar(10) unique not null,
	store_name varchar(100),
	city varchar(50),
	state varchar(50),
	region varchar(20),
	store_type varchar(20),
	open_date date);

insert into vaeolara.dim_store(store_id, store_name, city, state, region, store_type, open_date)
select store_id, store_name, city, state, region, store_type, open_date
from public.stores;

insert into vaeolara.dim_store (store_id, store_name, city, state, region, store_type, open_date)
values ('Online', 'Online Store', null, null, null, 'Online', null);


-- DIM CAMPAIGN -- 
create table vaeolara.dim_campaign(
	campaign_key int generated always as identity primary key,
	campaign_id varchar(15) unique not null,
	campaign_name varchar(100),
	campaign_type varchar(20),
	start_date date,
	end_date date,
	discount_pct numeric(5, 2),
	channel_scope varchar(20),
	target_category varchar(30));

insert into vaeolara.dim_campaign(campaign_id, campaign_name, campaign_type, start_date, end_date, discount_pct, channel_scope, target_category)
select campaign_id, campaign_name, campaign_type, start_date, end_date, discount_pct, channel_scope, target_category
from public.campaigns;

insert into vaeolara.dim_campaign (campaign_id, campaign_name, campaign_type, discount_pct)
values ('No Campaign', 'No Campaign', 'None', 0);


-- FACT SALES -- 
create table vaeolara.fact_sales(
	order_item_id varchar(15) primary key,
	order_id varchar(10) not null,
	order_date date not null,
	customer_key int references vaeolara.dim_customer(customer_key),
	product_key int references vaeolara.dim_product(product_key),
	store_key int references vaeolara.dim_store(store_key),
	campaign_key int references vaeolara.dim_campaign(campaign_key),
	channel varchar(20),
	payment_method varchar(30),
	quantity int,
	unit_price numeric (10, 2),
	discount_pct numeric (5, 2),
	line_total numeric (10, 2));

insert into vaeolara.fact_sales(order_item_id, order_id, order_date, customer_key, product_key, store_key, campaign_key, channel, payment_method, quantity, unit_price, discount_pct, line_total)
select oi.order_item_id, oi.order_id, o.order_date, dc.customer_key, dp.product_key, ds.store_key, dcm.campaign_key, o.channel, o.payment_method, oi.quantity, oi.unit_price, oi.discount_pct, oi.line_total
from public.order_items oi 
join public.orders o on oi.order_id = o.order_id
join vaeolara.dim_customer dc on o.customer_id = dc.customer_id
join vaeolara.dim_product dp on oi.product_id = dp.product_id 
join vaeolara.dim_store ds on o.store_id = ds.store_id 
join vaeolara.dim_campaign dcm on o.campaign_id = dcm.campaign_id;

