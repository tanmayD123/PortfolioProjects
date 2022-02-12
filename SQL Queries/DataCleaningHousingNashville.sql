-- Exploring the dataset
SELECT TOP 1000 *
FROM Portfolio..NashvilleHousing


--Changing the format of saleDate
SELECT SaleDate, CONVERT(date, SaleDate)
FROM Portfolio..NashvilleHousing

ALTER TABLE NashvilleHousing
ADD SaleDateConverted Date

UPDATE NashvilleHousing
SET SaleDateConverted = CONVERT(date, SaleDate)


--Alternate method for formatting date
--SELECT SaleDate, FORMAT(SaleDate, 'yyyy-MM-dd') as Date
--FROM Portfolio..NashvilleHousing


------------------------------------------------------------------------------------------------------------------
-- Filling null PropertyAddress 

SELECT a.ParcelID, a.PropertyAddress, b.ParcelID, b.PropertyAddress, ISNULL(a.PropertyAddress, b.PropertyAddress)
FROM Portfolio..NashvilleHousing a
JOIN Portfolio..NashvilleHousing b
	on a.ParcelID = b.ParcelID
	AND a.[UniqueID ] != b.[UniqueID ]
WHERE a.PropertyAddress is null


UPDATE a
SET PropertyAddress = ISNULL(a.PropertyAddress, b.PropertyAddress)
FROM Portfolio..NashvilleHousing a
JOIN Portfolio..NashvilleHousing b
	on a.ParcelID = b.ParcelID
	AND a.[UniqueID ] != b.[UniqueID ]
WHERE a.PropertyAddress is null

-----------------------------------------------------------------------------------------------------------

--Seperating Address and City from propertyAddress

SELECT SUBSTRING(PropertyAddress, 1, CHARINDEX(',', PropertyAddress) -1 ) as address
	, SUBSTRING(PropertyAddress, CHARINDEX(',', PropertyAddress) +1 , LEN(PropertyAddress)) as state
FROM Portfolio..NashvilleHousing

ALTER TABLE NashvilleHousing
ADD propertySplitAddress nvarchar(255)

UPDATE NashvilleHousing
SET propertySplitAddress = SUBSTRING(PropertyAddress, 1, CHARINDEX(',', PropertyAddress) -1 )

ALTER TABLE NashvilleHousing
ADD propertySplitCity nvarchar(255)

UPDATE NashvilleHousing
SET propertySplitCity = SUBSTRING(PropertyAddress, CHARINDEX(',', PropertyAddress) +1 , LEN(PropertyAddress))

------------------------------------------------------------------------------------------------------------------------

-- Seperating OwnerAdress 

SELECT PARSENAME(REPLACE(OwnerAddress, ',' , '.'), 3),
	PARSENAME(REPLACE(OwnerAddress, ',' , '.'), 2),
	PARSENAME(REPLACE(OwnerAddress, ',' , '.'), 1)
FROM Portfolio..NashvilleHousing

ALTER TABLE NashvilleHousing
Add OwnerSplitAddress Nvarchar(255)

Update NashvilleHousing
SET OwnerSplitAddress = PARSENAME(REPLACE(OwnerAddress, ',', '.') , 3)


ALTER TABLE NashvilleHousing
Add OwnerSplitCity Nvarchar(255)

Update NashvilleHousing
SET OwnerSplitCity = PARSENAME(REPLACE(OwnerAddress, ',', '.') , 2)


ALTER TABLE NashvilleHousing
Add OwnerSplitState Nvarchar(255)

Update NashvilleHousing
SET OwnerSplitState = PARSENAME(REPLACE(OwnerAddress, ',', '.') , 1)

------------------------------------------------------------------------------------------------------------------------

-- Changing yes and No to Y and N in Sold As Vacant (Because there are YES, NO, Y, N when we run DISTINCT)

SELECT DISTINCT(SoldAsVacant)
FROM Portfolio..NashvilleHousing

Select SoldAsVacant
, CASE When SoldAsVacant = 'Y' THEN 'Yes'
	   When SoldAsVacant = 'N' THEN 'No'
	   ELSE SoldAsVacant
	   END
From Portfolio..NashvilleHousing


Update NashvilleHousing
SET SoldAsVacant = CASE When SoldAsVacant = 'Y' THEN 'Yes'
	   When SoldAsVacant = 'N' THEN 'No'
	   ELSE SoldAsVacant
	   END

------------------------------------------------------------------------------------------------------------------------

-- Remove Duplicates 
-- At your own RISK, its NOT a standard procesure to delete anything from a database


WITH RowNumCTE AS(
Select *,
	ROW_NUMBER() OVER (
	PARTITION BY ParcelID,
				 PropertyAddress,
				 SalePrice,
				 SaleDate,
				 LegalReference
				 ORDER BY
					UniqueID
					) row_num

From Portfolio.dbo.NashvilleHousing
)
DELETE
From RowNumCTE
Where row_num > 1

------------------------------------------------------------------------------------------------------------------------
--Dropping useless columns

ALTER TABLE Portfolio.dbo.NashvilleHousing
DROP COLUMN OwnerAddress, TaxDistrict, PropertyAddress, SaleDate
