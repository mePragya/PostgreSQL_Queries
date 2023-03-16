--**************************************************************************** Database development part 2 *************************************************************************


----------------------------------------------------- dollar-quoted string constants ---------------------------------------------------
select 'I''m also a string constant'; -- doubling up ' ' to have one '  
select 'I''m using shivi''s laptop.';
------------------------------------------------------- Block Structure ------------------------------------------------------
do $$
declare
counter int =1;  first_name varchar(10) = 'Pragya';age int =22;
begin
raise notice '%. % age is %',counter,first_name,age;
end$$

----------------------------------------------------- Variables -----------------------------------------------

do $$
declare
	time1 time =now();
begin
	raise notice '%', time1;
	perform pg_sleep(10);
	raise notice '%', time1;
end $$;

-------------------------------------------> variables in sub-block and outer-block
do $$ <<outer_block>>
declare 
	counter integer :=0;
begin 
	counter :=counter +1;
	raise notice 'current value of counter in  outer-block %',counter;
	declare
	counter  int=10;
	begin 
	counter = counter*2;
	raise notice 'current value of counter in inner block %', counter;
	raise notice 'current value of counter in outer block %', outer_block.counter;
	end;
	raise notice 'current value of counter in outer block %', counter;
end outer_block $$;
---------------------------------------------------------- Select into -------------------------------------------------------------------
do $$
declare 
employee_count int := 0; -- initialize  count to 0   -- semicolon req, datatype
begin
select count(*)
into employee_count
from  employee; -- semicolon req
raise notice 'Number of employee are %',employee_count;
end $$
------------------------------------------------------Copying Datatypes ----------------------
--variablename tablename.columnname%type
do $$ 
declare
   film_title film.title%type;  -->copying datatypeof title in film table to new variable film_title
   featured_title film_title%type;
begin 
   select title
   from film
   into film_title
   where film_id = 100;
   raise notice 'Film title id 100: %s', film_title;
end; $$
select *  from customer
-------------------------------------------------------------Rowtypes----------------------------
--show first name and last name of customer id 10
do $$
declare
	mycustomer customer%rowtype;
begin
	select *
	from customer
	into mycustomer
	where  customer_id=10;
	raise notice 'Customer name : % %',
	mycustomer.first_name,mycustomer.last_name;
	end;$$
	
-----------------------------------------------------Record Type -------------------------------------------------------
--use record to fetch film id,tittle andlength from film forid  =200
do $$
declare 
	r record;
begin
	select film_id,title,length
	into r
	from film
	where film_id=200;
raise notice  '% %  % are the film details',r.film_id,r.title,r.length;
end; $$

------------------------------------------------- Constants ------------------------------------
do $$
declare
	quant int = 10;
	price constant int = 200;
begin
	raise notice 'Netprice = %',price*quant;
	quant =30; -->variable
	raise notice 'updated variable quant= %',quant;
	-- price =100;-->ERROR:  variable "price" is declared CONSTANT. 
end $$;

------------------------------------------------------ Raising Errors -------------------------------------
do $$ 
declare email varchar(20)='pragya#gmail.com';
begin 
  raise info 'information message %', now() ;
  raise log 'log message %', now();
  raise debug 'debug message %', now();
  raise warning 'warning message %', now();
  raise notice 'notice message %', now();
  raise exception 'Incorrect email %',email
  	using hint = 'check your email';  --also has 'detail','errcode','message' option
end $$;
-- PostgreSQL only reports the info, warning, and notice level messages back to the client.
--------------------------------------------------------Assert -----------------------------------
--  If the condition evaluates to true, the assert statement does nothing.
--In case the condition evaluates to false or null, PostgreSQL raises an assert_failure exception.
create table empty(id int);
do $$
declare
	counter int;
begin
	select count(*)
	into counter
	--from customer;
	from empty;
	assert counter>0,'Table is empty';
end$$
---------------------------------------------- Control Struture ---------------------------------------------
----------------------------------------------------  if -----------------------------------
--- fetch film title and length based on film_id inputed ,if it doesntexists show film notfound
do $$
declare
	id_choosed film.film_id%type = 10;
	film_choosed film%rowtype;
begin 
	select * from film
	into film_choosed
	where id_choosed=film_id;
if not found then
	raise notice 'Film with id % is not found',id_choosed;
else 
	raise notice 'Film_title is % and length is %',film_choosed.title,film_choosed.length;
end if;
end $$;

--First, select the film with id 100. If the film does not exist, raise a notice that the film is not found.
--Second, use the if then elsif statement to assign the film a description based on the length of the film.
-- 0-50 short , 51-120 medium , 121< long else na
do $$
declare
	id_choosed film.film_id%type =10;
	film_choosed film%rowtype;
	film_duration film.description%type;
begin 
	select * from film
	into film_choosed
	where id_choosed=film_id;
if not found then
	 raise notice 'Film with id % not found',id_choosed;
else

	if film_choosed.length>0 and film_choosed.length<=50 then
		 film_duration = 'Short film';
	elsif film_choosed.length>50 and film_choosed.length<=120 then
		film_duration= 'medium film';
	elsif film_choosed.length>120 then
		film_duration='Long film';
	else
		film_duration='NA';
	end if;
	raise notice 'Film length for id % is %',id_choosed,film_duration;
end if;
end $$;
------------------------------------------- CASE --------------------------
select * from employee
-- Choose salary status(>10k,<4k,(4k-9k)) for an employee of id 112
-------------------------------------------------> 
do $$
declare 
	emp_table employee%rowtype;
	--sal employee.salary%type;
	sal_status varchar(20);
begin
	select * from employee
	into emp_table
	where emp_id=101;

	if found then
		case 
		when emp_table.salary >=10000 then
			sal_status='High';
		when emp_table.salary>=4000 and emp_table.salary<=9000 then
			sal_status='Medium';
		when emp_table.salary<4000 then
			sal_status='Low';
		else 
			sal_status='Unknown';
		end case;
	raise notice 'Salary status for emp is %',sal_status;
	else
		raise notice 'Employee not found';
	end if;
end$$;
------------------------------------------------------------> or
select * from employee;
do $$
declare 
	sal employee.salary%type;
	--sal employee.salary%type;
	sal_status varchar(20);
begin
	select salary from employee
	into sal
	where emp_id=112;

	if found then
		case 
		when sal >=10000 then
			sal_status='High';
		when sal>=4000 and sal<=9000 then
			sal_status='Medium';
		when sal<4000 then
			sal_status='Low';
		else 
			sal_status='Unknown';
		end case;
	raise notice 'Salary status for emp is %',sal_status;
	else
		raise notice 'Employee not found';
	end if;
end$$;
------------------------------------------------ Loop ----------------------------------------------
--- Fibonacci series
do $$
declare 
	counter int =0;
	num int=10;
	fib int=0;
	i int=0;
	j int=1;
begin 
	if(num<1) then
		fib=0;
	else
		loop 
			exit when counter=num;
			 counter = counter+1;
			 select j,i+j into i,j;
		end loop;
	end if;
	fib=i;
raise notice '%',fib;
end $$;

--  loop : count 1 to 7
do $$
declare
	counter int =0;
	num int =7;
begin
	loop
		exit when counter=num;
		counter =counter +1;
		raise notice '%',counter;
	end loop;
end$$;
------------------------------------------------- While ----------------------------------------------------
-- count 1 to 10
do $$
declare 
	count int=0;
begin 
	while count < 10 loop
		count = count +1;
		raise notice '%',count;
	end loop;
end $$;

------------------------------------------------- for loop -----------------------------------
--> count 1 to 10
do $$
declare
	count int=0;
begin 
	for count in reverse 10..1 by 2 loop
	raise notice '%',count;
	end loop;
	end  $$;

--> display the titles of the top 10 longest films.
select * from film
do $$
declare
 f record;
begin 
	for f in select title,length
	from film
	order by length desc,title
	limit 10
	
	loop
	raise notice '% : % mins',f.title,f.length;
	end loop;
end $$;

------------------------------------------- exit ----------------------------------------------------
-- > count from 1 to 3 then exit 
do $$
declare 
 i int =0; j int=0;
begin 
	loop 
		i=i+1;
		exit when i>3;
		raise notice '%',i;
	end loop;
end $$;

-------------------------------------------------- Continue ----------------------------------------
--> print even numbers from 1 to 10
do $$
declare 
	num int =0;
begin 
	loop
		num=num+1;
		exit when num>10;
		continue when mod(num,2) <> 0; -- skip odd numbers
		raise notice '%',num;
	end loop;
end $$;
----------------------------------------------------- USER DEFINED FUNCTIONS --------------------------------------------------------
-------------------------------------------------------  Create functions -----------------------------------------------------------------------
-- Fetch count of films for a particular length duration
-- select * from film
create function get_count_film(len_from int, len_to int)
returns int 
language plpgsql
as 
$$
declare 
	film_count int;
begin
	select count(*)
	into film_count
	from film
	where length BETWEEN len_from and len_to;
	return film_count;
end $$;

------>>> Function calling
select get_count_film(40,90);

select get_count_film(
len_from=>30,
len_to => 100);

select get_count_film(40,len_to =>90);

---------------------------------------------------------- Functions Parameters -----------------------------------
--- Fetch customer name for a given customer id --->> PARAMETER IN
create or replace function get_cust_name(c_id int)
returns varchar
language plpgsql
as 
$$
declare
	c_name customer.first_name%type;
begin 
select first_name
Into c_name
FROM customer
where customer.customer_id=c_id;
	if not found then
		raise notice 'Customer with id - % not found',c_id;
	end if;
return c_name;
end $$;

-- select get_cust_name(1);

-- Fetch film status --->> PARAMETER OUT
--> Fetch avg salary of all employees 
select * from employee

create or replace function get_emp(
	out avg_salary dec)
	
language plpgsql
as $$
begin
	select avg(salary)
	into avg_salary
	from employee;
end $$;

select get_emp()
-- select avg(salary) from employee
-- drop function get_emp();

create or replace function get_film_stat(
    out min_len int,
    out max_len int,
    out avg_len numeric) 
language plpgsql
as $$
begin
  
  select min(length),
         max(length),
		 avg(length) ::numeric(5,1)
  into min_len, max_len, avg_len
  from film;

end;$$

-- select get_film_stat();

--  Parametre INOUT
create function swap(
	inout a int,
	inout b int)
language plpgsql
as 
$$
begin 
select a, b into b,a;
end $$;
-- select swap(88,123);

------------------------------------------------ Function overloading -----------------------------------
 ---->>>  FUNCTION 1
create or replace function get_emp(e_id int)
returns varchar
language plpgsql
as $$
declare
	name employee.emp_name%type;
begin 
	select emp_name 
	into name
	from employee
	where emp_id = e_id;
	return name;
end $$;

---->>> FUNCTION 2
create or replace function get_emp(
	p_deptname varchar,
	p_salary int )
returns varchar
language plpgsql
as $$
declare 
	name employee.emp_name%type;
begin
	select emp_name 
	into name 
	from employee
	where employee.dept_name=p_deptname and salary > p_salary;
return name;
end $$;

-- select * from employee;
-- select get_emp(104)
-- select get_emp('HR',4500);

--------------------------------------------- Functions That Return A Table --------------------------------
create or replace function get_actor (
  p_like varchar
) 
	returns table (
		p_fname varchar,
		p_lname varchar,
		p_actorid int
	) 
	language plpgsql
as $$
begin
	return query 
		select
			first_name,
			last_name,
			actor_id
		from
			actor
		where
			first_name ilike p_like;
end;$$

SELECT * from get_actor('p%');

------------------------------------------------------------- Drop Function -------------------------------------------------------------
DROP FUNCTION get_actor
DROP function get_emp(int,varchar);
DROP function get_emp();
DROP function get_film(int);

--------------------------------------------------------------- Exceptions --------------------------------------
---------------------------------------------------------- no_data_found Exception --------------------------------------------

-- fetch film details from film table using an input id (which doesnt exist) 
-- select * from film
do
$$
declare
	rec record;
	v_film_id int = 2000;  --> film id has id's only upto 1000
begin
	select film_id, title 
-- 	into rec
	into strict rec -->If the STRICT option is specified, the command must return exactly one row 
	from film		--> or a run-time error will be reported, either NO_DATA_FOUND (no rows) or TOO_MANY_ROWS (more than one row).
	where film_id = v_film_id;
-- raise notice  '%',rec.title;

	exception 
		when no_data_found then
			raise exception 'Film % not found',v_film_id;
end;
$$
language plpgsql;

------------------------------------------------------------- too_many_rows exception ----------------------

------ Fetch actor details from film_actor(a table with many rows)
-- select * from film_actor;  --> 5462 rows
do $$
declare
	p_input_id int = 3; --> present in accounts table
	selected_row film_actor%rowtype;
begin 
	select actor_id,film_id,last_update
	into strict selected_row --> due to 'strict' it outputs error as returned value is not exactly 1
	from film_actor
	where film_actor.actor_id=p_input_id;
exception
	when too_many_rows then 
		raise exception 'Search Query Returns Too Many Rows';
	end;
	$$

-------------------------------------------------------------- Not unique exception And SQLState codes-----------------------------------------------------------
-- select last_name from actor ORDER by last_name --> table actor has duplicate last names
--> fetch actor details using last name 
do $$
declare 
	 row actor%rowtype;
	 p_lname varchar ='Akroyd'; -- last name not unique
-- 	 p_lname varchar ='Gupta'; -- last name not found
begin
	select actor_id,first_name
	into strict row
	from actor
	where last_name=p_lname;
	
	exception
		when sqlstate 'P0002' then
			raise exception 'last name : % not found',p_lname;
		when sqlstate 'P0003' then 
			raise exception 'Last name : % not unique',p_lname;
end;
$$

------------------------------------------------------------ Store Procedures ---------------------------------------

/* Note : Difference Between function and procedure
	1. Transactions  => Absent in function            => Possible in proceure (commit,rollback,savepoint)
	2. Return Values => Function Returns a value      => No value returned in procedure
	3. Calling       => DML commands within a query   => Explicit CALL command
	4. Attributes    => Attributes like strict works  => They dont.
*/

-->> update salary of all employees in department of HR to 10,000
select * from employee;

create or replace procedure update_salary( 
	dep_name varchar(20))
language plpgsql
as $$
begin 
	update employee
	set salary=10000
	where dept_name =dep_name;
	commit;
end $$;

-->>calling procedure
call update_salary('HR')
select * from employee


-->> Transfer funds of 400 from auyur to aakash using procedure
select * from accounts;
CREATE or replace procedure money_transfer(
	sender int,
	receiver int,
	amount dec)
language plpgsql
as $$
begin
	update accounts
	set balance = balance - amount
	where id= sender;
	
	update accounts
	set balance = balance + amount
	where id=receiver;
	
	commit;
end $$;

---->>> Calling procedure
call money_transfer( 1,2,400);
select * from accounts



select * from actor
--> Insert first name and last name into actor table using procedure inputing one parameter - fullname
create or replace procedure insert_actor(
	full_name varchar
)
language plpgsql	
as $$
declare
	fname varchar;
	lname varchar;
begin
	-- split the fullname into first & last name
	select 
		split_part(full_name,' ', 1),
		split_part(full_name,' ', 2)
	into fname,
	     lname;
	
	-- insert first & last name into the actor table
	insert into actor(first_name, last_name)
	values(fname,lname);
end;
$$;

call insert_actor('Pragya Gupta')

-->> in postgre version 14 : inout parameters in procedure works 
create or replace procedure swap_procedure(
	inout a int,
	inout b int)
language plpgsql
as 
$$
begin 
select a, b into b,a;
end $$;

call swap_procedure(11,22)
--------------------------------------------------- Drop Procedure ---------------------------------------------------------

drop procedure money_transfer();
drop procedure money_transfer(int,int,int);
drop procedure 
			insert_actor,
			update_salary;

---------------------------------------------------- Cursor --------------------------------------------------------------
--> Use of fetch and move in cursor to fetch employee details 
create or replace function show_emp_details()
returns void
as
$$
declare
	c1 refcursor;
	emp_row employee%rowtype;
begin 
	open c1 for select * from employee; --> c1 will store details from employee table
	
	-- => Fetch first row
	fetch first from c1 into emp_row;  --> c1 points and reads first row from table employee
	raise notice 'First row : % % %',emp_row.emp_id,emp_row.emp_name,emp_row.dept_name;
	
	-- => fetch next row
	fetch next from c1 into emp_row;
	raise notice 'Next row : % % %',emp_row.emp_id,emp_row.emp_name,emp_row.dept_name;
	
	-- => fetch using default value 
	fetch from c1 into emp_row;  ---> default value is to fetch next row
	raise notice 'Row after next is : % % %',emp_row.emp_id,emp_row.emp_name,emp_row.dept_name;
	
	-- => set cursor to a particular row but not read it  --> use of move
	move relative 3 from c1; -->moves cursor by 3 position from its previous position
	
	fetch from c1 into emp_row; --> initial position id:104  current position of cursor id:110 (data in table is in order 104,106 108 109,110)
	raise notice 'Row after using move by 3 positions is : % % %',emp_row.emp_id,emp_row.emp_name,emp_row.dept_name;
	
	fetch from c1 into emp_row; --> initial position id:104  current position of cursor id:110 (data in table is in order 104,106 108 109,110)
	raise notice 'Row  : % % %',emp_row.emp_id,emp_row.emp_name,emp_row.dept_name;
	
	
	
	close c1;
	
end; $$
language plpgsql;

select * from employee;
select * from show_emp_details();	-->check messages in output window
	

------>> Use of loop with cursor
      
create or replace function show_customer()
returns void
as $$
declare 
	cur refcursor;
	cust_row customer%rowtype;
begin 
	open cur for select * from customer;
	
		loop
			fetch from cur into cust_row;
			exit when not found;
			raise notice '% % %',cust_row.customer_id,cust_row.first_name,cust_row.last_name;
		end loop;
	close cur;
end; $$
language plpgsql;

select * from customer;
select * from show_customer();

------>> Use of reverse loop  ==> SCROLL parameter ,prior 

create or replace function show_customer()
returns void
as $$
declare 
	cur refcursor;
	cust_row customer%rowtype;
begin 
	open cur scroll for select * from customer;  --you specify whether the cursor can be scrolled backward using the SCROLL. If you use NO SCROLL, the cursor cannot be scrolled backward.	
	
	fetch last from cur into cust_row; --> for reverse loop cursor must point to last value from start
		loop
			raise notice '% % %',cust_row.customer_id,cust_row.first_name,cust_row.last_name;
			fetch prior from cur into cust_row; -->Returns the result row immediately preceding the current row, and decrements the current row to the row returned. 
			exit when not found;
			raise notice '% % %',cust_row.customer_id,cust_row.first_name,cust_row.last_name;
		end loop;
	close cur;
end; $$
language plpgsql;

select * from customer;
select * from show_customer();

--------------------------------------- Triggers --------------------------------------------------
/* Steps : 
			1. Create a Table (to enter new values)
			2. Create a log/audit table (to store old overwritten values)
			3. Create a Trigger function
			4. Create Trigger */

--> EXAMPLE : for every  new staff add old staff details in stafflog

-- 1. Create table
create table staff_demo(sid int,sname varchar(20));
insert into staff_demo values (1,'Akbar'),(2,'Barun'),(3,'Carol');
select * from staff_demo;

--2. Create a log table
create table staff_log(log_id int generated always as identity,old_sid int,old_sname varchar(20),changed_on timestamp(6));

-- 3. create trigger function
create or replace function fn_staff_log()
returns trigger
language plpgsql
as $$
begin 
	if new.sname <> old.sname then
		insert into staff_log(old_sid,old_sname,changed_on) values(old.sid,old.sname,now());
	end if;
	return new;
end;$$

drop function fn_staff_log

-- 4. Create trigger
create or replace trigger trg_staff_log
-- before update
-- after update
after delete
on staff_demo
for each row
execute function fn_staff_log();

drop trigger trg_staff_log on staff_demo cascade

update staff_demo set sname='Bob' where sid=2; 
update staff_demo set sname='Atul' where sid=1;
delete from staff_demo where sid =3; 
select * from staff_log


------------------------------------------ Drop Triggers ----------------------
drop function fn_staff_log
drop trigger trg_staff_log on staff_demo cascade
--------------------------------------------------------   Alter Triggers --------------------------------------
 alter trigger trg_staff_log on staff_demo
 rename  to trg_log_staff
----------------------------------------------- Disable Triggers ------------------------------------------
alter table staff_demo disable trigger  trg_staff_log;
alter table staff_demo disable trigger  all;
------------------------------------------------- Enable Triggers ------------------------------------
alter table staff_demo enable trigger  trg_staff_log;
alter table staff_demo enable trigger all;
------------------------------------------------ Aggregate functions --------------------------------------------------
select floor(avg(balance))  from accounts;
select dept_name,max(salary) from employee group by dept_name
select min(salary) as Min_Salary_IT,emp_name from employee where dept_name='IT'group by(emp_name) order by emp_name
select count(customer_id) as No_Of_Customer from customer 
select sum(return_date - rental_date) rental_duration from rental;

--------------------------------------------- Window Function -------------------------------------------

select *, 
---> Row Number : Assign row number for each employee row wrt to dept_name 
row_number() over(partition by dept_name) as row_No,

---> Rank : Rank each row wrt to dept_name according to their salary
rank() over(partition by dept_name order by salary desc) as salary_rank,

---> DenseRank : doesn't skip next rank for previos two same rank
dense_rank() over(partition by dept_name order by salary desc) as Sal_dense_rank
from employee 
------------------------------------------------------------------------------------
select emp_id,dept_name,salary,
---> FirstValue : returns first value within that partition
first_value(salary) over(partition by dept_name order by emp_id ) as First_Sal,

---> LastValue : returns Last value within that partition
last_value(salary) over(partition by dept_name order by emp_id RANGE BETWEEN UNBOUNDED PRECEDING AND UNBOUNDED FOLLOWING ) as Last_Sal,

---> Lag : returns data from previous row
lag(salary) over(partition by dept_name order by emp_id) as Prev_sal,

---> Lead : returns data from next row
lead(salary) over(partition by dept_name order by emp_id) as Next_sal
from employee

--------------------- Date Functions --------------------------------------
select age(timestamp '2000-11-18'),current_date,current_time,localtimestamp(2) ;
select date_part('year',timestamp '2022-03-10');
select extract(doy from localtimestamp)
select to_date('2022013','yyyymmdd'),to_timestamp('2022-09-18 9:30:02','yyyy/mm/dd hh:mi:ss' )
select now();
set timezone='America/Los_angeles'
select now();
set timezone='Asia/Kolkata'
select (now() + interval '2 hours')

----------------------------- String Function -------------------
select ascii('*'),chr(99),md5('Postgresql')
select position( 'Ace' in film.title) from film order by title
Select emp_name,substring(emp_name,1,1) as initial from employee 
select p_id,split_part(parent_name,' ',1) First_name,split_part(parent_name,' ',2) Last_name from parent
update films_demo set title = replace(title,'ccc','xxx')
select regexp_replace(email,'[[:digit:]]','','g')from demo where age=22;
select first_name,length(first_name) from customer where customer_id=1;
select ltrim('88pragya','88'),btrim('**pragya**','**')
select format('%s %s',first_name,last_name) full_name from customer
select lpad('pgadmin',16,'^');
select payment_id,payment date,to_char(payment_date,'mon-dd-yyyy hh:mipm' )payment_time from payment
select to_number('12765','99999')
select * from payment;

------------------------------- Math Funations -----------------
select round (Avg(length),2)from film
select abs(-22.56),ceil(22.56),floor(22.56),trunc(22.56,-1),mod(-22,3)
