Create database if not exists Data_Cleaning;
use Data_cleaning;

drop table if exists data_cleaning;
CREATE TABLE data_cleaning (
	UniqueID DECIMAL(38,0) NOT NULL, 
	ParcelID VARCHAR(40) NOT NULL, 
	LandUse VARCHAR(40) NOT NULL, 
	PropertyAddress VARCHAR(40), 
	SaleDate DATE , 
	SalePrice DECIMAL(38,0) NOT NULL, 
	LegalReference VARCHAR(40) NOT NULL, 
	SoldAsVacant VARCHAR(5) NOT NULL, 
	OwnerName VARCHAR(40), 
	OwnerAddress VARCHAR(40), 
	Acreage DECIMAL(38,3), 
	TaxDistrict VARCHAR(40), 
	LandValue DECIMAL(38,3), 
	BuildingValue DECIMAL(38,3), 
	TotalValue DECIMAL(38,3), 
	YearBuilt DECIMAL(38,3), 
	Bedrooms DECIMAL(38,3), 
	FullBath DECIMAL(38,3), 
	HalfBath DECIMAL(38,3)
);

set session sql_mode = ' ';
LOAD DATA INFILE 
'c:/data_cleaning.csv'
into table `data_cleaning`
FIELDS TERMINATED BY ','
ENCLOSED BY '"'
LINES TERMINATED BY '\n'
IGNORE 1 ROWS;

select * from data_cleaning limit 1000;

SELECT SoldAsVacant , count(SoldAsVacant)
from data_cleaning
group by SoldAsVacant ; -- This indicates that we have to tranform this column to contain uniform format i.e with yes,no or y,n





-- 1. Conversion of Property address in proper format i.e separating city,state.

select * from data_cleaning 
where PropertyAddress = '';


-- we are trying to get reed of data with no property address using self join method

select b.PropertyAddress
 from data_cleaning a
join data_cleaning b
 on a.ParcelID = b.ParcelID
  and a.UniqueID <> b.UniqueID
where a.PropertyAddress = '';

update data_cleaning a 
left join data_cleaning b 
on a.ParcelID = b.ParcelID 
and a.UniqueId <> b.UniqueID
set a.PropertyAddress = b.PropertyAddress
where a.PropertyAddress = '';


-- 2. Breaking Address into individual columns (Address,city,state)

-- we make use of locate function to help us separating this


select 
substring(PropertyAddress,1,locate(',',PropertyAddress)-1) as address,
substring(PropertyAddress,locate(',',PropertyAddress) + 1,length(PropertyAddress)) as city
from data_cleaning;

-- we will create 2 new columns to hold these values

alter table data_cleaning
add column PropAddress varchar(50),
add column PropCity varchar(60);

update data_cleaning
set PropAddress = substring(PropertyAddress,1,locate(',',PropertyAddress)-1) ;

update data_cleaning
set PropCity = substring(PropertyAddress,locate(',',PropertyAddress) + 1,length(PropertyAddress));


-- Doing same for owner adress column
-- Here we will step by step alot the address as here we have 2 delimiters

alter table data_cleaning 
add column OwnerAdd varchar(50),
add column OwnerCity Varchar(50),
add column OwnerState varchar(20);

select * from data_cleaning limit 10;

update data_cleaning
set OwnerAdd = substring(OwnerAddress,1,locate(',',OwnerAddress) -1 );

-- here we create proxy city so that we could break this to get our city for owner

alter table data_cleaning
add column proxyCity varchar(50),
add column ProxyState varchar(50);

select * from data_cleaning limit 19;

-- here we create proxy city to extract city and state for our work


update data_cleaning
set proxyCity = substring(OwnerAddress , locate(',',OwnerAddress)+1,length(OwnerAddress));

update data_cleaning
set OwnerCity = substring(proxyCity ,1, locate(',',proxyCity)-1);

update data_cleaning
set OwnerState = substring(proxyCity , locate(',',proxyCity)+1,length(proxyCity));


-- 3. change Y and N in SoldAsVacant to Yes and NO

-- first we check what is the count of different type of values in this column

SELECT SoldAsVacant , count(SoldAsVacant)
from data_cleaning                              -- here we are trying to see in what proportion we have Yes,No,Y,N in our column SoldAsVacant
group by SoldAsVacant
order by 2 ;

select SoldAsVacant ,
	case when SoldAsVacant = 'Y' then 'Yes'
		when SoldAsVacant = 'N' then 'No'         -- Here we are create a output column where we apply the change using cases.
		else SoldAsVacant
	end
from data_cleaning;

update data_cleaning
set SoldAsVacant = case when SoldAsVacant = 'Y' then 'Yes'   -- Now we update our original column using the above technique
	when SoldAsVacant = 'N' then 'No'
    else SoldAsVacant
    end;


-- 4. Remove Duplicates and Null value present at various fields .
-- we make use of CTE to help us find duplicate entries. Here we had to do inner join between our table and the cte we are making
-- for deletion

with CTE as(
select UniqueID,
row_number() over (
partition by ParcelID,
PropertyAddress,
SalePrice,
SaleDate,
LegalReference
order by UniqueId ) row_num
from data_cleaning 
)
Delete ddc from data_cleaning ddc 
inner join CTE c on c.UniqueID = ddc.UniqueID
where row_num > 1 ;


-- deletion of NUll values.
-- here we observe that Field OwnerName contains some blank places. we will remove those as they wont be contibuting to our analysis

delete from data_cleaning where OwnerName = '' ;


-- 5 . Delete Unused Columns that were present or we created for our purpose

select * from data_cleaning ;

-- upon inspection I did find 2 column which were created early i.e proxycity , proxystate .
-- As we have created proper address for property address and owner address , now we delete the original column for these two .
-- we also delete tax district as we don't have any use of it.

alter table data_cleaning 
drop column proxyCity ,
drop column ProxyState ,
drop column PropertyAddress,
drop column OwnerAddress ,
drop column TaxDistrict;

-- deletion is now complete



-------------------------------------------------- Here we have completed cleaning our data ------------------------------------------ 










