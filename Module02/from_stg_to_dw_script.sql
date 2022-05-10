create schema dw;
----------------------------------------------------
--SHIPPING

--creating a table
drop table if exists dw.shipping_dim ;
CREATE TABLE dw.shipping_dim
(
 ship_id       integer NOT NULL,
 shipping_mode varchar(25) NOT NULL,
 CONSTRAINT PK_shipping_dim PRIMARY KEY ( ship_id )
);


--deleting rows
truncate table dw.shipping_dim;

--generating ship_id and inserting ship_mode from orders
insert into dw.shipping_dim 
select 100+row_number() over(), ship_mode 
from (select distinct ship_mode from stg.orders ) a;
--checking
select * from dw.shipping_dim sd; 

----------------------------------------------------
--CUSTOMER

drop table if exists dw.customer_dim ;
CREATE TABLE dw.customer_dim
(
cust_id integer NOT NULL,
customer_id   varchar(15) NOT NULL, --id can't be NULL
 customer_name varchar(25) NOT NULL,
 segment      varchar(25) NOT NULL,
 CONSTRAINT PK_customer_dim PRIMARY KEY ( cust_id )
);

--deleting rows
truncate table dw.customer_dim;
--inserting
insert into dw.customer_dim 
select 100+row_number() over(), customer_id, customer_name, segment 
from (select distinct customer_id, customer_name, segment from stg.orders ) a;
--checking
select * from dw.customer_dim cd; 

----------------------------------------------------
--GEOGRAPHY

drop table if exists dw.geo_dim ;
CREATE TABLE dw.geo_dim
(
 geo_id      integer NOT NULL,
 country     varchar(40) NOT NULL,
 city        varchar(30) NOT NULL,
 state       varchar(40) NOT NULL,
 postal_code varchar(10) NULL,       --can't be integer, we lost first 0
 state_rus	 varchar(24) NOT NULL,
 CONSTRAINT PK_geo_dim PRIMARY KEY ( geo_id )
);

--deleting rows
truncate table dw.geo_dim;
--generating geo_id and inserting rows from orders
insert into dw.geo_dim 
select 100+row_number() over(), country, city, state, postal_code, state_rus
from (select distinct country, city, o.state, postal_code, state_rus from stg.orders o
	LEFT JOIN lib.state_translation st ON st.state=o.state
	) a;
--data quality check
select * from dw.geo_dim
select distinct country, city, state, postal_code,state_rus from dw.geo_dim
where country is null or city is null or postal_code is null;

-- City Burlington, Vermont doesn't have postal code
update dw.geo_dim
set postal_code = '05401'
where city = 'Burlington'  and postal_code is null;

--also update source file
update stg.orders
set postal_code = '05401'
where city = 'Burlington'  and postal_code is null;


select * from dw.geo_dim
where city = 'Burlington'

----------------------------------------------------
--PRODUCT

--creating a table
drop table if exists dw.product_dim ;
CREATE TABLE dw.product_dim
(
 prod_id   integer NOT NULL, --we created surrogated key
 product_id   varchar(50) NOT NULL,  --exist in ORDERS table
 product_name varchar(150) NOT NULL,
 category     varchar(50) NOT NULL,
 sub_category varchar(50) NOT NULL,
 CONSTRAINT PK_product_dim PRIMARY KEY ( prod_id )
);

--deleting rows
truncate table dw.product_dim ;
--
insert into dw.product_dim 
select 100+row_number() over () as prod_id ,product_id, product_name, category, subcategory 
from (select distinct product_id, product_name, category, subcategory from stg.orders ) a;
--checking
select * from dw.product_dim cd; 

----------------------------------------------------
--CALENDAR use function instead 
-- examplehttps://tapoueh.org/blog/2017/06/postgresql-and-the-calendar/

--creating a table
drop table if exists dw.calendar_dim ;
CREATE TABLE dw.calendar_dim
(
dateid serial  NOT NULL,
year        int NOT NULL,
quarter     int NOT NULL,
month       int NOT NULL,
week        int NOT NULL,
date        date NOT NULL,
week_day    varchar(15) NOT NULL,
leap  varchar(20) NOT NULL,
CONSTRAINT PK_calendar_dim PRIMARY KEY ( dateid )
);

--deleting rows
truncate table dw.calendar_dim;
--
insert into dw.calendar_dim 
select 
to_char(date,'yyyymmdd')::int as date_id,  
       extract('year' from date)::int as year,
       extract('quarter' from date)::int as quarter,
       extract('month' from date)::int as month,
       extract('week' from date)::int as week,
       date::date,
       to_char(date, 'dy') as week_day,
       extract('day' from
               (date + interval '2 month - 1 day')
              ) = 29
       as leap
  from generate_series(date '2000-01-01',
                       date '2030-01-01',
                       interval '1 day')
       as t(date);
--checking
select * from dw.calendar_dim; 

----------------------------------------------------
--RETURNS

--creating a table
drop table if exists dw.returns_dim ;
--
CREATE TABLE dw.returns_dim
(
 ret_id   integer NOT NULL,
 returned varchar(10) NOT NULL,
 order_id varchar(25) NOT NULL,
 CONSTRAINT PK_returns_dim PRIMARY KEY ( ret_id )
);
--deleting rows
truncate table dw.returns_dim;
--
insert into dw.returns_dim 
select 100+row_number() over () as ret_id ,returned , order_id 
from (select DISTINCT returned, order_id from stg.returns ) a;
--checking
select * from dw.returns_dim; 

----------------------------------------------------
--MANAGERS

--creating a table
drop table if exists dw.managers_dim ;
--
CREATE TABLE dw.managers_dim
(
 manager_id   integer NOT NULL,
 manager_name varchar(50) NOT NULL,
 region       varchar(50) NOT NULL,
 CONSTRAINT PK_managers_dim PRIMARY KEY ( manager_id )
);
--deleting rows
truncate table dw.managers_dim;
--
insert into dw.managers_dim 
select 100+row_number() over () as manager_id ,person , region 
from (select DISTINCT person, region from stg.people ) a;
--checking
select * from dw.managers_dim; 

----------------------------------------------------
--METRICS

--creating a table
drop table if exists dw.sales_fact ;
--
CREATE TABLE dw.sales_fact
(
 sales_id      serial NOT NULL,
 ret_id        integer,
 manager_id    integer NOT NULL,
 ship_id       integer NOT NULL,
 cust_id       integer NOT NULL,
 geo_id        integer NOT NULL,
 prod_id       integer NOT NULL,
 sales         numeric(9,4) NOT NULL,
 discount      numeric(4,2) NOT NULL,
 profit        numeric(9,4) NOT NULL,
 quantity      int4 NOT NULL,
 order_id      varchar(25) NOT NULL,
 order_date_id integer NOT NULL,
 ship_date_id  integer NOT NULL,
 CONSTRAINT PK_sales_fact PRIMARY KEY ( sales_id )
);
--deleting rows
truncate table dw.sales_fact;
--
insert into dw.sales_fact 
select
	 100+row_number() over() as sales_id
	 ,r.ret_id
	 ,m.manager_id
	 ,s.ship_id
	 ,cd.cust_id
	 ,g.geo_id
	 ,p.prod_id
	 ,sales
	 ,discount
	 ,profit
	 ,quantity
	 ,o.order_id
	 ,to_char(order_date,'yyyymmdd')::int as  order_date_id
	 ,to_char(ship_date,'yyyymmdd')::int as  ship_date_id
from stg.orders o 
inner join dw.shipping_dim s on o.ship_mode = s.shipping_mode
inner join dw.geo_dim g on o.postal_code = g.postal_code and g.country=o.country and g.city = o.city and o.state = g.state --City Burlington doesn't have postal code
inner join dw.product_dim p on o.product_name = p.product_name and o.subcategory=p.sub_category and o.category=p.category and o.product_id=p.product_id 
inner join dw.customer_dim cd on cd.customer_id=o.customer_id and cd.customer_name=o.customer_name and o.segment=cd.segment
LEFT join dw.returns_dim r ON o.order_id = r.order_id
LEFT JOIN dw.managers_dim m ON o.region = m.region
;
--checking
select * from dw.sales_fact; 
select count(*) from dw.sales_fact; 