DROP TABLE users_temp;
CREATE TABLE users_temp as
(select users.*, 
sum(CAST(contribution_in_paisa as DECIMAL)/10000.0) as invamt,
count(*) as invcommcount 
from users 
left join investments on investments.investor_id=users.id 
group by users.id
);



drop table investments_temp;
CREATE TABLE investments_temp as 
(select investments.*,
CAST(contribution_in_paisa as DECIMAL)/(10000.0*invamt) as rowfractionamount,
invcommcount,
1000.0/CAST(invcommcount as DECIMAL) as partsperthousand 
from investments 
left join users_temp on  investments.investor_id=users_temp.id     );

  
                       
DROP TABLE pie_district;
CREATE TABLE pie_district ( 
select investor_id , borrower_district, 
sum(rowfractionamount) as fractionamt, sum(partsperthousand) , sum(contribution_in_paisa/10000.0) as amount, count(*) as count from investments_temp 
left join loan_profiles on investments_temp.loan_profile_id=loan_profiles.id  group by 1,2 );
                       

                       
DROP TABLE pie_month ;
create TABLE pie_month as (
select investor_id , SUBSTR(published_date,6,2) as month1, 
sum(rowfractionamount) as fractionamt, sum(partsperthousand) , 
sum(contribution_in_paisa/10000.0) as amount, 
count(*) as count from investments_temp 
left join loan_profiles on investments_temp.loan_profile_id=loan_profiles.id group by 1,2 );
 
                       
DROP TABLE pie_activity;
CREATE TABLE pie_activity as (  select investor_id , activity, 
sum(rowfractionamount) as fractionamt, sum(partsperthousand) as partsperthousand, sum(contribution_in_paisa/10000.0) as amount, count(*) as count from investments_temp 
left join loan_profiles on investments_temp.loan_profile_id=loan_profiles.id group by 1,2 );
                       
DROP TABLE pie_state;
CREATE TABLE pie_state as (  
select investor_id , borrower_state, 
sum(rowfractionamount) as fractionamt, sum(partsperthousand), sum(contribution_in_paisa/10000.0) as amount, count(*) as count from investments_temp 
left join loan_profiles on investments_temp.loan_profile_id = loan_profiles.id group by 1,2 );
