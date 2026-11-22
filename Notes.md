# NOTES.md

## 1. Schemas, Tables, and Why

- **Account:** City, Member, Wallet. Handles members, their locations, and wallets.
- **Logistics:** Warehouse, Employee. Manages warehouses and their employees.
- **Category:** Category, Item, ItemPhoto. Organizes categories, items, and item photos.
- **Auction:** Auction, Bid, Auction_Follower. Manages auctions, bids, and followers.

## 2. Relationship Types

- **1:1:** Member and Wallet. Each wallet belongs to one member.
- **1:N:** City and Member, City and Warehouse, Member and Bid, Auction and Bid, Category and Item, Warehouse and Item.
- **M:N:** Member and Warehouse through Employee. Member and Auction through Auction_Follower.
- **Recursive:** Member.InvitedById references Member.MemberId. Category.ParentCategoryId references Category.CategoryId.
- **Weak Entity:** ItemPhoto depends on Item and uses a composite primary key (ItemId, Position).

## 3. Data Type Choices

- **UNIQUEIDENTIFIER for Members:** Provides globally unique member IDs.
- **BIGINT for Bids:** Supports a large number of bid records.
- **FLOAT for GPS:** Stores latitude and longitude values.
- **DECIMAL for Money:** Provides accurate decimal values for financial calculations.
- **DATETIMEOFFSET for RegisteredAt:** Stores date, time, and time-zone offset.

## 4. Why Can't Circular Relationships Be Created Inside CREATE TABLE?

Because one table may reference another table that has not been created yet. Creating all tables first and adding foreign keys later using ALTER TABLE solves this problem.

## 5. Table Creation Order

1. City
2. Member
3. Wallet
4. Warehouse
5. Employee
6. Category
7. Item
8. ItemPhoto
9. Auction
10. Bid
11. Auction_Follower

The order ensures that referenced tables exist before adding foreign key constraints.

## 6. Errors in Tasks 3.6 and 3.11

**Task 3.6:**
Changing MaxItems from INT to SMALLINT can fail if existing values exceed the SMALLINT range. The solution is to check existing data and use the smallest data type that can store all values while keeping the CHECK constraint (MaxItems > 0).

**Task 3.11:**
Dropping IsVerified can fail because it has a DEFAULT constraint. The solution is to drop the DEFAULT constraint first, then drop the column.

## 7. Hand Trace – Task 5

Input: [1, 2, 3, 4]

**Prefix Array:**

[1, 1, 2, 6]

**Suffix Array:**

[24, 12, 4, 1]

**Final Result:**

[24, 12, 8, 6]

For each index, the result is the product of its prefix and suffix values.

Time Complexity: O(n)

Space Complexity: O(n) for the first solution.

Space Complexity: O(1) extra space for the second solution, excluding the output array.

No division was used.