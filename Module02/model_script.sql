--SHIPPING

--creating a table
drop table if exists shipping_dim;
CREATE TABLE shipping_dim
(
 ship_id      serial NOT NULL,
 shipping_mode varchar(25) NOT NULL,
 CONSTRAINT PK_shipping_dim PRIMARY KEY ( ship_id )
);

--deleting rows
truncate table shipping_dim;

--generating ship_id and inserting ship_mode from orders
insert into shipping_dim 
select 100+row_number() over(), ship_mode from (select distinct ship_mode from orders ) a;
--checking
select * from shipping_dim sd;

--CUSTOMER

--creating a table
drop table if exists customer_dim;
CREATE TABLE customer_dim
(
 cust_id       serial NOT NULL,
 customer_id   varchar(8) NOT NULL,
 customer_name varchar(50) NOT NULL,
 segment       varchar(50) NOT NULL,
 CONSTRAINT PK_customer_dim PRIMARY KEY ( cust_id )
);

--deleting rows
truncate table customer_dim;
--inserting
insert into customer_dim 
select 100+row_number() over(), customer_id, customer_name, segment
from (select distinct customer_id, customer_name, segment from orders) a;
--checking
select * from customer_dim cd;  

--GEO

--creating a table
drop table if exists geo_dim;
CREATE TABLE geo_dim
(
 geo_id      serial NOT NULL,
 country     varchar(50) NOT NULL,
 state       varchar(25) NOT NULL,
 city        varchar(50) NOT NULL,
 postal_code varchar(20) NULL,
 CONSTRAINT PK_geo_dim PRIMARY KEY ( geo_id )
);

--deleting rows
truncate table geo_dim;
--inserting
insert into geo_dim 
select 100+row_number() over(), country, state, city, postal_code
from (select distinct country, state, city, postal_code from orders ) a;
--checking
select * from geo_dim; 
--data quality check
select distinct country, city, state, postal_code from geo_dim
where country is null or city is null or postal_code is null;
-- City Burlington, Vermont doesn't have postal code
update geo_dim
set postal_code = '05401'
where city = 'Burlington'  and postal_code is null;

--also update source file
update orders
set postal_code = '05401'
where city = 'Burlington'  and postal_code is null;

select * from geo_dim
where city = 'Burlington'

--PRODUCT

--creating a table
drop table if exists product_dim;
CREATE TABLE product_dim
(
 prod_id      serial NOT NULL,
 category     varchar(50) NOT NULL,
 subcategory  varchar(50) NOT NULL,
 product_id   varchar(50) NOT NULL,
 product_name varchar(150) NOT NULL,
 CONSTRAINT PK_product_dim PRIMARY KEY ( prod_id )
);

--deleting rows
truncate table product_dim;
--inserting
insert into product_dim 
select 100+row_number() over(), category, subcategory, product_id, product_name
from (select distinct category, subcategory, product_id, product_name from orders) a;
--checking
select * from product_dim cd; 


--CALENDAR

--creating a table
drop table if exists calendar_dim;
CREATE TABLE calendar_dim
(
 date_id  serial NOT NULL,
 year     int NOT NULL,
 quarter  int NOT NULL,
 month    int NOT NULL,
 week     int NOT NULL,
 week_day varchar(15) NOT NULL,
 date     date NOT NULL,
 leap     varchar(20) NOT NULL,
 CONSTRAINT PK_calendar PRIMARY KEY ( date_id )
);
--deleting rows
truncate table calendar_dim;
--inserting
insert into calendar_dim 
select 
to_char(date,'yyyymmdd')::int as date_id,  
       extract('year' from date)::int as year,
       extract('quarter' from date)::int as quarter,
       extract('month' from date)::int as month,
       extract('week' from date)::int as week,
       to_char(date, 'dy') as week_day,
       date::date,
       CASE WHEN extract('month' from date) = 1 and extract('day' from date) = 1 and 
       extract('day' from (date + interval '2 month - 1 day')) = 29 THEN true
            ELSE false
       end as leap
  from generate_series(date '2016-01-01',
                       date '2030-01-01',
                       interval '1 day')
       as t(date);
--checking
select * from calendar_dim; 

/*
--MANAGERS

--creating a table
drop table if exists managers_dim;
CREATE TABLE managers_dim
(
 manager_id   integer NOT NULL,
 manager_name varchar(50) NOT NULL,
 region       varchar(50) NOT NULL,
 CONSTRAINT PK_managers_dim PRIMARY KEY ( manager_id )
);
--deleting rows
truncate table managers_dim;
--inserting
insert into managers_dim 
select 100+row_number() over(), manager_name, region  
from (select distinct person as manager_name, region from orders ) a;
--checking
select * from managers_dim; */

--METRICS

--creating a table
drop table if exists sales_fact;
CREATE TABLE sales_fact
(
 sales_id      serial NOT NULL,
 cust_id integer NOT NULL,
 order_date_id integer NOT NULL,
 ship_date_id integer NOT NULL,
 prod_id  integer NOT NULL,
 ship_id     integer NOT NULL,
 geo_id      integer NOT NULL,
 order_id    varchar(25) NOT NULL,
 sales       numeric(9,4) NOT NULL,
 profit      numeric(21,16) NOT NULL,
 quantity    int4 NOT NULL,
 discount    numeric(4,2) NOT NULL,
 CONSTRAINT PK_sales_fact PRIMARY KEY ( sales_id )
);

select * from sales_fact;

--inserting
insert into sales_fact 
select
	 100+row_number() over() as sales_id
	 ,cust_id
	 ,to_char(order_date,'yyyymmdd')::int as  order_date_id
	 ,to_char(ship_date,'yyyymmdd')::int as  ship_date_id
	 ,p.prod_id
	 ,s.ship_id
	 ,geo_id
	 ,o.order_id
	 ,sales
	 ,profit
     ,quantity
	 ,discount
from orders o 
inner join shipping_dim s on o.ship_mode = s.shipping_mode
inner join geo_dim g on (CASE WHEN o.postal_code is null THEN '0' ELSE o.postal_code::text  END) = g.postal_code and g.country=o.country and g.city = o.city and o.state = g.state --City Burlington doesn't have postal code
inner join product_dim p on o.category=p.category and o.subcategory=p.subcategory and o.product_id=p.product_id and o.product_name = p.product_name
inner join customer_dim cd on cd.customer_id=o.customer_id and cd.customer_name=o.customer_name and cd.segment=o.segment;

select count(*) from sales_fact sf
inner join shipping_dim s on sf.ship_id=s.ship_id
inner join geo_dim g on sf.geo_id=g.geo_id
inner join product_dim p on sf.prod_id=p.prod_id
inner join customer_dim cd on sf.cust_id=cd.cust_id;
 