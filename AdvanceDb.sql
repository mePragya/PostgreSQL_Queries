---------------------------------------------------- ADVANCE DATABASE DEVELOPMENT : IMPLEMENTATION ------------------------------------


------------------------------------------------------------------------ Deadlock Implementation Transaction 1 ------------------------------------------------------------
drop table t_data;
CREATE TABLE t_data (id int, data int);

INSERT INTO t_data VALUES (1, 100), (2, 200);
select * from t_data;

BEGIN;	
UPDATE t_data
SET data = data * 10
WHERE id = 1
--go to transaction 2
UPDATE t_data
SET data = data * 10
WHERE id = 2
--wait
commit;
rollback;
 ------------------------------------------------------------------------------ Deadlock Implementation transaction 2 --------------------
CREATE TABLE t_data (id int, data int);

INSERT INTO t_data VALUES (1, 100), (2, 200);

select * from t_data;

--drop table t_data;
begin;
UPDATE t_data
SET data = data * 10
WHERE id = 2
  -- go to transaction 1
UPDATE t_data
SET data = data * 10
WHERE id = 1
-- deadlock
rollback; 
------------------------------------------------------------------------- Deadlock avoidance transaction 1 ----------------------------------------------------------
BEGIN;	
UPDATE t_data
SET data = data * 10
WHERE id = 1
--updates,go to tran2
UPDATE t_data
SET data = data * 10
WHERE id = 2
-- updates , do not go to tranc 2 before u commit here ,if u do, and make update or select
-- request from tran.2 it will give error- "ERROR: execute cannot be used while an asynchronous query is underway", 
-- this occured when  a transaction which was already waiting was asked to execute a locked command.
commit;
----------------------------------------------------------------------------------- Deadlock Avoidance transaction 2 ------------------
begin;
UPDATE t_data
SET data = data * 10
WHERE id = 1
-- waits , go to tran 1

UPDATE t_data
SET data = data * 10
WHERE id = 2
commit;
--------------------------------------------------------------------------- On delete cascade ------------------------------------------------------------

-- https://www.commandprompt.com/education/postgresql-delete-cascade-with-examples/#:~:text=foreign%20key%20constraints).-,To%20use%20a%20delete%20cascade%20in%20Postgres%2C%20specify%20the%20%22ON,deleted%20in%20the%20referencing%20table.
drop table customer_details;
drop table orders
create table customer_details(
c_id integer primary key,
c_name varchar(20) not null)

create table orders(
o_id int primary key,
c_id int references customer_details(c_id) on delete cascade,
o_date date)

INSERT INTO customer_details (c_id, c_name)
VALUES(10, 'Joe'),
(2, 'Mike'),
(3, 'Joseph');

INSERT INTO orders (o_id,c_name, c_id, o_date)
VALUES(1,'Joe',1, '2022-12-12'),
(2,'Joe',1, '2022-12-12'),
(3,'Mike',2, '2022-11-15'),
(4,'Joseph',3, '2022-12-16'),
(5,'Mike',2, '2022-12-18');

select * from  customer_details;
select * from orders;
commit
DELETE FROM customer_details 
WHERE c_id = 1;

-- c_id int references customer_details(c_id) on update cascade,

------------------------------------------------------------------------- Update Cascade ----------------------------------------------------------------

drop table if exists orders;
create table orders(
o_id int primary key,c_name varchar(20) not null,
c_id int references customer_details(c_id) on update cascade,
o_date date)

update customer_details
set c_id=33 where c_id=3

-- can update only the primary key column and no other column -->so no changes will be reflected in orders
update customer_details 
set c_name='cat' where c_id=22;

--will show error i.e only the changes made in primary table will be reflected automatically in foreign table 
-- changes made in foreign table wont be reflected automatically to primary table
update orders set c_id=15 where c_id=1  -- updating orders made no changes in customer_details even when they are linked

create table accounts(id int,name varchar(20),balance int)
insert into accounts values(1,'first',100),(2,'second',100),(3,'third',100)
drop table accounts;

--------------------------------------------------------------------- Isolation levels -> Transaction 1 ----------------------------------------------------------
show transaction isolation level;
-- by Default in postgres its read commited (in Mysql its repeatable read)

--------------------------------------------------------------------------- Read Uncommitted ------------------------------------
begin 
set transaction isolation level read uncommitted; -- Changing Transaction level 
show transaction isolation level; -->read uncommitted
select * from accounts
update accounts set balance=200 where id =1 --Value is updated(but only for this tranaction)
-- move to transaction 2
COMMIT
--  -> Dirty read is prevented here
----------------------------------------------------------------------------- Read Committed ------------------------------------
begin 
set transaction isolation level read committed; -- Changing Transaction level 
show transaction isolation level;
select * from accounts
update accounts set balance=300 where id =1 --Value is updated(but only for this tranaction)
-- move to T2
commit;
--  -> Phantom read is prevented here
---------------------------------------------------------------------------- Repeatable Read ------------------------------------
begin;
set transaction isolation level Repeatable Read; -- Changing Transaction level 
show transaction isolation level;
select * from accounts
update accounts set balance=balance-210 where id =1 --updated for T1
commit
--  -> Phantom read is prevented here
------------------------------------------------------------------------ what is serialization anomaly ------------------------------------
begin;
set transaction isolation level Repeatable Read;
show transaction isolation level;
select * from accounts
select sum(balance) from accounts; -- sum is 290.
insert into accounts values(4,'Sum',290);
select * from accounts -- sum 290 is inserted
-- go to T2
commit --> now go to t2 and commit it

------------------------------------------------------------------------------- Serializable ------------------------------------
begin;
set transaction isolation level serializable;
show transaction isolation level;
select * from accounts
select sum(balance) from accounts; -- sum is 870.
insert into accounts values(4,'Sum',870);
select * from accounts  -->870 inserted.
---> go to T2
commit;

------------------------------------ Isolation levels -> Transaction 2 ----------------------------------------------------------
show transaction isolation level; -- -> read committed by default
--------------------------------------------- Read Uncommitted ------------------------------------
begin
set transaction isolation level read uncommitted;
show transaction isolation level;  --> read uncommitted
select * from accounts where id=1;
-- after update in transaction 1 without commit
select * from accounts where id=1; --(this has not read an uncommited value)
-- According to postgres Documentation, READ UNCOMMITTED behaves same as READ COMMITTED.
-- After commit
select * from accounts where id=1;
commit;

--------------------------------------------- Read Committed ------------------------------------
begin
set transaction isolation level read committed;
show transaction isolation level;
select * from accounts where id=1;
-- after update,no commit in T1
select * from accounts where id=1; -- not updated
-- after commit
select * from accounts where id=1; -- updated,Hence read committed
commit
--  -> Phantom read is prevented here
--------------------------------------------- Repeatable Read ------------------------------------
begin;
set transaction isolation level Repeatable Read;
show transaction isolation level;
select * from accounts where id=1
select * from accounts where balance >=100
-- after update, commit
select * from accounts where balance >=100 -- after commit this should give newly updated result, but due to use of repeatable read it must keep givivg previous reault
-- gave previous results
--  -> Phantom read is prevented here
update accounts set balance=balance-10 where id =1 -- T1 value =90(after commit) ,T2 value =300 ->idealy this query should output 80(as in mysql) or give an error and not make updates
-- ERROR:  could not serialize access due to concurrent update. this is nice as it avoids confusing state like subtracting 10 from 300 gives 80.
commit
--------------------------------------------- what is serialization anomaly ------------------------------------
begin;
set transaction isolation level Repeatable Read;
show transaction isolation level;
select * from accounts -- no sum is inserted(due to no commit yet),table is in intial state as it should be
select sum(balance) from accounts; -- sum is 290.
insert into accounts values(4,'Sum',290);
select * from accounts -- sum 290 is inserted
-- go to t1 and commit it.
-- now commit t2
commit ---> now this commit shows insertion of 290 twice(one due to T1,other due to T2) which should'nt happen as second sum should be 290+290=580
-- this is problem called serialization anomaly
---> solved in serializable.

--------------------------------------------- Serializable ------------------------------------
begin;
set transaction isolation level serializable;
show transaction isolation level;
select * from accounts
select sum(balance) from accounts; -- sum is 870.
insert into accounts values(4,'Sum',870);
select * from accounts
----> commit T1
commit; --> will show error,which is nice as it wont allow insertion of wrong data as seen in serialization anomaly
/*ERROR:  could not serialize access due to read/write dependencies among transactions
DETAIL:  Reason code: Canceled on identification as a pivot, during commit attempt.
HINT:  The transaction might succeed if retried. */
select * from accounts
--> only one 870 insertion will be present.
