--create view kam_CustomerPBI12182023 as
WITH Query1 as 
(select 
[Customer ID] as CustID, 
Email, 
[Residential Address] as HomeAddress,
Membership, 
[Pass #] as PassNumber,
Age, 
case when Age >= 65 then 'Senior' 
when Age between 19 and 64.9 then 'Adult'
when Age between 13 and 18.9 then 'Youth'
when Age < 13 then 'Child'
else null end as AgeGroup, 
Gndr as Gender, 
[Package Name] as PackageName,
convert (varchar, Sold, 23) as SoldDate,
convert (varchar, DOB, 23) as BirthDate,
convert(varchar(30),Effective, 23)as EffectiveDate,
convert (varchar(30), Expires, 23) as ExpireDate
from kam_customers_12182023),

/*Query2 as 
(select 
*,
case when PackageName in ('General 3-Month - Adult','General Bi-Weekly - Adult','Platinum Annual - Adult',
'General 1-Month - Adult','Gold Bi-Weekly - Adult','General 6-Month - Adult','General 1-Month - Young Adult','General Annual - Adult') 
then 'Adult' 

when PackageName in ('General 6-Month - Young Adult','General Bi-Weekly - Young Adult','Gold Bi-Weekly - Young Adult',
'Gold Annual - Young Adult','General Annual - Young Adult','General 3-Month - Young Adult') 
then 'Young Adult'

when PackageName in ('General 6-Month - Youth','General Bi-Weekly - Youth','General 3-Month - Youth',
'General 1-Month - Youth','General Annual - Youth')
then 'Youth'

when PackageName in ('General 3-Month - Family','General 1-Month - Family','Platinum Bi-Weekly - Family','General Annual - Family',
'General Bi-Weekly - Family','General 6-Month - Family','Gold Bi-Weekly - Family')
then 'Family'

when PackageName in ('Platinum Bi-Weekly - Senior','General 1-Month - Senior','Platinum Annual - Senior','Gold Bi-Weekly - Senior',
'General Annual - Senior','Gold Annual - Senior','General 3-Month - Senior','General Bi-Weekly - Senior',
'General 6-Month - Senior') 
then 'Senior' 

When PackageName in ('General 1-Month - Child','General Annual - Child','General 6-Month - Child',
'General Bi-Weekly - Child','General 3-Month - Child') 
then 'Child' 
else null end as PackageAgeGroup
from Query1)
select * from Query2*/
Query2 as 
(select 
*, 
case when  PackageName in
('General 6-Month - Young Adult','General 6-Month - Youth','General 3-Month - Family',
'Platinum Bi-Weekly - Senior','General 1-Month - Family','General Bi-Weekly - Young Adult',
'General 1-Month - Child','Gold Bi-Weekly - Young Adult','Platinum Bi-Weekly - Adult',
'Platinum Bi-Weekly - Family','General Annual - Child','General 3-Month - Adult','General Bi-Weekly - Youth',
'General 1-Month - Senior','Platinum Annual - Senior','Gold Bi-Weekly - Senior',
'General 6-Month - Child','General Bi-Weekly - Adult','General Annual - Senior',
'General 3-Month - Youth','Gold Annual - Senior','Gold Annual - Young Adult',
'General Annual - Family','General 1-Month - Youth','General Bi-Weekly - Family',
'General 3-Month - Senior','General Bi-Weekly - Senior','Platinum Annual - Adult',
'Gold Bi-Weekly - Adult','General 6-Month - Family','General Bi-Weekly - Child',
'General 1-Month - Adult','Gold Bi-Weekly - Family','General Annual - Young Adult',
'General Annual - Youth','General 3-Month - Young Adult','General 3-Month - Child',
'General 6-Month - Adult','General 1-Month - Young Adult','General Annual - Adult',
'General 6-Month - Senior')
then 'Membership' 
when PackageName in (
'Program Pass 3-Month - Family','Program Pass Bi-Weekly - Senior','Program Pass Bi-Weekly - Family',
'Program Pass 1-Month - Senior','Program Pass 3-Month - Child','Program Pass Bi-Weekly - Youth',
'Program Pass Annual - Family','Program Pass 6-Month - Youth','Program Pass 6-Month - Young Adult',
'Program Pass 6-Month - Adult','Program Pass Annual - Youth','Program Pass Annual - Young Adult',
'Program Pass 3-Month - Young Adult','Program Pass 3-Month - Adult','Program Pass 6-Month - Family',
'Program Pass Annual - Child','Program Pass 1-Month - Young Adult','Program Pass Annual - Adult',
'Program Pass 6-Month - Senior','Program Pass 3-Month - Youth','Program Pass 6-Month - Child',
'Program Pass Bi-Weekly - Adult', 'Program Pass 1-Month - Youth','Program Pass Bi-Weekly - Young Adult',
'Program Pass 3-Month - Senior', 'Program Pass Annual - Senior','Program Pass 1-Month - Child',
'Program Pass 1-Month - Adult','Program Pass Bi-Weekly - Child','Program Pass 1-Month - Family')
then 'Program Pass' 
when PackageName in ('1-Week Trial Membership - Family', '5 Days 5 Ways Punch Pass', '1-Week Trial Membership',
'3-Day Trial Membership', '12 Days of Christmas Punch Pass','2-Week Out-of-Town Pass') 
then 'Promotion' 
when PackageName in ('Staff Bi-Weekly - Family','Staff Bi-Weekly - Individual') 
then 'Staff'
when PackageName in ('Volunteer Bi-Weekly - Individual')
then 'Volunteer'
when PackageName in ('Interactive Centre Pass - Preschooler (3-5)','Interactive Centre Pass - Infant (<1)',
'Interactive Centre Pass - Youth (6-18)','Interactive Centre Pass - Adult (19+)',
'Interactive Centre Pass - Toddler (1-2)') 
then 'Interactive Centre Pass'
when PackageName in ('Teen Summer Membership')
then 'Teen Summer'
else PackageName 
end as Category
--'Swim - Legacy 14 Punch Pass'
from Query1 ),
Query3 as 
(select * from Query2 
where Category like 'Membership'),

Query4 as
(select *, 
row_number () over (partition by CustID order by EffectiveDate) as RowNumberEffective,
row_number () over (partition by CustID order by ExpireDate desc) as RowNumberExpire
from Query3),

Query5 as 
(select * , 
case when RowNumberEffective = 1 then EffectiveDate else null end as FirstEffectiveDate, 
case when RowNumberEffective =1 then PackageName else null end as FirstPackageName,
case when RowNumberExpire =1 then ExpireDate else null end as LastExpireDate,
case when RowNumberExpire =1 then PackageName else null end as LastPackageName
from Query4)

select 
CustID, 
BirthDate,
Age, 
Gender, 
Category,
AgeGroup, 
'Kamloops' as Centre, 
case when PackageName like '%Adult%' then 'Adult'
when PackageName like '%Family%' then 'Family'
when PackageName like '%Young Adult%' then 'Young Adult'
when PackageName like '%Youth%' then 'Youth'
when PackageName like '%Senior%' then 'Senior'
when PackageName like '%Child%' then 'Child'
else null end as PackageAgeGroup,
case when PackageName like '%General%' then 'General'
when PackageName like '%Platinum%'  then 'Platinum'
when PackageName like '%Gold%' then 'Gold' 
else PackageName end as PackageType, 
case when PackageName like '%Bi-Weekly%' then 'Bi-Weekly' 
when PackageName like '%Annual%' then 'Annual'
when PackageName like '%1-Month%' then '1-Month'
when PackageName like '%3-Month%' then '3-Month'
when PackageName like '%6-Month%' then '6-Month'
else PackageName end as PackageDuration,
PackageName, 
SoldDate, 
EffectiveDate, 
ExpireDate, 
RowNumberEffective, 
RowNumberExpire, 
FirstEffectiveDate, 
FirstPackageName, 
LastExpireDate, 
LastPackageName  
from Query5


