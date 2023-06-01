/*Cleaning Data in SQL queries




*/
select *
from PortfolioProject..NashvilleHousing





--1.Standardize Date Format----------------------------------------------------------------------------------------------------------------------------------------

select  SaleDate
from PortfolioProject..NashvilleHousing			 --the sales date in unnecessary format which is datetime, change it to yymmdd


select SaleDate, CONVERT(date,saledate)			 -- we want the column to appear in date format- we can see the different between two column
from PortfolioProject..NashvilleHousing		 	 -- but it doesn't store the new format in date
											

ALTER TABLE NashvilleHousing					 --use alter column to store date format in saledate, we can always change it back to datetime if we want
ALTER COLUMN  SaleDate date		 





--2.PopulateProperty Address Data--------------------------------------------------------------------------------------------------------------------------------

select * from NashvilleHousing					 --there is null value in property address, ParcelID is a reference to the Property Address.
order by 4



select *										 --JOIN the table by itself using ParcelID and UniqueID as parameter
from NashvilleHousing  as a						 --NULL address is a missing address based on the same ParcelID 
join NashvilleHousing as b						 --ISNULL is to replace the NULL value from Preperty Address
on a.ParcelID = b.ParcelID
and a.[UniqueID ] <> b.[UniqueID ]


select a.ParcelID, a.PropertyAddress,b.ParcelID, b.PropertyAddress, ISNULL(a.PropertyAddress,b.PropertyAddress)					 
from NashvilleHousing  as a						
join NashvilleHousing as b
on a.ParcelID = b.ParcelID
and a.[UniqueID ] <> b.[UniqueID ]
where a.PropertyAddress is null

UPDATE a
SET PropertyAddress = ISNULL(a.PropertyAddress,b.PropertyAddress)
from NashvilleHousing  as a						
join NashvilleHousing as b
on a.ParcelID = b.ParcelID
and a.[UniqueID ] <> b.[UniqueID ]
where a.PropertyAddress is null



--3 Separate the Address into Individual Columns (Address,City,State)-------------------------------------------------------------------------------------------

select PropertyAddress
from PortfolioProject..NashvilleHousing

/*
Notice that the address having comma(,) to divide the Address and the City. We use SUBSTRING to separate the 1st & 2nd part of the Address
The CHARINDEX function will search the comma(,) in the Address and specify the location in the text.
Here come the tricky part using CHARINDEX funtion inside SUBSTRING function. 

The first SUBSTRING start at 1st value, find comma and delete ,end and return to value. The comma(,) will appear in the text if (-1) not specify.
2nd part of the Address start after the comma(,) We are going to start at value with CHARINDEX (+1) indicate it will take 1 value after comma(,) and return PropertyAddres
*/

select SUBSTRING(PropertyAddress,1,CHARINDEX(',',PropertyAddress)-1) as Property_Address
	  --,CHARINDEX(',',PropertyAddress)
	  ,SUBSTRING(PropertyAddress,CHARINDEX(',',PropertyAddress)+1,LEN(PropertyAddress)) as Property_City
from PortfolioProject..NashvilleHousing

ALTER TABLE NashvilleHousing
ADD Property_Address nvarchar(225)
,Property_City nvarchar(225);

UPDATE NashvilleHousing
SET Property_Address = SUBSTRING(PropertyAddress,1,CHARINDEX(',',PropertyAddress)-1)
, Property_City = SUBSTRING(PropertyAddress,CHARINDEX(',',PropertyAddress)+1,LEN(PropertyAddress))






--We Also can Use PARSENAME--


select OwnerAddress
from PortfolioProject..NashvilleHousing


Select PARSENAME(REPLACE (OwnerAddress,',','.'),3) 
,PARSENAME(REPLACE (OwnerAddress,',','.'),2)
,PARSENAME(REPLACE (OwnerAddress,',','.'),1)
from PortfolioProject..NashvilleHousing



ALTER TABLE NashvilleHousing
ADD Owner_Address nvarchar(225)
,Owner_City nvarchar(225)
,Owner_State nvarchar(225)

UPDATE NashvilleHousing
SET Owner_Address = PARSENAME(REPLACE (OwnerAddress,',','.'),3)
,Owner_City = PARSENAME(REPLACE (OwnerAddress,',','.'),2)
,Owner_State = PARSENAME(REPLACE (OwnerAddress,',','.'),1)




--4.Change the Y n N to 'Yes' & 'No' in 'SoldAsVacant' field----------------------------------------------------------------------------------------------------

select distinct soldAsVacant, count(soldasvacant)
from NashvilleHousing
group by soldAsVacant
order by SoldAsVacant

UPDATE NashvilleHousing										--purposely change to Y and N. we can also use REPLACE function or CASE STATEMENT 
SET SoldAsVacant = REPLACE (SoldAsVacant,'Yes','Y')
,SoldAsVacant = REPLACE (SoldAsVacant,'No','N')


select SoldAsVacant
,CASE WHEN SoldAsVacant ='Y' THEN 'Yes'						--CASE statement will show the changes, we still need to update into the column
      WHEN SoldAsVacant ='N' THEN 'No'
	  ELSE SoldAsVacant
	  END
from PortfolioProject..NashvilleHousing

UPDATE NashvilleHousing										--Here an update using CASE STATEMENT
SET SoldAsVacant = CASE WHEN SoldAsVacant ='Y' THEN 'Yes'	
				   WHEN SoldAsVacant ='N' THEN 'No'
				   ELSE SoldAsVacant
				   END
				   from PortfolioProject..NashvilleHousing




--5.Removing Duplicate for learning purposes------------------------------------------------------------------------------------------------------------------------------------------
--Not a standard Practice to delete data that already in the databases. 

Select*
from PortfolioProject..NashvilleHousing


WITH RowNumCTE AS											--creating a CTE to remove Duplicate row
(

Select *, ROW_NUMBER () OVER(								--First we have to group the entire table and divide it using PARTITION by selected parameter
				PARTITION BY ParcelID,						--We try identify any duplicate as row_num more than 1 
				PropertyAddress,
				SalePrice,
				LegalReference
				ORDER BY
				UniqueID) as row_num
from PortfolioProject..NashvilleHousing
--order by ParcelID
)
DELETE
from RowNumCTE
where row_num >1
--order by PropertyAddress




--6.Remove Unused Data------------------------------------------------------------------------------------------------------------------------------------------

select *
from PortfolioProject..NashvilleHousing

ALTER TABLE PortfolioProject..NashvilleHousing
DROP COLUMN OwnerAddress,TaxDistrict,PropertyAddress,SaleDate