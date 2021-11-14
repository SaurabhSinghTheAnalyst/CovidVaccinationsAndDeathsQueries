/*
Cleaning Data in SQL Queries
*/

Select * 
From Portfolioproject.dbo.NashvilleHousing

--Standardise Date Format 

Select SaleDateConverted, CONVERT(Date,SaleDate)
From Portfolioproject.dbo.NashvilleHousing

ALTER TABLE	Portfolioproject.dbo.NashvilleHousing
Add SaleDateConverted Date;

Update Portfolioproject.dbo.NashvilleHousing
SET SaleDateConverted = CONVERT(Date,SaleDate)

-- Populate Property Address data 

Select a.ParcelID, a.PropertyAddress, b.ParcelID, b.PropertyAddress, ISNULL(a.PropertyAddress, b.PropertyAddress)
From Portfolioproject.dbo.NashvilleHousing a
JOIN Portfolioproject.dbo.NashvilleHousing b
on a.ParcelID = b.ParcelID
AND a.[UniqueID] <> b.[UniqueID]
where a.propertyAddress is null

UPDATE a
SET PropertyAddress = ISNULL(a.PropertyAddress, b.PropertyAddress)
From Portfolioproject.dbo.NashvilleHousing a
JOIN Portfolioproject.dbo.NashvilleHousing b
on a.ParcelID = b.ParcelID
AND a.[UniqueID] <> b.[UniqueID]
where a.propertyAddress is null

-- Breaking out Address into individual columns (Address, City, State) 

Select PropertyAddress
From Portfolioproject.dbo.NashvilleHousing
--where PropertyAddress is null
--order by ParcelID

Select 
SUBSTRING(PropertyAddress, 1, CHARINDEX(',' , PropertyAddress)-1) as Address,
SUBSTRING(PropertyAddress, CHARINDEX(',' , PropertyAddress) +1, LEN(PropertyAddress)) as City
From PortfolioProject.dbo.NashvilleHousing


ALTER TABLE	Portfolioproject.dbo.NashvilleHousing
Add PropertySplitAddress Nvarchar(255);

Update Portfolioproject.dbo.NashvilleHousing
SET  PropertySplitAddress = SUBSTRING(PropertyAddress, 1, CHARINDEX(',' , PropertyAddress)-1)

ALTER TABLE	Portfolioproject.dbo.NashvilleHousing
Add PropertySplitCity Nvarchar(255);

Update Portfolioproject.dbo.NashvilleHousing
SET PropertySplitCity = SUBSTRING(PropertyAddress, CHARINDEX(',' , PropertyAddress) +1, LEN(PropertyAddress))

Select
PARSENAME(REPLACE(OwnerAddress, ',', '.'),3),
PARSENAME(REPLACE(OwnerAddress, ',', '.'),2),
PARSENAME(REPLACE(OwnerAddress, ',', '.'),1)
From Portfolioproject.dbo.NashvilleHousing
where OwnerAddress is not null

ALTER TABLE	Portfolioproject.dbo.NashvilleHousing
Add OwnerSplitAddress Nvarchar(255);

Update Portfolioproject.dbo.NashvilleHousing
SET  OwnerSplitAddress = PARSENAME(REPLACE(OwnerAddress, ',', '.'),3)

ALTER TABLE	Portfolioproject.dbo.NashvilleHousing
Add OwnerSplitCity Nvarchar(255);

Update Portfolioproject.dbo.NashvilleHousing
SET  OwnerSplitCity = PARSENAME(REPLACE(OwnerAddress, ',', '.'),2)

ALTER TABLE	Portfolioproject.dbo.NashvilleHousing
Add OwnerSplitState Nvarchar(255);

Update Portfolioproject.dbo.NashvilleHousing
SET  OwnerSplitState = PARSENAME(REPLACE(OwnerAddress, ',', '.'),1)

-- Change Y and N to Yes and No in "Sold as Vacant" Field 

Update Portfolioproject.dbo.NashvilleHousing
SET  SoldAsVacant = Case When SoldAsVacant = 'Y' THEN 'Yes'
	When SoldAsVacant = 'N' THEN 'NO'
	ELSE SoldAsVacant
	END
From Portfolioproject.dbo.NashvilleHousing

Select DISTINCT(SoldAsVacant), COUNT(SoldAsVacant)
From Portfolioproject.dbo.NashvilleHousing
Group by SoldAsVacant
Order by 2

--Remove Duplicates 
WITH RowNumCTE AS(
Select *, 
	ROW_NUMBER() OVER (
	PARTITION BY ParcelID, PropertyAddress, SalePrice
	, SaleDate, LegalReference
	ORDER BY UniqueID) row_num
From Portfolioproject.dbo.NashvilleHousing
)
Select * 
From RowNumCTE
Where row_num > 1 

--Delete Unused columns 

ALTER TABLE Portfolioproject.dbo.NashvilleHousing
DROP COLUMN SaleDate


Select * 
From Portfolioproject.dbo.NashvilleHousing
