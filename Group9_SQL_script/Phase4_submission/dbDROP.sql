-- Drop the view first as it has no dependencies
DROP VIEW IF EXISTS AuctionBidCount;

-- Drop the trigger
DROP TRIGGER IF EXISTS CloseAuctionAfterHighBid;

-- Drop the stored procedure
DROP PROCEDURE IF EXISTS TotalActiveBids;

-- Drop the tables that contain foreign keys and have dependencies last
DROP TABLE IF EXISTS Bids;
DROP TABLE IF EXISTS Payment;
DROP TABLE IF EXISTS Shipment;
DROP TABLE IF EXISTS Watchlists;
DROP TABLE IF EXISTS Comments;
DROP TABLE IF EXISTS Auction;
DROP TABLE IF EXISTS Users;
DROP TABLE IF EXISTS Category;
