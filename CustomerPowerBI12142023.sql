--create view CustomerPowerBI_12142023 as 
WITH ygv_customers_12142023 as 
(select *, 'Individual' as Category from ygv_individual_12142023
UNION
select *, 'Family' as Category from ygv_family_12142023
UNION
select *, 
case when [Package Name] like '%Community%' then 'Community'
when [Package Name]like '%Employee%' then 'Staff'
when [Package Name] like '%HFR%' then 'INT/HFR Partnership' 
else [Package Name] end as Category from ygv_community_intl_staff_12142023 
UNION
select *, 'Promotions' as Category from ygv_promotions_bay_bck_12142023
UNION 
select *, 'Student Wellness' as Category from ygv_customers_studentwellness_12142023
UNION
select *, 'Promotions' as Category from ygv_promotions_RLY_LAN_12142023
UNION
select *, 'Promotions' as Category from ygv_promotions_TLY_12142023
),
census_cohort as 
(select * 
from ygv_customers_12142023
where [Package Name] in 
('Bettie Allard - Family Membership - Annual',
'Bettie Allard - Family Membership - BiWeekly',
'Bettie Allard - Family Plus Membership - BiWeekly',
'Bettie Allard - Individual Membership (19+) Annual',
'Bettie Allard - INT/HFR Partnership',
'Bettie Allard- Individual Membership(19+)BiWeekly',
'Bettie Allard -Individual Plus Membership-Annual',
'Bettie Allard -Individual Plus Membership-BiWeekly',
'Bettie Allard-Individual Membership (0-18) Annual',
'Bettie Allard-Individual Membership (0-18)Biweekly',
'Bettie Allard - Student Wellness Membership.',
'Chilliwack - Family Membership - Annual',
'Chilliwack - Family Membership - BiWeekly',
'Chilliwack - Individual Membership (0-18) Annual',
'Chilliwack - Individual Membership (0-18) BiWeekly',
'Chilliwack - Individual Membership (19+) Annual',
'Chilliwack - Individual Membership (19+) BiWeekly',
'Chilliwack - Student Wellness Membership.',
'Community Membership - 1 year',
'Community Membership - 3 months',
'Community Membership - 6 months',
'Community Membership - 6 weeks',
'Community Membership - Honorary',
'Community Membership - Honorary Plus',
'Community Membership - Sept 2023 - Aug 2024',
'Langara - Family Membership - BiWeekly',
'Langara - Full Time Student',
'Langara - Individual Membership (0-18) Annual',
'Langara - Individual Membership (0-18) BiWeekly',
'Langara - Individual Membership (19+) BiWeekly',
'Langara - Individual Membership (19+) Annual',
'Langara - INT/HFR Partnership',
'Langara Only Family Pass - Annual',
'Langara Only Family Pass - Bi-Weekly',
'Langara Only Pass (0-18) Annual',
'Langara Only Pass (0-18) Bi-Weekly',
'Langara Only Pass (19+) Annual',
'Langara Only Pass (19+) Bi-Weekly',
'Langara - Student Wellness Membership.',
'Robert Lee - Family Membership - Annual',
'Robert Lee - Family Membership - BiWeekly',
'Robert Lee - Family Plus Membership - Annual',
'Robert Lee - Family Plus Membership - BiWeekly',
'Robert Lee - Highschool/HFR Partnership',
'Robert Lee - Individual Membership (0-18) Annual',
'Robert Lee - Individual Membership (0-18) BiWeekly',
'Robert Lee - Individual Membership (19+) Annual',
'Robert Lee - Individual Membership (19+) BiWeekly',
'Robert Lee - Individual Plus Membership - Annual',
'Robert Lee - Individual Plus Membership - BiWeekly',
'Robert Lee - INT/HFR Partnership',
'Robert Lee - Student Wellness Membership.',
'Tong Louie - Family Membership - Annual',
'Tong Louie - Family Membership - BiWeekly',
'Tong Louie - Family Plus Membership - Annual',
'Tong Louie - Family Plus Membership - BiWeekly',
'Tong Louie - Full Time Student - Annual',
'Tong Louie - Full Time Student - BiWeekly',
'Tong Louie - Individual Membership (0-18) Annual',
'Tong Louie - Individual Membership (0-18) BiWeekly',
'Tong Louie - Individual Membership (19+) Annual',
'Tong Louie - Individual Membership (19+) BiWeekly',
'Tong Louie - Individual Plus Membership - Annual',
'Tong Louie - Individual Plus Membership - BiWeekly',
'Tong Louie - INT/HFR Partnership',
'Tong Louie - Student Wellness Membership.')),

Query1 as 
(select
--ID, --an added primary key ID using alter table
[Customer ID] as CustID, 
--Membership, 
[Pass #] as PassNumber,
Age as Age, 
case when Age >= 65 then 'Senior' 
when Age between 19 and 64.9 then 'Adult'
when Age between 13 and 18.9 then 'Youth'
when Age < 13 then 'Child'
else null end as AgeGroup, 
Gndr as Gender,
Category,
[Residential Address] as HomeAddress,
case when [Package Name] like 'Langara Only Family Pass - Annual' then 'Langara Family Membership - Annual' 
when [Package Name] like 'Langara Only Family Pass - Bi-Weekly' then 'Langara Family Membership - Bi-Weekly'
when [Package Name] like 'Langara Only Pass (0-18) Annual' then 'Langara Individual Membership (0-18) - Annual'
when [Package Name] like 'Langara Only Pass (0-18) Bi-Weekly' then 'Langara Individual Membership (0-18) - Bi-Weekly'
when [Package Name] like 'Langara Only Pass (19+) Annual' then 'Langara Individual Membership (19+) - Annual'
when [Package Name] like 'Langara Only Pass (19+) Bi-Weekly' then 'Langara Individual Membership (19+) - Bi-Weekly'
else [Package Name] end as PackageName, --this column has multiple data types
Case when Suspended LIKE '%Suspended%' Then Suspended 
else Null End as Suspended,

--cast(Suspended as varchar(60)) as Suspended,
--datediff(year,DOB,min(effective)) as Age, 
convert (varchar, Sold, 23) as SoldDate,
convert (varchar, DOB, 23) as BirthDate,
convert(varchar(30),Effective, 23)as EffectiveDate,
convert (varchar(30), Expires, 23) as ExpireDate

from census_cohort
--union select *, 'Promo' as Category from dbo.customers_ygv_promo_10022023

),
Query1b as
(select *, 
row_number () over (partition by CustID order by EffectiveDate) as RowNumberEffective,
row_number () over (partition by CustID order by ExpireDate desc) as RowNumberExpire
from Query1),

Query2 as 
(select * , 
case when RowNumberEffective = 1 then EffectiveDate else null end as FirstEffectiveDate, 
case when RowNumberEffective =1 then PackageName else null end as FirstPackageName,
case when RowNumberExpire =1 then ExpireDate else null end as LastExpireDate,
case when RowNumberExpire =1 then PackageName else null end as LastPackageName
from Query1b)

select 
distinct CustID, 
BirthDate,
Age, 
Gender, 
Category,
AgeGroup, 
 case when PackageName like '%Tong Louie%' then 'Tong Louie'
 when PackageName like '%Robert Lee%' then 'Robert Lee'
 when PackageName like '%Chilliwack%' then 'Bob Chan-Kent'
 when PackageName like '%Langara%' then 'Langara'
 when PackageName like '%Bettie Allard%' then 'Bettie Allard'
 else null end as Centre,
 case when PackageName like '%Individual Membership%' then 'Individual'
 when PackageName like '%Individual Plus%' then 'Individual Plus'
 when PackageName like '%Family Membership%' then 'Family'
 when PackageName like '%Family Plus%' then 'Family Plus'
 when PackageName like '%Full Time Student%' then 'Student'
 when PackageName like '%Day Pass%' then 'Day Pass'
 when PackageName like '%INT/HFR%' then 'INT/HFR Partnership'
 when PackageName like '%Highschool/HFR%' then 'INT/HFR Partnership'
 when PackageName like '%Student Wellness Membership%' then 'Student Wellness'
 when PackageName like '%Community%' then 'Community'
 else PackageName end as PackageType,
 case when PackageName like '%BiWeekly%' then 'Bi-Weekly'
 when PackageName like '%Bi-Weekly%' then 'Bi-Weekly'
 when PackageName like '%Annual%' then 'Annual'
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
from Query2
order by CustID 


