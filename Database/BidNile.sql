
USE BidNile;
GO


CREATE TABLE Account.City
(
    CityId INT IDENTITY(1,1) PRIMARY KEY,
    Name NVARCHAR(100) NOT NULL,
    CountryCode CHAR(2) NOT NULL,

    CONSTRAINT UQ_City_Name_CountryCode
        UNIQUE (Name, CountryCode),

    CONSTRAINT CK_City_CountryCode
        CHECK (CountryCode IN ('EG', 'SA', 'AE'))
);
GO



CREATE TABLE Account.Member
(
    MemberId UNIQUEIDENTIFIER PRIMARY KEY DEFAULT NEWID(),
    FullName NVARCHAR(100) NOT NULL,
    Email VARCHAR(150) NOT NULL UNIQUE,
    Mobile VARCHAR(20) NOT NULL,
    NationalId VARCHAR(20) NOT NULL UNIQUE,
    BirthDate DATE NOT NULL,
    IsVerified BIT NOT NULL DEFAULT 0,
    RegisteredAt DATETIMEOFFSET NOT NULL DEFAULT SYSDATETIMEOFFSET(),
    CityId INT NOT NULL,
    InvitedById UNIQUEIDENTIFIER NULL,

    CONSTRAINT CK_Member_BirthDate
        CHECK (BirthDate <= DATEADD(YEAR, -18, GETDATE()))
);
GO



CREATE TABLE Account.Wallet
(
    MemberId UNIQUEIDENTIFIER PRIMARY KEY,
    Balance DECIMAL(18,2) NOT NULL DEFAULT 0,
    HeldAmount DECIMAL(18,2) NOT NULL DEFAULT 0,
    Currency CHAR(3) NOT NULL DEFAULT 'EGP',
    UpdatedAt DATETIME2 NOT NULL DEFAULT SYSDATETIME(),

    CONSTRAINT CK_Wallet_Balance
        CHECK (Balance >= 0),

    CONSTRAINT CK_Wallet_HeldAmount
        CHECK (HeldAmount >= 0 AND HeldAmount <= Balance)
);
GO


CREATE TABLE Logistics.Warehouse
(
    WarehouseId BIGINT IDENTITY(1,1) NOT NULL PRIMARY KEY,
    Name NVARCHAR(100) NOT NULL UNIQUE,
    Capacity INT NOT NULL,
    Latitude FLOAT NOT NULL,
    Longitude FLOAT NOT NULL,
    CityId INT NOT NULL,
    ManagerId UNIQUEIDENTIFIER NULL UNIQUE,
    ManagerSince DATETIME2 NULL,

    CONSTRAINT CK_Warehouse_Capacity
        CHECK (Capacity > 0),

    CONSTRAINT CK_Warehouse_Latitude
        CHECK (Latitude BETWEEN -90 AND 90),

    CONSTRAINT CK_Warehouse_Longitude
        CHECK (Longitude BETWEEN -180 AND 180)
);
GO



CREATE TABLE Logistics.Employee
(
    MemberId UNIQUEIDENTIFIER NOT NULL,
    WarehouseId BIGINT NOT NULL,

    CONSTRAINT PK_Employee
        PRIMARY KEY (MemberId, WarehouseId)
);
GO



CREATE TABLE Category.Category
(
    CategoryId INT NOT NULL PRIMARY KEY,
    NameEn NVARCHAR(100) NOT NULL UNIQUE,
    NameAr NVARCHAR(100) NULL,
    CommissionPct DECIMAL(5,2) NOT NULL,
    ParentCategoryId INT NULL,

    CONSTRAINT CK_Category_CommissionPct
        CHECK (CommissionPct BETWEEN 0 AND 30)
);
GO


CREATE TABLE Category.Item
(
    ItemId BIGINT IDENTITY(1,1) NOT NULL PRIMARY KEY,
    Title NVARCHAR(150) NOT NULL,
    Description NVARCHAR(MAX) NULL,
    ConditionScore TINYINT NOT NULL,
    Specs NVARCHAR(MAX) NOT NULL,
    ListedAt DATETIME2 NOT NULL DEFAULT SYSDATETIME(),
    SellerId UNIQUEIDENTIFIER NOT NULL,
    InspectorId UNIQUEIDENTIFIER NULL,
    CategoryId INT NOT NULL,
    WarehouseId BIGINT NULL,

    CONSTRAINT CK_Item_ConditionScore
        CHECK (ConditionScore BETWEEN 1 AND 10),

    CONSTRAINT CK_Item_Specs
        CHECK (ISJSON(Specs) = 1),

    CONSTRAINT CK_Item_Inspector
        CHECK (InspectorId IS NULL OR InspectorId <> SellerId)
);
GO



CREATE TABLE Category.ItemPhoto
(
    ItemId BIGINT NOT NULL,
    Position TINYINT NOT NULL,
    Url NVARCHAR(500) NOT NULL,
    IsMain BIT NOT NULL DEFAULT 0,

    CONSTRAINT PK_ItemPhoto
        PRIMARY KEY (ItemId, Position),

    CONSTRAINT CK_ItemPhoto_Position
        CHECK (Position BETWEEN 1 AND 20)
);
GO



CREATE TABLE Auction.Auction
(
    AuctionId BIGINT IDENTITY(1,1) NOT NULL PRIMARY KEY,
    StartPrice DECIMAL(18,2) NOT NULL,
    ReservePrice DECIMAL(18,2) NULL,
    BidIncrement DECIMAL(18,2) NOT NULL DEFAULT 50,
    StartsAt DATETIME2 NOT NULL,
    EndsAt DATETIME2 NOT NULL,
    Status VARCHAR(20) NOT NULL DEFAULT 'Draft',
    ItemId BIGINT NOT NULL,

    CONSTRAINT CK_Auction_StartPrice
        CHECK (StartPrice > 0),

    CONSTRAINT CK_Auction_ReservePrice
        CHECK (ReservePrice IS NULL OR ReservePrice >= StartPrice),

    CONSTRAINT CK_Auction_BidIncrement
        CHECK (BidIncrement > 0),

    CONSTRAINT CK_Auction_Dates
        CHECK (EndsAt > StartsAt),

    CONSTRAINT CK_Auction_Status
        CHECK (Status IN ('Draft', 'Live', 'Ended', 'Cancelled'))
);
GO



CREATE TABLE Auction.Bid
(
    BidId BIGINT IDENTITY(1,1) NOT NULL PRIMARY KEY,
    Amount DECIMAL(18,2) NOT NULL,
    PlacedAt DATETIME2 NOT NULL DEFAULT SYSDATETIME(),
    IpAddress VARCHAR(45) NOT NULL,
    AuctionId BIGINT NOT NULL,
    MemberId UNIQUEIDENTIFIER NOT NULL,

    CONSTRAINT UQ_Bid_Auction_Amount
        UNIQUE (AuctionId, Amount),

    CONSTRAINT CK_Bid_Amount
        CHECK (Amount > 0)
);
GO


CREATE TABLE Auction.Auction_Follower
(
    MemberId UNIQUEIDENTIFIER NOT NULL,
    AuctionId BIGINT NOT NULL,
    FollowedAt DATETIMEOFFSET NOT NULL DEFAULT SYSDATETIMEOFFSET(),

    CONSTRAINT PK_Auction_Follower
        PRIMARY KEY (MemberId, AuctionId)
);
GO
USE BidNile;
GO

SELECT
    SCHEMA_NAME(schema_id) AS SchemaName,
    name AS TableName
FROM sys.tables
ORDER BY schema_id, name;

-- Task 3 

ALTER TABLE Account.Member
ADD CONSTRAINT FK_Member_City
FOREIGN KEY (CityId)
REFERENCES Account.City(CityId);

ALTER TABLE Account.Member
ADD CONSTRAINT FK_Member_InvitedBy
FOREIGN KEY (InvitedById)
REFERENCES Account.Member(MemberId);


ALTER TABLE Account.Wallet
ADD CONSTRAINT FK_Wallet_Member
FOREIGN KEY (MemberId)
REFERENCES Account.Member(MemberId);


ALTER TABLE Logistics.Warehouse
ADD CONSTRAINT FK_Warehouse_City
FOREIGN KEY (CityId)
REFERENCES Account.City(CityId);


ALTER TABLE Logistics.Warehouse
ADD CONSTRAINT FK_Warehouse_Manager
FOREIGN KEY (ManagerId)
REFERENCES Account.Member(MemberId);


ALTER TABLE Logistics.Employee
ADD CONSTRAINT FK_Employee_Member
FOREIGN KEY (MemberId)
REFERENCES Account.Member(MemberId);


ALTER TABLE Logistics.Employee
ADD CONSTRAINT FK_Employee_Warehouse
FOREIGN KEY (WarehouseId)
REFERENCES Logistics.Warehouse(WarehouseId);


ALTER TABLE Category.Category
ADD CONSTRAINT FK_Category_Parent
FOREIGN KEY (ParentCategoryId)
REFERENCES Category.Category(CategoryId);


ALTER TABLE Category.Item
ADD CONSTRAINT FK_Item_Seller
FOREIGN KEY (SellerId)
REFERENCES Account.Member(MemberId);


ALTER TABLE Category.Item
ADD CONSTRAINT FK_Item_Inspector
FOREIGN KEY (InspectorId)
REFERENCES Account.Member(MemberId);


ALTER TABLE Category.Item
ADD CONSTRAINT FK_Item_Category
FOREIGN KEY (CategoryId)
REFERENCES Category.Category(CategoryId);

ALTER TABLE Category.Item
ADD CONSTRAINT FK_Item_Warehouse
FOREIGN KEY (WarehouseId)
REFERENCES Logistics.Warehouse(WarehouseId);


ALTER TABLE Category.ItemPhoto
ADD CONSTRAINT FK_ItemPhoto_Item
FOREIGN KEY (ItemId)
REFERENCES Category.Item(ItemId)
ON DELETE CASCADE;


ALTER TABLE Auction.Auction
ADD CONSTRAINT FK_Auction_Item
FOREIGN KEY (ItemId)
REFERENCES Category.Item(ItemId);


ALTER TABLE Auction.Bid
ADD CONSTRAINT FK_Bid_Auction
FOREIGN KEY (AuctionId)
REFERENCES Auction.Auction(AuctionId);


ALTER TABLE Auction.Bid
ADD CONSTRAINT FK_Bid_Member
FOREIGN KEY (MemberId)
REFERENCES Account.Member(MemberId);


ALTER TABLE Auction.Auction_Follower
ADD CONSTRAINT FK_AuctionFollower_Member
FOREIGN KEY (MemberId)
REFERENCES Account.Member(MemberId);


ALTER TABLE Auction.Auction_Follower
ADD CONSTRAINT FK_AuctionFollower_Auction
FOREIGN KEY (AuctionId)
REFERENCES Auction.Auction(AuctionId);

ALTER TABLE Account.Member
ADD Language CHAR(2) NOT NULL DEFAULT 'ar';

ALTER TABLE Category.Item
ADD IsFeatured BIT NOT NULL DEFAULT 0;

ALTER TABLE Logistics.Warehouse
DROP CONSTRAINT CK_Warehouse_Capacity;

EXEC sp_rename
    'Logistics.Warehouse.Capacity',
    'MaxItems',
    'COLUMN';

ALTER TABLE Logistics.Warehouse
ADD CONSTRAINT CK_Warehouse_MaxItems
CHECK (MaxItems > 0);
ALTER TABLE Account.Member
ALTER COLUMN FullName NVARCHAR(150) NOT NULL;



ALTER TABLE Logistics.Warehouse
DROP CONSTRAINT CK_Warehouse_MaxItems;

ALTER TABLE Logistics.Warehouse
ALTER COLUMN MaxItems SMALLINT NOT NULL;

ALTER TABLE Logistics.Warehouse
ADD CONSTRAINT CK_Warehouse_MaxItems
CHECK (MaxItems > 0);


ALTER TABLE Category.Category
DROP CONSTRAINT CK_Category_CommissionPct;

ALTER TABLE Category.Category
ADD CONSTRAINT CK_Category_CommissionPct
CHECK (CommissionPct BETWEEN 0 AND 25);


ALTER TABLE Auction.Auction
DROP CONSTRAINT CK_Auction_Status;

DECLARE @StatusDefault NVARCHAR(200);

SELECT @StatusDefault = dc.name
FROM sys.default_constraints dc
JOIN sys.columns c
    ON dc.parent_object_id = c.object_id
    AND dc.parent_column_id = c.column_id
WHERE dc.parent_object_id = OBJECT_ID('Auction.Auction')
    AND c.name = 'Status';

IF @StatusDefault IS NOT NULL
BEGIN
    EXEC('ALTER TABLE Auction.Auction DROP CONSTRAINT ' + @StatusDefault);
END;

ALTER TABLE Auction.Auction
ADD CONSTRAINT CK_Auction_Status
CHECK (Status IN ('Draft', 'PendingReview', 'Live', 'Ended', 'Cancelled'));

ALTER TABLE Auction.Auction
ADD CONSTRAINT DF_Auction_Status
DEFAULT 'PendingReview' FOR Status;


ALTER TABLE Auction.Auction
ADD BuyNowPrice DECIMAL(18,2) NULL;

ALTER TABLE Auction.Auction
WITH CHECK ADD CONSTRAINT CK_Auction_BuyNowPrice
CHECK (BuyNowPrice IS NULL OR BuyNowPrice > StartPrice);


IF NOT EXISTS
(
    SELECT Mobile
    FROM Account.Member
    GROUP BY Mobile
    HAVING COUNT(*) > 1
)
BEGIN
    ALTER TABLE Account.Member
    ADD CONSTRAINT UQ_Member_Mobile UNIQUE (Mobile);
END
ELSE
BEGIN
    PRINT 'Duplicate mobile numbers must be corrected before adding UNIQUE.';
END;


ALTER TABLE Account.Member
ADD VerifiedAt DATETIME2 NULL;

ALTER TABLE Account.Member
DROP CONSTRAINT DF_Member_IsVerified;

ALTER TABLE Account.Member
DROP COLUMN IsVerified;
Go

CREATE SCHEMA Marketing;
GO

ALTER SCHEMA Marketing
TRANSFER Auction.Auction_Follower;
GO