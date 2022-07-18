select *
from [Data Cleaning].dbo.NashvilleHousing

--standardize date format
select saledateconverted, convert(date, saledate)
from [Data Cleaning].dbo.NashvilleHousing

update NashvilleHousing
set	SaleDate = CONVERT(date,saledate)

alter table nashvillehousing
add saledateconverted date;

update NashvilleHousing
set saledateconverted = CONVERT(date,saledate)

--alter table nashvillehousing
--drop column saledatconverted

--populate property address data
select *
from [Data Cleaning].dbo.NashvilleHousing
where PropertyAddress is null
order by ParcelID

select *
from [Data Cleaning].dbo.NashvilleHousing
--where PropertyAddress is null
order by ParcelID

--join the database to itsself, then puts b.propety into a.property if a. is blank
select a.ParcelID, a.PropertyAddress, b.ParcelID, b.PropertyAddress, ISNULL(a.PropertyAddress, b.PropertyAddress)
from [Data Cleaning].dbo.NashvilleHousing as a
join [Data Cleaning].dbo.NashvilleHousing as b
	on	a.ParcelID = b.ParcelID
	and a.[UniqueID ] <> b.[UniqueID ]
where a.PropertyAddress is null

--updates above script to permanent
update a
set PropertyAddress = ISNULL(a.PropertyAddress, b.PropertyAddress)
from [Data Cleaning].dbo.NashvilleHousing as a
join [Data Cleaning].dbo.NashvilleHousing as b
	on	a.ParcelID = b.ParcelID
	and a.[UniqueID ] <> b.[UniqueID ]
where a.PropertyAddress is null

--breaking out address into individual columns
select PropertyAddress
from [Data Cleaning].dbo.NashvilleHousing

--looking at property address uptil the comma
select 
SUBSTRING(propertyaddress, 1, charindex(',', PropertyAddress)-1) as address
from [Data Cleaning].dbo.NashvilleHousing

--splits one column into two 
select 
SUBSTRING(propertyaddress, 1, charindex(',', PropertyAddress)-1) as address
, SUBSTRING(propertyaddress, charindex(',', PropertyAddress)+1, len(propertyaddress)) as city
from [Data Cleaning].dbo.NashvilleHousing

--add two columns
alter table nashvillehousing
add address nvarchar(255);

update NashvilleHousing
set address = SUBSTRING(propertyaddress, 1, charindex(',', PropertyAddress)-1)

alter table nashvillehousing
add city nvarchar(255);

update NashvilleHousing
set city = SUBSTRING(propertyaddress, charindex(',', PropertyAddress)+1, len(propertyaddress))

--split owver address
select OwnerAddress
from [Data Cleaning].dbo.NashvilleHousing

select
PARSENAME(REPLACE(Owneraddress, ',', '.'), 3)
, PARSENAME(REPLACE(Owneraddress, ',', '.'), 2)
, PARSENAME(REPLACE(Owneraddress, ',', '.'), 1)
from [Data Cleaning].dbo.NashvilleHousing

--add three columns
alter table nashvillehousing
add ownerstreet nvarchar(255);

update NashvilleHousing
set ownerstreet = PARSENAME(REPLACE(Owneraddress, ',', '.'), 3)

alter table nashvillehousing
add ownercity nvarchar(255);

update NashvilleHousing
set ownercity = PARSENAME(REPLACE(Owneraddress, ',', '.'), 2)

alter table nashvillehousing
add ownerstate nvarchar(255);

update NashvilleHousing
set ownerstate = PARSENAME(REPLACE(Owneraddress, ',', '.'), 1)

select *
from [Data Cleaning].dbo.NashvilleHousing

--change Y and N to Yes and No in 'Sold as Vacant' field
select Distinct(SoldAsVacant) 
from [Data Cleaning].dbo.NashvilleHousing

select Distinct(SoldAsVacant), COUNT(soldasvacant)
from [Data Cleaning].dbo.NashvilleHousing
group	by SoldAsVacant
order by 2

--use a case statement
select SoldAsVacant
, case when SoldAsVacant = 'Y' Then 'Yes'
		when SoldAsVacant = 'N' then 'No'
		else SoldAsVacant
		end
from [Data Cleaning].dbo.NashvilleHousing

update NashvilleHousing
set SoldAsVacant = case when SoldAsVacant = 'Y' Then 'Yes'
		when SoldAsVacant = 'N' then 'No'
		else SoldAsVacant
		end
from [Data Cleaning].dbo.NashvilleHousing

--remove duplicates

WITH RowNumCTE as ( --create cte and then select all duplicates
select *,
	row_number() over (
	partition by parcelid,
				propertyaddress,
				saleprice,
				saledate,
				legalreference
				order by uniqueid
				) as row_num
from [Data Cleaning].dbo.NashvilleHousing
)
select *
from RowNumCTE
where row_num > 1

WITH RowNumCTE as ( --create cte and delete duplicates
select *,
	row_number() over (
	partition by parcelid,
				propertyaddress,
				saleprice,
				saledate,
				legalreference
				order by uniqueid
				) as row_num
from [Data Cleaning].dbo.NashvilleHousing
)
delete
from RowNumCTE
where row_num > 1


select *
from [Data Cleaning].dbo.NashvilleHousing

--delete unused columns
alter table [Data Cleaning].dbo.NashvilleHousing
drop column owneraddress, propertyaddress

alter table [Data Cleaning].dbo.NashvilleHousing
drop column saledate