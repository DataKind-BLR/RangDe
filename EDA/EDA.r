# Loading Packages
install.packages("sqldf")
install.packages("reshape2")
library("reshape2", lib.loc="/Library/Frameworks/R.framework/Versions/3.1/Resources/library")
library("sqldf", lib.loc="/Library/Frameworks/R.framework/Versions/3.1/Resources/library")


# Loading Data
investments <- read.delim("~/Downloads/rangde-2yr-data/investments.tsv")
users <- read.delim("~/Downloads/rangde-2yr-data/users.tsv")
names(users)[1]<-"uid"
loan_profiles <- read.delim("~/Downloads/rangde-2yr-data/untitled folder/loan_profiles.tsv")

# Distribution of Investments
inv<- sqldf('select investor_id, count(*) from investments group by 1 order by 2 desc')
inv_coll <- sqldf('select investments.*,users.*  from investments left join users on 
                  investments.investor_id=users.uid')

users1<- sqldf('select users.*, sum(CAST(contribution_in_paisa as DECIMAL)/10000.0) as invamt,
count(*) as invcommcount 
from users left join investments on investments.investor_id=users.uid group by 1,2,3,4,5,6,7')

investments1 <- sqldf ('select investments.*, 
CAST(contribution_in_paisa as DECIMAL)/(10000.0*invamt) as rowfractionamount,
invcommcount,
1000.0/CAST(invcommcount as DECIMAL) as partsperthousand from investments left join users1 
                       on  investments.investor_id=users1.uid')

# How each fraction of investor's pie is distributed among districts, states, month

pie_district <- sqldf('select investor_id , borrower_district, 
sum(rowfractionamount), sum(partsperthousand) , sum(contribution_in_paisa/10000.0) as amount, count(*) as count from investments1 
left join loan_profiles on investments1.loan_profile_id=loan_profiles.id group by 1,2 
having count(*)>4 and sum(partsperthousand) <1000
                       order by 3 desc ' )
 
pie_state <- sqldf('select investor_id , borrower_state, 
sum(rowfractionamount), sum(partsperthousand), sum(contribution_in_paisa/10000.0) as amount, count(*) as count from investments1 
left join loan_profiles on investments1.loan_profile_id=loan_profiles.id group by 1,2 having count(*)>4
and sum(partsperthousand) <1000
                      order by 3 desc ' )

pie_month <- sqldf('select investor_id , SUBSTR(published_date,1,7) as month, 
sum(rowfractionamount), sum(partsperthousand) , sum(contribution_in_paisa/10000.0) as amount, count(*) as count from investments1 
left join loan_profiles on investments1.loan_profile_id=loan_profiles.id group by 1,2 
having count(*)>4 and sum(partsperthousand) <1000
                       order by 3 desc ' )

pie_activity <- sqldf('select investor_id , activity, 
sum(rowfractionamount) as fractionamt, sum(partsperthousand) as partsperthousand, sum(contribution_in_paisa/10000.0) as amount, count(*) as count from investments1 
left join loan_profiles on investments1.loan_profile_id=loan_profiles.id group by 1,2 
having count(*)> 10 and sum(partsperthousand) <1000
                   order by 3 desc ' )

hist(pie_activity$count, breaks=100)

# sqldf('select distinct occupation from loan_profiles')

# location distribution
inv_grp2<- sqldf('select nationality_id ,city, state_or_province,country, sum(contribution_in_paisa/10000),
                 count(*), sum(contribution_in_paisa/10000)/count(*) as avgcommit from inv_coll group by 1,2,3,4 order by 5 desc ')

# investorjoining cohort distribution
inv_grp4<- sqldf('select SUBSTR(registration_date,1,7), sum(contribution_in_paisa/10000),
                 count(*), sum(contribution_in_paisa/10000)/count(*) as avgcommit from inv_coll 
                 group by 1 order by 1 ')



# View(loan_profiles)
# inv_grp3<- sqldf('select borrower_village,borrower_city,borrower_district,borrower_state 
  #                from loan_profiles group by 1,2,3,4 order by 4,3,2,1')

loan_cohorts <- sqldf('select SUBSTR(published_date,1,7), count(*)  from loan_profiles group by 1') 
# To view loan distribution by 


# View(inv_grp3)
inv_grp2 <- sqldf('select a.investor_id, a.sum(contribution_in_paisa/10000) as total_amount, a.count(*) as total_investments, b.state_or_province, b.nation, b.nationality from investments a left join users b on a.investor_id = b.uid group by 1 order by 2 desc ')

# Create utility matrix 

utl_activity<- dcast(pie_activity[1:3], investor_id ~ activity, sum )
utl_state<- dcast(pie_state[1:3], investor_id ~ borrower_state, sum )
utl_month<- dcast(pie_month[1:3], investor_id ~ month, sum )
utl_district<- dcast(pie_district[1:3], investor_id ~ borrower_district, sum )







