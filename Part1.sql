--------------------------------------------------------------------------------------  QUERYING DATA --------------------------------------------  

--------------------------------------------------------------------------------------------- select -----------------------------------------
-- Fetch all columns from table customer
select * from customer;

--Fetch fullname and email of all the customers
select first_name||' '||last_name fullname,email
from customer;

-------------------------------------------------------------------------------------------- column alias -------------------------------------------------
-- Fetch first name and last name using alias surname for all the customers
select first_name, last_name Surname
from customer;

----------------------------------------------------------------------------------------------- order by ---------------------------------------------------------

--ORDER BY column_name [ASC | DESC] [NULLS FIRST | NULLS LAST]
-- Fetch first name and last name of all the customers and order them by first name in ascending order them last name in desending order
select first_name, last_name
from customer
order by first_name ,last_name desc

--Fetch customer details and order them by id in desending order
select * from customer 
order by customer_id desc;

-- NULLS FIRST and NULLS LAST in order by
create table demo( name varchar(10))
insert into demo values('Shiv'),(null),('Priya'),(null),('Ram');

select * from demo
order by name nulls last

----------------------------------------------------------------------------------- select distinct ---------------------------------------------------------
select distinct first_name from customer

----------------------------- FROM ------>  WHERE -----> GROUP BY -----> HAVING ----->  SELECT ------> DISTINCT -----> ORDER BY ----> LIMIT/FETCH

-------------------------------------------------------------------------------------- FILTERING DATA -----------------------------------------------------

------------------------------------------------------------------------------------------ where --------------------------------------------
-- Fetch name of customer whose last name ends with son 
select first_name,last_name 
from customer w
here last_name like '%son'

-- Fetch all customers whose last name are Gruber,Graves or Wright
select first_name,last_name
from customer
where last_name in ('Gruber','Graves','Wright');

-- Fetch all customers whose length of first name is between 3 to 6 (3 and 6 will be inclusive)
select first_name 
from customer
where length(first_name) between 3 and 6
order by length(first_name)

------------------------------------------------------------------------------------------ limit  ----------------------------------------------------------
-- limit n; gets n rows from table

-- Fetch top 3 actor names sorted by their firstname
select first_name from actor 
order by first_name 
limit 3

-- Fetch last 5 city names sorted by cityname
select city 
from city 
order by city desc
limit 5


-------------------------------------------------------------------------------------- offset ---------------------------------------------------------------------
--offset n; exclude n no. of rows

-- Retrive 4 films starting from the fourth one ordered by film_id
select film_id,title
from film
order by film_id
offset 3 limit 4

-------------------------------------------------------------------------------------- fetch -------------------------------------------------------------------------
-- Similar to limit but fetch should be prefered as it is comapatible with other db system
-- FETCH { FIRST | NEXT } [ row_count ] { ROW | ROWS } ONLY

-- fetch next five films after the first five films sorted by titles
select film_id,title
from film
order by title
offset 5 
fetch first 5 rows only

------------------------------------------------------------------------------------ in  --------------------------------------------------------------
-- Fetch rental information for customer where customerid not 1,2,3,5
select rental_id,rental_date,customer_id
from rental
where customer_id not in (1,2,3,5)
order by customer_id;

-------------------------------------------------------------------------- between ---------------------------------------------------------
-- fetch payment whose payment date is between 2007-02-07 and 2007-02-15
select payment_id,payment_date,amount
from payment
where payment_date between '2007-02-07' and '2007-02-15'
--------------------------------------------------------------------------- JOINS --------------------------------------------------------------

-- [INNER JOIN/JOIN] : FETCHES THOSE RECORDS WHICH ARE PRESENT IN BOTH THE TABLE i.e. ONLY COMMON RECORDS OF COMMON COLUMN
-- fetch employee name and department name they belong to  
select emp_name,dept_name
from employee e join department d 
on e.dept_id = d.dept_id;

--[LEFT JOIN] : FETHES COMMON RECORDS AND ALL RECORDS FROM LEFT TABLE. LEFT JOIN = INNER JOIN + REMAINING RECORDS FROM LEFT TABLE
-- fetch all employee names and their department name they belong to
select emp_name,dept_name
from employee e left join department d 
on e.dept_id = d.dept_id;

--[RIGHT JOIN] : FETHES COMMON RECORDS AND ALL RECORDS FROM RIGHT TABLE. RIGHT JOIN = INNER JOIN + REMAINING RECORDS FROM RIGHT TABLE
-- fetch all department names and employee name in them
select emp_name,dept_name
from employee e right join department d 
on e.dept_id = d.dept_id;

-- fetch all emp name,their manager,their dept and project they work on
select e.emp_name,d.dept_name,m.manager_name,p.project_name
from employee e left join department d
on e.dept_id=d.dept_id inner join manager m 
on m.manager_id = e.manager_id left join projects p
on e.emp_id=p.team_member_id

--[FULL JOIN] : INNER JOIN(MATCHING VALUES) + REMAINING RECORDS FROM LEFT AND RIGHT TABLE
select emp_name,dept_name
from employee e full join department d 
on e.dept_id = d.dept_id;

-- full outer join = full join
-- left outer join = left join		same meaning of all
-- right outer join = right join

-- [CROSS JOIN] : RETURNS CARTESIAN PRODUCT. NO NEED FOR JOIN CONDITION 
--  TABLE_1 = 6ROWS, TABLE_2= 4ROWS => OUTPUT TABLE= 6*4 = 24ROWS
-- Used when there is no common column between tables that needs to be joined.
-- Fetch employee name and their corresponding department name,also fetch their company name and company location
select emp_name,dept_name,company_name,location
from employee e
join department d on e.dept_id = d.dept_id
cross join company

--[NATURAL JOIN] : NATURAL JOIN WILL TRY TO DO AN INNER JOIN IF THERE ARE COLUMNS IN BOTH TABLE THAT SHARE SAME COLUMN NAME,
-- IF THERE ARE NO COLUMNS THAT SHARE SAME COLUMN NAME THEN CROSS JOIN WILL BE PERFORMED.
-- IF THERE ARE MORE THAN ONE COMMON COLUMN WITH SAME NAMES IN EACH OF THE TABLES THEN INNER JOIN WILL BE PERFORMED ON BOTH THE COLUMNS
-- NO NEED OF JOIN CONDITION
select emp_name,dept_name
from employee e NATURAL join department d  -- Here natural join is possible bcoz of common column name called dept_id

	-- lets change the column name
	alter table department rename column dept_id to id;
	
	-- now, as column of same column name does'nt exists,cross join will be performed
select emp_name,dept_name
from employee e NATURAL join department d

-- [SELF JOIN] : USED WHEN YOU TRY TO JOIN A TABLE WITH ITSELF. THERE IS NO KEYWORD CALLED 'SELF',YOU SIMPLE WRITE JOIN BUT USE SAME TABLE TWICE.
-- USED WHEN DETAILS YOU WANT TO FETCH ARE IN SAME COLUMN AND IN SAME TABLE.
-- Fetch child name and their age corresponding to their parent name and parent age
select child.name child_name, child.age child_age,parent.name parent_name,parent.age parent_name
from family as child 
join family as parent
on child.parent_id = parent.member_id

-------------------------------------------------------------------------- Group by And Having ----------------------------------------
-- fetch no. of students from each class
select sc.class_id,count(stu_id) no_of_stu
from stu_class sc
group by sc.class_id
order by class_id;

-- fetch students from a each class if no.of students in that class is more than 1
select sc.class_id,count(stu_id) no_of_stu
from stu_class sc
group by sc.class_id
having count(stu_id) >1
order by class_id;

-- parents with more than 1 kid in school
select par_id, count(*) no_of_kids
from stu_parent sp
group by(par_id)
having count(par_id) > 1
order by(par_id)
--------------------------------------------------------------------- Set Operations  ---------------------
----------------------------------------------------------------------- Union and Union All-------------------
select * from public.top_rated_films union select * from public.most_popular_films
select * from public.top_rated_films union All select * from public.most_popular_films
------------------------------------------------------------------ Except ----------------
select * from public.top_rated_films except select * from public.most_popular_films
------------------------------------------------------------------------ Intersect --------------
select * from public.top_rated_films intersect select * from public.most_popular_films

---------------------------------------------------------------------------------- Subquery -------------------------------------------------------
--fetch details of employee 
select *
from employee1 e
where (dept_name,salary) in (select dept_name,max(salary)
						     from employee1 e
						     group by dept_name)
-------------------------------------------------------------------------------------  Any --------------------------------------------------
select dept_name, emp_name,salary from employee1
where salary > any (select avg(salary) from employee1 group by dept_name)
-------------------------------------------------------------------------------------  All  ----------------------------------------------------------------------
select film_id, title,length
FROM film WHERE length > ALL (
            SELECT ROUND(AVG (length),2)
            FROM film
            GROUP BY rating)
ORDER BY length;
------------------------------------------------------------------------------------- exists ------------------------------------------------
select * 
from department1 d
where not exists (select 1 from employee1 e where e.dept_name = d.dept_name); 

---------------------------------------------------------------------- Modifying Data --------------------------------------
----------------------------------------------------------------------- Insert --------------------
insert into demo values('Shiv'),(null),('Priya'),(null),('Ram');
--------------------------------------------------------------------- Update -----------------------
update accounts set balance=4000 where name='Aakash' 
----------------------------------------------------------------------------- Update Join --------------------
update category set name ='Documentary_ '
from film_category
where film_id =1 and category.category_id=film_category.category_id
--------------------------------------------------------------------------------------- Delete -----------------------
delete from accounts where id =4 returning *;
------------------------------------------------------------------------------- Delete Join --------------------
delete 
from category
using film_category
where category.category_id=film_category.category_id and  film_id =1
----------------------------------------------------------------------------------------- Upsert -----------------------------
select * from customer1
insert into customer1(name,email)values('Microsoft','outlook.com')
on conflict (name)
do 
update set email=excluded.email||';'||customer1.email;
-------------------------------------------------------------------------------------------- CTE --------------------------
with avg_salary (avg_sal) as   -- avg_sal is the column in avg_salary table ,u need to mention the column u need as output
	(select avg(salary) from employee)
select * 
from employee e, avg_salary av -- avg_salary = a temp table(present only till executionof this query) ,av = alias of this table
where e.salary > av.avg_sal;
---------------------------------------------------------------------------------------  Recursive Query --------------------------

with recursive subordinates as(
select e_id,manager_id,fname from employee1 where e_id=2
union
select e.e_id,e.manager_id,e.fname from employee1 e 
inner join subordinates s on s.e_id=e.manager_id)
select * from subordinates;
----------------------------------------------------------------------------------  Transactions -------------------------------------------------------
DROP TABLE IF EXISTS accounts;
CREATE TABLE accounts (
    id INT GENERATED BY DEFAULT AS IDENTITY,
    name VARCHAR(100) NOT NULL,
    balance DEC(15,2) NOT NULL,
    PRIMARY KEY(id)
);
INSERT INTO accounts(name,balance)
VALUES('Bob',1000),('Alice',1000),('James',1000),('Joy',1000)
select * from accounts;
------------------------------------------------------------------------------------ Rollback ---------------------------------------------------------
-- Transactions where you delete user row to table account
begin;
delete from accounts where id =4
-- run -->transaction is locked,check dashboard,now i can either commit or rollback
-- check using select joy at id 4 is deleted.  BUT  in other session it wont be visible without commit.ie joy is still visible
rollback; -- joy at id 4 is now in table ,lock is released.

 ------------------------------------------------------------------------------------ Commit ----------------------------------------------------------------------
begin;
delete from accounts where id =6 
-- run ,changes made in this session, not visible in other session
commit; -- now, after commit, even in other session joy is deleted.

-- Transaction where you insert new row.
begin;
insert into accounts(name,balance) values('Pragya',9000); -- lock recieved , changes made are visile in this session,not yet in other.
--run
commit; -- lock released, changes made visible in other sessions

-- Transaction where you update a row.
begin;
update accounts set balance=4000 where name='Aakash' -- lock recieved , changes made are visile in this session,not yet in other.
--run

----------------------------------------------------------------------------------- Savepoint ----------------------------------------------------------------------
rollback;
select * from accounts;
begin;
update accounts set balance=9999 where id =3;
savepoint p1;
update accounts set name='Pragya' where id =1;
savepoint p2;
delete from accounts where id=2;
rollback to savepoint p1;


---------------------------------------------------------------------------- MANAGING TABLES -----------------------------------------------------------------------
----------------------------------------------------------------------------- Create a table ---------------------------------------------------------
create table users (
user_id serial primary key,
first_name varchar(20) not null,
email varchar(20) unique,
last_login timestamp)

create table employee as emp_info(
emp_id int,
emp_name  varchar(30)
salary int,
dept_name varchar(20))
------------------------------------------------------------------------------ Select Into ------------------------------------------------------------------
select emp_id,emp_name,salary 
into tempTable
from employee
where salary >3000

select *from tempTable
----------------------------------------------------------------------------- Serial ------------------------------
create table test1(
id serial,
name varchar(20));

insert into test1(name) values('Pragya'),('Shivi');
select * from test1

-------------------------------------------------------------------------------- Sequences -----------------------------------------
create sequence seq
increment  10
minvalue 10
maxvalue 50
start 10
cycle

select nextval('seq')
drop sequence seq

--------------------------------------------------------------------------------- Identity Column ------------------------------------------------
-- type 1 => generated always as identity, will always generate a value for the identity column. 
--If you attempt to insert (or update) values into the GENERATED ALWAYS AS IDENTITY column, PostgreSQL will issue an error.
--type 2 =>generated by default as identity,will generate a value for the identity column.
--if you supply a value for insert or update, PostgreSQL will use that value to insert into the identity column instead of using the system-generated value. 
create table fruits(
f_id int generated always as identity,
f_name varchar not null);
insert into fruits(f_name) values('Apple'),('Mango')
insert into fruits(f_id,f_name)values(4,'Banana') --ERROR due to use of generted always as identity

select * from fruits
drop table fruits

create table fruits(
f_id int generated by default as identity,
f_name varchar not null,
f_amt int not null);

insert into fruits(f_name) values('Apple'),('Mango')
insert into fruits(f_id,f_name) values(5,'Melon')

alter table fruits alter column f_amt add generated always as identity

alter table fruits alter column f_amt set generated by default

alter table fruits alter column f_amt drop identity

---------------------------------------------------------------- Alter table ---------------------------------------------
alter table fruits rename column f_id to id;
alter table fruits add column f_quantity int 
alter table fruits drop column f_amt
alter table fruits alter column f_quantity set not null
alter table fruits alter column f_quantity drop not null
alter table fruits alter column f_quantity set default 10
----------------------------------------------------------------- Rename Table --------------------------------------------------------------
alter table fruits rename to fruit
----------------------------------------------------------------- Add column -------------------------------------------------------------------------
alter table fruit add column f_breed varchar(20) not null
------------------------------------------------------------------ Drop column ---------------------------------------------------
alter table fruit drop column if exists f_breed
------------------------------------------------------------------- Change column data type -----------------------------------------------------------------
alter table fruit alter column f_name type text;
----------------------------------------------------------------- Drop table ---------------------------
drop table orders cascade
------------------------------------------------------------------- truncate table ------------------------------
truncate table fruit
---------------------------------------------------------------- Temporaty table --------------------------
--A temporary table, as its name implied, is a short-lived table that exists for the duration of a database session. 
--PostgreSQL automatically drops the temporary tables at the end of a session or a transaction.
create temp table test3(
t_id int)
drop table test3
--------------------------------------------------------------- CONSTRAINTS -----------------------------------------------------
create table parent(
p_id int,
parent_name varchar(10),
primary key(p_id));

create table child(
child_id int,
parent_id int,
name varchar(10) not null,
age integer check (age>18),
primary key(child_id),
constraint fk_parent 
foreign key(parent_id)
references parent(p_id));

drop table child;
drop table parent;

---------------------------------------------------------------- Conditional Expressions ---------------------------------------------
------------------------------------------------------------------------ Case Expression ----------------------------------------------------------

/* label the films by their length based on the following logic:

If the lengh is less than 50 minutes, the film is short.
If the length is greater than 50 minutes and less than or equal to 120 minutes, the film is medium.
If the length is greater than 120 minutes, the film is long. */
select * from film;

select film_id,title,length, 
	case 
		when length <=50 then 'Short'
		when length >50 and length <=120 then 'Medium'
		when length >120 then 'Long'
	end time_duration
from film
order by film_id


------------------------------------------------------------------- coalesce -----------------------------------------------------
--returns first non-null argument=>coalesce(arg1,arg2)
select *from items;

select product, (price-coalesce(discount,0)) net_price
from items

-------------------------------------------------------------------- nullif -----------------------------------------------
-- NULLIF(arg_1,arg_2);
-- The NULLIF function returns a null value if arg_1 equals to arg_2, otherwise it returns arg_1.
select *from posts

--display the posts overview page that shows title and excerpt of each posts. 
--In case the excerpt is not provided, we use the first 40 characters of the post body.

select id,title,coalesce(nullif(excerpt, ''),left(body,40))
from posts					  --empty empty -->null
							   --null empty--> null
							   
------------------------------------------------------------------  cast  --------------------------------------------------------------
select  * from employee

 select cast(avg(salary)as int) avg_salary 
 from employee

---------------------------------------------------------------- Copy an existing table ----------------------------------------------------------------------
-- copy entire table 
create table employeeCopy as
table employee;

select * from employeeCopy
drop table employeeCopy
-- copy only structure of an existing table, i.e.no data
create table filmCopyNodata as 
table film 
with no data;

select *from filmCopyNodata;
drop table filmCopyNodata

-- copy partial data from a table
create table employeecopy as
(select emp_id,emp_name,salary from employee)

select * from employeecopy


---------------------------------------------------------------- psqlcommands Notes-------------------------
-- CONNECTION 1.sudo su postgres -> enter root password -> psql -d databasename -U username -W -> enter pgadmin entry password. (when you know dbname)
-- or sudo su postgres -> enter root password -> psql -> \list ->\c databasename (when you wish to see dbname listed)
--or psql -h localhost -d databasename -U username -W 
-- some commands
/*  \c dbname : connect to database
	\l		  : list database
	\dt		  : list tables
	\d tbname : describe structure of table
	\s        : history
	\s filename : saves history
	\i filename(with path) : executes psql file
	\h        : info of commands in sql
	\h drop table : shows drop table syntax
	\timing   : to show query execution time
	\e        : edit commands
	\a        : switches to non-aligned output
	\H        : shows output in html format
	\q        : quits terminal  */

----------------------------------------------------------- Psql Recipes -----------------------------------------------------------------------
--------------------------------------------------------- Compare two tables ---------------------------------------------
drop table if exists  t1; drop table if  exists t2;
create table t1(id int, name varchar(10));
create table t2(id int, name varchar(10));
insert into t1 values(1,'Apple'),(2,'Ball');
insert into t2 values(1,'Apple'),(2,'Car');
select * from t1;
select * from t2;

-- rows in t1 but not t2
select *  from t1
except 
select *  from t2;

------------------------------------------------------ Delete Duplicate Rows  ---------------------------------------------------------
insert into t1 values(3,'Apple');

delete from  t1 a
using t1 b
where a.id<b.id
and a.name = b.name;
-- in abv query we joined the t1 table to itself and checked if two different rows 
-- (a.id < b.id) have the same value in the name column

----------------------------------------------------- Generate Random Number --------------------
select random(); -- any double precision no.between 0 to1
select random() * 10+1 -- random no. between 1 to11
select floor(random() *10) --avoids  decimal no.
select floor(random() *10) :: int; -- typecasted to int

------------------------------------------------------  Explain ---------------------------------------------------------
EXPLAIN SELECT * FROM film WHERE film_id = 100;
