SELECT *
FROM nashvilleHousing

--standardize data format

SELECT SaleDateConverted, CONVERT(date,SaleDate)
FROM nashvilleHousing

UPDATE nashvilleHousing
SET SaleDate = CONVERT(date,SaleDate)

ALTER TABLE nashvilleHousing
ADD SaleDateConverted Date;

UPDATE nashvilleHousing
SET SaleDateConverted = CONVERT(date,SaleDate)

--populate property address data

SELECT *
FROM nashvilleHousing
--WHERE PropertyAddress is null
ORDER BY ParcelID

SELECT a.PropertyAddress, a.ParcelID, b.ParcelID, b.PropertyAddress, ISNULL(a.PropertyAddress,b.PropertyAddress)
FROM nashvilleHousing AS a
JOIN nashvilleHousing AS b
	ON a.ParcelID = b.ParcelID
	AND a.[UniqueID ] <> b.[UniqueID ]
WHERE a.PropertyAddress is null

UPDATE a
SET PropertyAddress = ISNULL(a.PropertyAddress,b.PropertyAddress)
FROM nashvilleHousing AS a
JOIN nashvilleHousing AS b
	ON a.ParcelID = b.ParcelID
	AND a.[UniqueID ] <> b.[UniqueID ]
WHERE a.PropertyAddress is null

--breaking out address into individual columns (address, city, state)

SELECT PropertyAddress
FROM nashvilleHousing
--WHERE PropertyAddress is null
--ORDER BY ParcelID

SELECT
SUBSTRING(PropertyAddress,1,CHARINDEX(',', PropertyAddress)-1) as Address,
SUBSTRING(PropertyAddress,CHARINDEX(',', PropertyAddress)+1, LEN(PropertyAddress)) as Address
FROM nashvilleHousing

ALTER TABLE nashvilleHousing
ADD PropertySplitAddress NvarChar(255);

UPDATE nashvilleHousing
SET PropertySplitAddress = SUBSTRING(PropertyAddress,1,CHARINDEX(',', PropertyAddress)-1)

ALTER TABLE nashvilleHousing
ADD PropertySplitCity NvarChar(255);

UPDATE nashvilleHousing
SET PropertySplitCity = SUBSTRING(PropertyAddress,CHARINDEX(',', PropertyAddress)+1, LEN(PropertyAddress))


SELECT OwnerAddress
FROM nashvilleHousing

SELECT
PARSENAME(REPLACE(OwnerAddress,',','.'),3),
PARSENAME(REPLACE(OwnerAddress,',','.'),2),
PARSENAME(REPLACE(OwnerAddress,',','.'),1)
FROM nashvilleHousing


ALTER TABLE nashvilleHousing
ADD OwnerSplitAddress NvarChar(255);

UPDATE nashvilleHousing
SET OwnerSplitAddress = PARSENAME(REPLACE(OwnerAddress,',','.'),3)

ALTER TABLE nashvilleHousing
ADD OwnerSplitCity NvarChar(255);

UPDATE nashvilleHousing
SET OwnerSplitCity = PARSENAME(REPLACE(OwnerAddress,',','.'),2)

ALTER TABLE nashvilleHousing
ADD OwnerSplitState NvarChar(255);

UPDATE nashvilleHousing
SET OwnerSplitState = PARSENAME(REPLACE(OwnerAddress,',','.'),1)


--change Y and N to Yes and No in "sold as vacant" field

SELECT DISTINCT(SoldAsVacant), COUNT(SoldAsVacant)
FROM nashvilleHousing
GROUP BY SoldAsVacant
ORDER BY 2


SELECT SoldAsVacant
, CASE WHEN SoldAsVacant = 'Y' THEN 'YES'
	   WHEN SoldAsVacant = 'N' THEN 'NO'
	   ELSE SoldAsVacant
	   END
FROM nashvilleHousing

UPDATE nashvilleHousing
SET SoldAsVacant = CASE WHEN SoldAsVacant = 'Y' THEN 'YES'
	   WHEN SoldAsVacant = 'N' THEN 'NO'
	   ELSE SoldAsVacant
	   END


WITH RowNumCTE AS (
SELECT *,
	ROW_NUMBER()OVER(
	PARTITION BY ParcelID,
				 PropertyAddress,
				 SalePrice,
				 SaleDate,
				 LegalReference
				 ORDER BY
					UniqueID
					) row_num
FROM nashvilleHousing
)
SELECT *
FROM RowNumCTE
WHERE row_num > 1
ORDER BY PropertyAddress


WITH RowNumCTE AS (
SELECT *,
	ROW_NUMBER()OVER(
	PARTITION BY ParcelID,
				 PropertyAddress,
				 SalePrice,
				 SaleDate,
				 LegalReference
				 ORDER BY
					UniqueID
					) row_num
FROM nashvilleHousing
)
DELETE
FROM RowNumCTE
WHERE row_num > 1
--ORDER BY PropertyAddress


--DELETE UNUSED COLUMNS

ALTER TABLE nashvilleHousing
DROP COLUMN OwnerAddress, TaxDistrict, PropertyAddress

ALTER TABLE nashvilleHousing
DROP COLUMN SaleDate