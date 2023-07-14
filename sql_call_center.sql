# Create Database
create database jo_company; # Name is for learning purpose

# Command SQL to use database
use jo_company; 
# Create the table based on data from https://data.world/markbradbourne/rwfd-real-world-fake-data/workspace/file?filename=Call+Center.csv
create table call_center(
	id char(24),
    customer_name varchar(255),
    sentiment char(13),
    csat_score int,
    call_timestamp char(10),
    reason char(20),
    city char(20),
    state char(20),
    channel char(20),
    response_time char(20),
    call_duration_in_minutes int,
    call_center Char(20)
);


# Alter table rather than recreate the whole table, in case the table is filled with datas
alter table jo_company.call_center modify call_timestamp varchar(255);
alter table jo_company.call_center modify call_center varchar(255);
alter table jo_company.call_center modify csat_score varchar(10);
alter table jo_company.call_center modify call_duration_in_minutes varchar(30);
 alter table jo_company.call_center modify city varchar(255);

# Turn off safety features
SET SQL_SAFE_UPDATES=0;

# Peek the folders readable by safe SQL functions
SHOW VARIABLES LIKE "secure_file_priv";

# Load data from the CSV downloaded raw
LOAD DATA 
	INFILE "C:/ProgramData/MySQL/MySQL Server 8.0/Uploads/Call Center.csv" 
	INTO TABLE jo_company.call_center
    FIELDS TERMINATED BY ","
    optionally ENCLOSED BY '"'
    LINES TERMINATED BY '\n'
    IGNORE 1 LINES
    (
		id,customer_name,sentiment,csat_score,call_timestamp,
		reason,city,state,channel,response_time,
        call_duration_in_minutes ,call_center
    );

# Update the date column from text to SQL date
UPDATE  jo_company.call_center SET call_timestamp = str_to_date(call_timestamp, '%m/%d/%Y hh:mm:ss'); # parameters needed are the variable changed, the former format (it will change to how sql read it)

# Update scores that has been detected to be null
update  jo_company.call_center SET csat_score=null Where csat_score = "";

# Peek the first 10 data
Select * from call_center LIMIT 10;

# Alteration to number type data so it's easier to do future exploration
alter table jo_company.call_center modify call_duration_in_minutes int;
alter table jo_company.call_center modify csat_score int;

#Turn on the updates safety. We will be seeing the data
SET SQL_SAFE_UPDATES=1;

Select count(id) FROM jo_company.call_center WHERE jo_company.call_center.csat_score!=""; #12271 (so 12k people rated the call center, might be skipping)
Select count(id) FROM jo_company.call_center WHERE jo_company.call_center.call_duration_in_minutes!=""; #32941 (No empty)
select distinct sentiment from jo_company.call_center; #Neutral, Very Positive, Negative, Very Negative, Positive
select distinct reason from jo_company.call_center; #Billing Question, Payments, Service Outage
select distinct state from  jo_company.call_center; # Many city, but no empties detected
-- most question asked in call center
select reason, count(id) from  jo_company.call_center GROUP BY reason; 
-- Billing Question	23462
-- Service Outage	4730
-- Payments	4749
select distinct call_timestamp from  jo_company.call_center order by call_timestamp ; #1-31 oct 2020

select reason, count(id) from  jo_company.call_center WHERE call_timestamp  BETWEEN "2020-10-01" AND  "2020-10-07" group by reason; 
-- Service Outage	1060
-- Billing Question	5411
-- Payments	1127
select call_timestamp, count(call_timestamp) from  jo_company.call_center group by call_timestamp order by count(call_timestamp) desc; #1170 call on 21 oct	

select reason, min(call_duration_in_minutes) from  jo_company.call_center  group by reason; #whatever the problem is, they have their same max and minimal call duration
select avg(csat_score), reason from  jo_company.call_center where csat_score is not null group by reason; #Payments has more average score, at 0.1 more than others
select min(csat_score), reason from  jo_company.call_center where csat_score is not null group by reason; #Payments has more average score, at 0.1 more than others




