---***** DATA CLEANING ******-------

select * from NashvilleHousing;


--Populating Addrress
select * from NashvilleHousing WHERE
PropertyAddress is NULL

select a.ParcelID, a.PropertyAddress, b.ParcelID, b.PropertyAddress, ISNULL(a.PropertyAddress,b.PropertyAddress)
from NashvilleHousing a
JOIN NashvilleHousing b 
on a.ParcelID=b.ParcelID and 
a.UniqueID <> b.UniqueID
where a.PropertyAddress is NULL


UPDATE a 
SET PropertyAddress = ISNULL(a.PropertyAddress,b.PropertyAddress)
from NashvilleHousing a
JOIN NashvilleHousing b 
on a.ParcelID=b.ParcelID and 
a.UniqueID <> b.UniqueID
where a.PropertyAddress is NULL





--Breaking out address into individual columns
select PropertyAddress, 
substring(PropertyAddress, 1, CHARINDEX(',', PropertyAddress) -1) as Address,
substring(PropertyAddress, CHARINDEX(',', PropertyAddress) +1, LEN(PropertyAddress)) as Address
from NashvilleHousing


ALTER TABLE NashvilleHousing
ADD PropertyAddressSplit nvarchar(255);

Update NashvilleHousing
SET PropertyAddressSplit = substring(PropertyAddress, 1, CHARINDEX(',', PropertyAddress) -1)

ALTER TABLE NashvilleHousing
add PropertyAddSplitCity nvarchar(255);


Update NashvilleHousing
set PropertyAddSplitCity = substring(PropertyAddress, CHARINDEX(',', PropertyAddress) +1, LEN(PropertyAddress)) 


select * from NashvilleHousing;


--Splitting Owner Address
SELECT 
    PARSENAME(REPLACE(OwnerAddress, ',', '.'), 3) as OwnerAddressSplit,
    PARSENAME(REPLACE(OwnerAddress, ',', '.'), 2) as OwnerAddressCity,
    PARSENAME(REPLACE(OwnerAddress, ',', '.'), 1) as OwnerAddressState
FROM NashvilleHousing;

ALTER TABLE NashvilleHousing
ADD OwnerAddressSplit nvarchar(200);

UPDATE NashvilleHousing
SET OwnerAddressSplit = PARSENAME(REPLACE(OwnerAddress, ',', '.'), 3);


ALTER TABLE NashvilleHousing
ADD OwnerAddressCity nvarchar(200);

UPDATE NashvilleHousing
SET OwnerAddressCity = PARSENAME(REPLACE(OwnerAddress, ',','.'), 2)

ALTER TABLE NashvilleHousing
ADD OwnerAddressState nvarchar(200);

UPDATE NashvilleHousing
SET OwnerAddressState = PARSENAME(REPLACE(OwnerAddress, ',', '.'), 1);

select * from NashvilleHousing;



--Changing Y and N to Yes and No in SoldAsVAcant column 

select distinct(SoldAsVacant), COUNT(SoldAsVacant)
from NashvilleHousing
group by SoldAsVacant
order by 2;



select SoldAsVacant, 
CASE when SoldAsVacant = 'Y' then 'Yes'
when SoldAsVacant='N' then 'No'
Else SoldAsVacant
End
from NashvilleHousing


Update NashvilleHousing
SET SoldAsVacant = CASE when SoldAsVacant = 'Y' then 'Yes'
when SoldAsVacant='N' then 'No'
Else SoldAsVacant
End


--Remove Duplicates  using (CTE AND WINDOW FUNCTIONS)

WITH rownumCTE AS(
select *, ROW_NUMBER() OVER(
        PARTITION BY ParcelID,
        PropertyAddress,
        SalePrice,
        SaleDate,
        LegalReference
        Order by 
        UniqueID 
    ) row_num
    from NashvilleHousing)
    
select *
from rownumCTE
where row_num > 1
Order by PropertyAddress


WITH rownumCTE AS(
select *, ROW_NUMBER() OVER(
        PARTITION BY ParcelID,
        PropertyAddress,
        SalePrice,
        SaleDate,
        LegalReference
        Order by 
        UniqueID 
    ) row_num
    from NashvilleHousing)
    
delete
from rownumCTE
where row_num > 1


--Delete Unused data

Alter table NashvilleHousing
DROP column PropertyAddress, TaxDistrict, OwnerAddress, SaleDate

Select * from NashvilleHousing




