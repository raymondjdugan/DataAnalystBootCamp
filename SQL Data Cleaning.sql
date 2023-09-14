-- Data Cleaning Project

Select *
From PortfolioProject..NashvilleHousing

----------------------------------------------------------------------------------------------
-- Standardize Date Format

Select SaleDate, CONVERT(Date,SaleDate)
From PortfolioProject..NashvilleHousing

UPDATE PortfolioProject..NashvilleHousing
SET SaleDate = CONVERT(Date,SaleDate)

ALTER TABLE	NashvilleHousing
Add SaleDateConverted Date;

Update PortfolioProject..NashvilleHousing
Set SaleDateConverted = CONVERT(Date,SaleDate)

Select SaleDateConverted, CONVERT(Date,SaleDate)
From PortfolioProject..NashvilleHousing

----------------------------------------------------------------------------------------------
--Populate Property Address Data

Select *
From PortfolioProject..NashvilleHousing
--Where PropertyAddress is null
Order by ParcelID

Select a.ParcelID, a.PropertyAddress, b.ParcelID, b.PropertyAddress, ISNULL(a.PropertyAddress, b.PropertyAddress)
From PortfolioProject..NashvilleHousing as a
Join PortfolioProject..NashvilleHousing as b
	on a.ParcelID = b.ParcelID
	and a.[UniqueID ] <> b.[UniqueID ]
Where a.PropertyAddress is null

Update a
Set PropertyAddress = ISNULL(a.PropertyAddress, b.PropertyAddress)
From PortfolioProject..NashvilleHousing as a
Join PortfolioProject..NashvilleHousing as b
	on a.ParcelID = b.ParcelID
	and a.[UniqueID ] <> b.[UniqueID ]
Where a.PropertyAddress is null



----------------------------------------------------------------------------------------------
/* 

Breaking Out Address Into Individual Columns (Address, City, State)

*/

-- Looking at the PropertyAddress Data Set
Select PropertyAddress
From PortfolioProject..NashvilleHousing

-- Parsing out the address and city using substring
Select 
SUBSTRING(PropertyAddress, 1, CHARINDEX(',', PropertyAddress)-1) as Address,
SUBSTRING(PropertyAddress, CHARINDEX(',', PropertyAddress)+1, LEN(PropertyAddress)) as City
From PortfolioProject..NashvilleHousing

-- Adding columns to the table for the new data
ALTER TABLE	PortfolioProject..NashvilleHousing
Add ProptertySplitAddress nvarchar(255), PropertySplitCity nvarchar(255) 

-- Updating the table with the new data
Update PortfolioProject..NashvilleHousing
Set PropertySplitAddress = SUBSTRING(PropertyAddress, 1, CHARINDEX(',', PropertyAddress)-1),
PropertySplitCity = SUBSTRING(PropertyAddress, CHARINDEX(',', PropertyAddress)+1, LEN(PropertyAddress))

--Checking the data
Select PropertySplitAddress, PropertySplitCity
From PortfolioProject..NashvilleHousing


-- Parsing Owner Address

-- Looking at the data set using parsename instead of substring
Select
PARSENAME(REPLACE(OwnerAddress, ',','.'), 3) as OwnerSplitAddress, 
PARSENAME(REPLACE(OwnerAddress, ',','.'), 2) as OwnerSplitCity,
PARSENAME(REPLACE(OwnerAddress, ',','.'), 1) as OwnerSplitState
From PortfolioProject..NashvilleHousing

-- Adding three new columns for the onwer address data parsed out
ALTER TABLE	NashvilleHousing
Add OwnerSplitAddress nvarchar(255), 
OwnerSplitCity nvarchar(255),
OwnerSplitState nvarchar(255) 

-- updating the table with the new owner data parsed out
UPDATE PortfolioProject..NashvilleHousing
SET	
OwnerSplitAddress = PARSENAME(REPLACE(OwnerAddress, ',','.'), 3),
OwnerSplitCity = PARSENAME(REPLACE(OwnerAddress, ',','.'), 2),
OwnerSplitState = PARSENAME(REPLACE(OwnerAddress, ',','.'), 1)

-- Checking the data
Select OwnerSplitAddress, OwnerSplitCity, OwnerSplitState
From PortfolioProject..NashvilleHousing
----------------------------------------------------------------------------------------------
/*

Change Y and N to Yes and No in "Sold as Vacant" field

*/

-- Viewing all of the sold as vacant column data
Select Distinct(SoldAsVacant), Count(SoldAsVacant)
From PortfolioProject..NashvilleHousing
Group by SoldAsVacant
order by 2

-- Using case to change y and n to yes and no and viewing before updating
Select SoldAsVacant,
	Case When SoldAsVacant = 'Y' Then 'Yes'
		 When SoldAsVacant = 'N' Then 'No'
		 Else SoldAsVacant
	End
From PortfolioProject..NashvilleHousing
WHERE SoldAsVacant = 'Y' or SoldAsVacant = 'N'

-- updating the table to reflect only yes or no
Update PortfolioProject..NashvilleHousing
Set SoldAsVacant =
		Case When SoldAsVacant = 'Y' Then 'Yes'
		 When SoldAsVacant = 'N' Then 'No'
		 Else SoldAsVacant
	End
----------------------------------------------------------------------------------------------

/*

Remove Duplicates

*/

--Creating CTE to distinguish duplicates
With RowNumCTE As(
Select *,
	ROW_NUMBER() Over (
	Partition By ParcelID,
				 PropertyAddress,
				 SalePrice,
				 SaleDate,
				 LegalReference
				 Order by 
					UniqueID
					) row_num
From PortfolioProject..NashvilleHousing
--Order by ParcelID
)
--Delete
--From RowNumCTE
--Where row_num > 1
----Order by PropertyAddress
Select *
From RowNumCTE
Where row_num > 1
Order by PropertyAddress


----------------------------------------------------------------------------------------------

/*

Remove unused columns

*/

Alter table PortfolioProject..NashvilleHousing
Drop Column OwnerAddress, TaxDistrict, PropertyAddress, SaleDate

Select *
From PortfolioProject..NashvilleHousing
