
/*
--SQL Portfolio Project
--Nashville Housing - Cleaning data in SQL query

--Features and skills used: Data cleaning, Alter, Update, Convert, Join, CTE, Substring, ISNULL, Charindex, Len, Parsename, Replace, Case statement, Count, Row_Number
*/

USE HousingProject
GO

SELECT *
FROM NashvilleHousing

--------------------------------------------------------------------------------------------------------------------------
--Standarize Date Format

SELECT SaleDate
FROM NashvilleHousing

UPDATE NashvilleHousing
SET SaleDate = CONVERT(Date,SaleDate)

--If it doesn't update

ALTER TABLE NashvilleHousing
ADD SaleDateConverted date

UPDATE NashvilleHousing
SET SaleDateConverted = CONVERT(date, SaleDate)

ALTER TABLE NashvilleHousing
DROP COLUMN SaleDate

--------------------------------------------------------------------------------------------------------------------------
-- Populate Property Address data

SELECT *
FROM NashvilleHousing
--WHERE PropertyAddress IS NULL
ORDER BY ParcelID

--Self join

SELECT a.ParcelID, a.PropertyAddress, b.ParcelID, b.PropertyAddress, ISNULL(a.PropertyAddress, b.PropertyAddress)
FROM NashvilleHousing a
JOIN NashvilleHousing b
	ON a.ParcelID = b.ParcelID
	AND a.UniqueID <> b.UniqueID
WHERE a.PropertyAddress IS NULL

UPDATE a
SET PropertyAddress = ISNULL(a.PropertyAddress, b.PropertyAddress)
FROM NashvilleHousing a
JOIN NashvilleHousing b
	ON a.ParcelID = b.ParcelID
	AND a.UniqueID <> b.UniqueID
WHERE a.PropertyAddress IS NULL


 --------------------------------------------------------------------------------------------------------------------------
 --Breaking out Address into Individual Columns (Address, City, State)

SELECT PropertyAddress
FROM NashvilleHousing

SELECT
SUBSTRING(PropertyAddress, 1, (CHARINDEX(',', PropertyAddress) - 1)) AS Address,
SUBSTRING(PropertyAddress, (CHARINDEX(',', PropertyAddress) + 1), LEN(PropertyAddress)) AS Address
FROM NashvilleHousing

ALTER TABLE NashvilleHousing
ADD  PropertySplitAddress nvarchar(255);

UPDATE NashvilleHousing
SET PropertySplitAddress = SUBSTRING(PropertyAddress, 1, CHARINDEX(',', PropertyAddress) -1 )

ALTER TABLE NashvilleHousing
ADD PropertySplitCity nvarchar(255);

UPDATE NashvilleHousing
SET PropertySplitCity = SUBSTRING(PropertyAddress, CHARINDEX(',', PropertyAddress) + 1 , LEN(PropertyAddress))

--Extract Owner Address and State

SELECT OwnerAddress
FROM NashvilleHousing

SELECT 
PARSENAME(REPLACE(OwnerAddress, ',', '.') , 3)
,PARSENAME(REPLACE(OwnerAddress, ',', '.') , 2)
,PARSENAME(REPLACE(OwnerAddress, ',', '.') , 1)
FROM NashvilleHousing


ALTER TABLE NashvilleHousing
ADD OwnerSplitAddress nvarchar(255);

UPDATE NashvilleHousing
SET OwnerSplitAddress = PARSENAME(REPLACE(OwnerAddress, ',', '.') , 3)


ALTER TABLE NashvilleHousing
ADD OwnerSplitCity nvarchar(255);

UPDATE NashvilleHousing
SET OwnerSplitCity = PARSENAME(REPLACE(OwnerAddress, ',', '.') , 2)


ALTER TABLE NashvilleHousing
ADD OwnerSplitState nvarchar(255);

UPDATE NashvilleHousing
SET OwnerSplitState = PARSENAME(REPLACE(OwnerAddress, ',', '.') , 1)



--Checking new columns

SELECT PropertySplitAddress, PropertySplitCity, OwnerSplitAddress, OwnerSplitCity, OwnerSplitState
FROM NashvilleHousing

--------------------------------------------------------------------------------------------------------------------------

-- Change 1 and 0 to Yes and No in "Sold as Vacant" field


SELECT DISTINCT(SoldAsVacant), COUNT(SoldAsVacant)
FROM NashvilleHousing
GROUP BY SoldAsVacant

ALTER TABLE NashvilleHousing
ADD SoldAsVacant2 varchar(10)

UPDATE NashvilleHousing
SET SoldAsVacant2 = CONVERT(varchar(10), SoldAsVacant)

UPDATE NashvilleHousing
SET SoldAsVacant2=
CASE WHEN SoldAsVacant2 = '0' THEN 'No'
WHEN SoldAsVacant2 = '1' THEN 'Yes'
ELSE soldasVacant2
END 
FROM NashvilleHousing

ALTER TABLE NashvilleHousing
DROP COLUMN SoldAsVacant

-----------------------------------------------------------------------------------------------------------------------------------------------------------

-- Finding/Removing Duplicates

WITH RownumCTE AS(
SELECT 
	ROW_NUMBER() OVER(
	PARTITION BY ParcelID,
				PropertyAddress,
				SalePrice,
				SaleDateConverted,
				LegalReference
				ORDER BY 
				UniqueID) row_num
FROM NashvilleHousing
--ORDER BY ParcelID
)

--DELETE
SELECT*
FROM RownumCTE
WHERE row_num>1

---------------------------------------------------------------------------------------------------------

-- Delete Unused Columns

SELECT *
FROM NashvilleHousing


ALTER TABLE NashvilleHousing
DROP COLUMN OwnerAddress, TaxDistrict, PropertyAddress
