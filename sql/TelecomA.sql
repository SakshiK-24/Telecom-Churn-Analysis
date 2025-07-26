create database telecom;
use telecom;
LOAD DATA INFILE 'C:/ProgramData/MySQL/MySQL Server 8.0/Uploads/cleaned_telecom_churn.csv'
INTO TABLE cleaned_telecom_churn
FIELDS TERMINATED BY ',' 
ENCLOSED BY '"'
LINES TERMINATED BY '\n'
IGNORE 1 LINES;
rename table cleaned_telecom_churn to c_telecom_churn;
select * from c_telecom_churn;
select count(*) from c_telecom_churn;
select date_of_registration, month from c_telecom_churn;

-- 1.Count the number of customers in each state
select state,count(customer_id) as customer_count
from c_telecom_churn
group by state
order by customer_count desc;

-- 2.Average Salary by Gender
select gender,round(avg(estimated_salary),2) as avg_salary
from c_telecom_churn
group by gender
order by avg_salary desc;

-- 3.Count the number of churned and not churned customers
select churned,count(customer_id) as customer_count
from c_telecom_churn
group by churned
order by customer_count desc;

-- 4.Calculate net_usage i.e total and average data usage cosidered refunded and acutal usage 
select round(sum(data_usage_GB),2) as net_usage,round(avg(data_usage_GB),2) as avg_data_usage -- considered -ve refunded data as well
from c_telecom_churn;
-- 5.Calcualte the refunded data_usage
select count(data_usage_GB) as refunded_count
from c_telecom_churn
where data_usage_GB<0;
-- 6.Calculate the total actual usage of the customers i.e +ve values
select round(sum(data_usage_GB),2) as acutal_usage, round(avg(data_usage_GB),2) as avg_data_usage
from c_telecom_churn
where data_usage_GB>0;
-- 7.Calculate the count of customers who didn't use the data at all
select count(customer_id) as customer_count
from c_telecom_churn
where data_usage_GB=0;

-- 8.Count of customer under each telecom_partner per city
select city,telecom_partner,count(customer_id) as customer_count
from c_telecom_churn
group by city,telecom_partner
order by customer_count desc;

-- 9.Find customers who earned more than the average_salary
select customer_id,estimated_salary
from c_telecom_churn
where estimated_salary>(select round(avg(estimated_salary),2) from c_telecom_churn);

-- 10.List of customers from cities having more than 100 users
select city,count(customer_id) as customer_count
from c_telecom_churn
group by city
having customer_count>100;

-- 11.Count of customers having number of dependents
select num_dependents, count(*) as customer_count
from c_telecom_churn
group by num_dependents
order by  num_dependents desc;

-- 12.Cities with highest churn and who were the telecom_partner
select city,telecom_partner,count(customer_id) as churn_customer_count
from c_telecom_churn
where churn=1
group by city,telecom_partner
order by churn_customer_count desc;

-- 13.Ranking the telecom_partners by total number of customers
select telecom_partner,count(customer_id) as customer_count,
rank() over(order by count(customer_id) desc) as Rank_customer
from c_telecom_churn
group by telecom_partner;

-- 14.Rejected calls and Failed SMS,Successful calls and SMS sent, according to telecom_partner
select telecom_partner,
abs(sum(case when calls_made<0 then calls_made else 0 end)) as total_rejected_calls,
abs(sum(case when sms_sent <0 then sms_sent else 0 end)) as total_failed_sms,
sum(case when calls_made>0 then calls_made else 0 end) as total_successful_calls,
sum(case when sms_sent>0 then sms_sent else 0 end) as total_successful_sms
from c_telecom_churn
group by telecom_partner;

-- 15.Total refunded data and churned customers by telecom_partner
select telecom_partner,
round(abs(sum(case when data_usage_GB<0 then data_usage_GB else 0 end)),2) as total_refunded_gb,
count(case when  data_usage_GB <0 then customer_id end) as customer_refunded,
count(case when churn=1 and data_usage_GB<0 then customer_id end) as churned_after_refund
from c_telecom_churn
group by telecom_partner
order by total_refunded_gb desc;

-- 16.Ranking telecom_partners by refunded data
select telecom_partner,
round(abs(sum(case when data_usage_GB<0 then data_usage_GB else 0 end)),2) as total_refunded_gb,
rank() over(order by abs(sum(case when data_usage_GB<0 then data_usage_GB else 0 end)) desc) as refund_gb_rank
from c_telecom_churn
group by telecom_partner;

-- 17.Total refunded_data
select round(abs(sum(case when data_usage_GB<0 then data_usage_GB else 0 end)),2) as total_refunded_data_gb
from c_telecom_churn;

-- 18.Total actual data usage per age_group 
select age_group,
round(sum(case when data_usage_GB>0 then data_usage_GB else 0 end),2) as total_actual_data_gb
from c_telecom_churn
group by age_group
order by total_actual_data_gb desc;

-- 19.Churned customer in each year
with yearby_churn as
(
select year(date_of_registration) as Year,count(case when churn=1 then customer_id end) as churned_customers
from c_telecom_churn
group by Year
)
select * from yearby_churn
order by Year;

-- 20.Monthly actual data usage and refunded
with monthly_data as
(
select month,year(date_of_registration) as Year,
round(sum(case when data_usage_GB>0 then data_usage_GB else 0 end),2) as total_used,
round(abs(sum(case when data_usage_GB<0 then data_usage_GB else 0 end)),2) as total_refunded
from c_telecom_churn
group by Year,month
) 
select * from monthly_data
order by month,Year;

-- 21.How many users per telecom_partner by gender
select telecom_partner,gender,count(*) as customer_count
from c_telecom_churn
group by telecom_partner,gender
order by customer_count desc;








