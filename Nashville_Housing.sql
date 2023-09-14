SELECT TOP (1000) [UniqueID ]
      ,[ParcelID]
      ,[LandUse]
      ,[PropertyAddress]
      ,[SaleDate]
      ,[SalePrice]
      ,[LegalReference]
      ,[SoldAsVacant]
      ,[OwnerName]
      ,[OwnerAddress]
      ,[Acreage]
      ,[TaxDistrict]
      ,[LandValue]
      ,[BuildingValue]
      ,[TotalValue]
      ,[YearBuilt]
      ,[Bedrooms]
      ,[FullBath]
      ,[HalfBath]
  FROM [PortfoliaProject].[dbo].[NashvilleHousing]

  SELECT * 
  from PortfoliaProject..Sheet1$

  -- Standardize the Sale Date

   SELECT SalesDateConverted,convert(Date,SaleDate)
  from PortfoliaProject..Sheet1$
  
  Alter Table Sheet1$
  Add SalesDateConverted Date;

  Update Sheet1$
  Set SalesDateConverted = convert(Date,SaleDate)

  -- Propert Address Data
  SELECT *
  from PortfoliaProject..Sheet1$
 -- Where PropertyAddress is NULL
 order by ParcelID

 SELECT a.ParcelID,a.PropertyAddress,b.ParcelID,b.PropertyAddress,ISNULL(a.PropertyAddress,b.PropertyAddress)
  from PortfoliaProject..Sheet1$ a
  JOIN PortfoliaProject..Sheet1$ b
  ON a.ParcelID = b.ParcelID
  AND a.UniqueID <> b.UniqueID
  Where a.PropertyAddress is NUll

  Update a
  Set PropertyAddress = ISNULL(a.PropertyAddress,b.PropertyAddress)
  from PortfoliaProject..Sheet1$ a
  JOIN PortfoliaProject..Sheet1$ b
  ON a.ParcelID = b.ParcelID
  AND a.UniqueID <> b.UniqueID
  Where a.PropertyAddress is NUll

  -- Breaking out Address into Individual columns(Address, City, State)
  SELECT PropertyAddress
  from PortfoliaProject..Sheet1$
 -- Where PropertyAddress is NULL
-- order by ParcelID

Select
SUBSTRING(PropertyAddress,1,CHARINDEX(',',PropertyAddress)-1) As Address,
SUBSTRING(PropertyAddress,CHARINDEX(',',PropertyAddress)+1,LEN(PropertyAddress)) As City
from PortfoliaProject..Sheet1$

  Alter Table Sheet1$
  Add Address Nvarchar(255);

  Update Sheet1$
  Set Address = SUBSTRING(PropertyAddress,1,CHARINDEX(',',PropertyAddress)-1)

    Alter Table Sheet1$
  Add City Nvarchar(255);

  Update Sheet1$
  Set City =SUBSTRING(PropertyAddress,CHARINDEX(',',PropertyAddress)+1,LEN(PropertyAddress))

  -- Breaking out OwnerAddress into Address,City and States

  SELECT 
  PARSENAME(REPLACE(OwnerAddress,',','.'),3) As Owner_Address,
  PARSENAME(REPLACE(OwnerAddress,',','.'),2) As Owner_City,
  PARSENAME(REPLACE(OwnerAddress,',','.'),1) As Owner_State
  from PortfoliaProject..Sheet1$

   
   Alter Table Sheet1$
  Add Owner_Address Nvarchar(255);

  Update Sheet1$
  Set Owner_Address = PARSENAME(REPLACE(OwnerAddress,',','.'),3)

   Alter Table Sheet1$
  Add Owner_City Nvarchar(255);

  Update Sheet1$
  Set Owner_City=PARSENAME(REPLACE(OwnerAddress,',','.'),2)

  Alter Table Sheet1$
  Add Owner_State Nvarchar(255);

  Update Sheet1$
  Set Owner_State =PARSENAME(REPLACE(OwnerAddress,',','.'),1)

  SELECT *
  FROM PortfoliaProject..Sheet1$

  -- Change y and N to Yes and No in "Sold as Vacant" field

  SELECT DISTINCT(SoldAsVacant),COUNT(SoldAsVacant)
  FROM PortfoliaProject..Sheet1$
  GROUP BY SoldAsVacant
  ORDER BY 2

   SELECT SoldAsVacant,
   CASE 
	WHEN SoldAsVacant = 'Y' THEN 'Yes'
    WHEN SoldAsVacant = 'N' THEN 'NO'
	ELSE SoldAsVacant
   END
   FROM PortfoliaProject..Sheet1$

   UPDATE Sheet1$
   SET SoldAsVacant = CASE 
	WHEN SoldAsVacant = 'Y' THEN 'Yes'
    WHEN SoldAsVacant = 'N' THEN 'NO'
	ELSE SoldAsVacant
   END

   -- Remove Duplicates

   SELECT * 
  from PortfoliaProject..Sheet1$

  WITH RowNumCTE AS (
  SELECT *,
	ROW_NUMBER() OVER(
	PARTITION BY ParcelID,
				 PropertyAddress,
				 SalePrice,
				 SaleDate,
				 LegalReference
				 ORDER BY
					UniqueID
				) row_num
  from PortfoliaProject..Sheet1$
  )
SELECT *
FROM RowNumCTE
WHERE row_num > 1

-- Delete Unused Columns

SELECT * 
  from PortfoliaProject..Sheet1$

  ALTER TABLE PortfoliaProject..Sheet1$
  DROP COLUMN OwnerAddress, PropertyAddress,TaxDistrict

  ALTER TABLE PortfoliaProject..Sheet1$
  DROP COLUMN SalesDateConverted

