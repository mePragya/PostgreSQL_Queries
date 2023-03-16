------------------ Database Development Part 3 -------------------------

-------------------- Managing Database ------------------------------

-------------------------- create database --------------------
create database demo
with encoding ='UTF8'
Owner = postgres
connection limit=100

-------------------------- Alter Database ------------------------------
alter database demo with connection limit 150
alter database demo rename to sample
create role dummy login createdb password '123';
alter database sample owner to pragya

------------------------ Rename Database--------------------------------

--------------------------- Drop Database --------------------

select * from pg_stat_activity where datname ='sample'

select pg_terminate_backend (pg_stat_activity.pid)
from pg_stat_activity where pg_stat_activity.datname='sample'

drop database sample


----------------------------- Copy a database --------------------
create database sourcedb;
create database sampleTest with template sourcedb;

----------------------- Database Object Sizes --------------
select pg_size_pretty (pg_database_size ('PostTutDb'));
select pg_size_pretty (pg_indexes_size('actor'));
select pg_size_pretty ( pg_tablespace_size ('pg_default') );
select pg_column_size(5::bigint);

------------------------------ Managing Schema --------------------------
select current_schema();
show search_path;

----------------------- Create Schema ------------------------------
create schema schematest;
create schema authorization pragya1;
create schema sch
	create table tb(
	id int not null,
	name varchar(20))
	
-------------------- Alter Schema--------------------------------
alter schema schematest rename to schemaDemo
alter schema schemaDemo owner to postgres

---------------------- Drop Schema -------------------------
drop schema schemaDemo cascade
set search_path to schematest, public;
create table demo ( id int,age int);
create role pragya1 login password '123';



--------------------------------Managing Tablespace---------------------------

---------------------- Create Tablespace --------------------------
create tablespace tbsp1 location '/home/pragya/Documents';


----------------------- Alter Tablespace -------------------
alter tablespace tbsp1 rename to tbsp
alter tablespace tbsp owner to pragya


--------------------Drop tablespace ------------------
drop tablespace tbsp


----------------------------------- Role And Privileges ---------------------
select usename from pg_catalog.pg_user


------------------------------------- Create Role -------------------------------
create role adam
select rolname from pg_roles
create role riya createdb login password '123' connection limit 100 valid until '2022-03-15'

------------------------------------ Grant Permission ---------------------

grant insert,update,delete on films_demo to adam
grant all on films_demo to adam
grant all on all tables in schema sch to riya
grant select on all tables in schema sch to riya

--------------------------------- Revoke Permission ----------------------

revoke insert,update,delete on films_demo from adam
revoke all on films_demo from adam

------------------------ Alter Role ---------------------

alter role adam rename to adam_williams;
alter role adam_williams valid until '2022-03-20';
alter role adam_williams password '123'
alter role adam_williams with createdb
-------------------------- Drop Role ---------------------
reassign owned by adam_williams to riya
drop role adam_williams

------------------------ Role Membership ---------------------

-- Create group role
create role HR;
-- Grant group role
Grant HR to adam
-- Revoke group Role
revoke hr from adam

-----------------------List Role--------------------------------
-- \du   \du+   in psql tool
select * from pg_catalog.pg_user
select * from pg_user

--------------------- Backup And Restore -------------------
--pg_dump -U postgres -W -F t testDb > c:\pgbackup\testDb.tar
--pg_dumpall -U postgres > c:\pgbackup\all.sql
-- pg_restore --dbname=newDB --verbose c:\pgbackup\testDb.tar
