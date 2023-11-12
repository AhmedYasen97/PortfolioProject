/*
Cleaning Data in SQL Queries

*/

SELECT *
FROM PortfolioProject.. Housing

--------------------------------------------------------------------------------------------------------------

-- Standarize Date Format


SELECT SalesDateUpdated, CONVERT(Date,SaleDate)
FROM PortfolioProject.. Housing

UPDATE Housing
SET SaleDate = CONVERT(Date,SaleDate)


ALTER TABLE Housing
ADD SalesDateUpdated Date 
UPDATE Housing
SET SalesDateUpdated = CONVERT(Date,SaleDate)

--------------------------------------------------------------------------------------------------------------

-- Populate Property Address Data

SELECT *
FROM PortfolioProject.. Housing
--WHERE PropertyAddress is NULL
ORDER BY ParcelID

SELECT a.ParcelID, a.PropertyAddress , b.ParcelID, b.PropertyAddress, ISNULL(a.PropertyAddress ,b.PropertyAddress)
FROM PortfolioProject.. Housing a
JOIN PortfolioProject.. Housing b
	ON a.ParcelID = b.ParcelID
	AND a.[UniqueID ] <> b.[UniqueID ]
WHERE a.PropertyAddress IS NULL

UPDATE a
SET PropertyAddress = ISNULL(a.PropertyAddress ,b.PropertyAddress)
FROM PortfolioProject.. Housing a
JOIN PortfolioProject.. Housing b
	ON a.ParcelID = b.ParcelID
	AND a.[UniqueID ] <> b.[UniqueID ]
WHERE a.PropertyAddress IS NULL

--------------------------------------------------------------------------------------------------------------

-- Breaking Out Address Into Individual Columns (Address, City, State)

SELECT PropertyAddress
FROM PortfolioProject.. Housing


SELECT
SUBSTRING (PropertyAddress , 1,CHARINDEX(',',PropertyAddress)-1) as Address
,SUBSTRING (PropertyAddress,CHARINDEX(',',PropertyAddress)+1,LEN(PropertyAddress)) as Address

FROM PortfolioProject.. Housing



ALTER TABLE Housing
ADD PropertySplitAddress Nvarchar(255) 

UPDATE Housing
SET PropertySplitAddress = SUBSTRING (PropertyAddress , 1,CHARINDEX(',',PropertyAddress)-1)

ALTER TABLE Housing
ADD PropertySplitCity Nvarchar(255)  

UPDATE Housing
SET PropertySplitCity = SUBSTRING (PropertyAddress,CHARINDEX(',',PropertyAddress)+1,LEN(PropertyAddress))

SELECT *
FROM PortfolioProject.. Housing



Select
PARSENAME(REPLACE(OwnerAddress, ',', '.') , 3)
,PARSENAME(REPLACE(OwnerAddress, ',', '.') , 2)
,PARSENAME(REPLACE(OwnerAddress, ',', '.') , 1)
FROM PortfolioProject.. Housing



ALTER TABLE Housing
Add OwnerSplitAddress Nvarchar(255)

Update Housing
SET OwnerSplitAddress = PARSENAME(REPLACE(OwnerAddress, ',', '.') , 3)


ALTER TABLE Housing
Add OwnerSplitCity Nvarchar(255);

Update Housing
SET OwnerSplitCity = PARSENAME(REPLACE(OwnerAddress, ',', '.') , 2)



ALTER TABLE Housing
Add OwnerSplitState Nvarchar(255);

Update Housing
SET OwnerSplitState = PARSENAME(REPLACE(OwnerAddress, ',', '.') , 1)



Select *
FROM PortfolioProject.. Housing




--------------------------------------------------------------------------------------------------------------

-- Change Y and N to Yes and No in "Sold as Vacant" field

Select Distinct(SoldAsVacant), Count(SoldAsVacant)
From PortfolioProject.. Housing
Group by SoldAsVacant
order by 2


Select SoldAsVacant
, CASE WHEN SoldAsVacant = 'Y' THEN 'Yes'
	   WHEN SoldAsVacant = 'N' THEN 'No'
	   ELSE SoldAsVacant
	   END
From PortfolioProject.. Housing

UPDATE Housing
SET SoldAsVacant = CASE WHEN SoldAsVacant = 'Y' THEN 'Yes'
	   WHEN SoldAsVacant = 'N' THEN 'No'
	   ELSE SoldAsVacant
	   END

--------------------------------------------------------------------------------------------------------------

-- Remove Duplicates
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


FROM PortfolioProject.. Housing
)

SELECT *
FROM RowNumCTE
WHERE row_num > 1

--------------------------------------------------------------------------------------------------------------


-- Delete Unused Columns



Select *
From PortfolioProject.. Housing


ALTER TABLE Housing
DROP COLUMN OwnerAddress, TaxDistrict, PropertyAddress, SaleDate

 