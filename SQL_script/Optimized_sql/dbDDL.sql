-- create your entire database schema, named dbDDL.sql.  This includes the tables with their constraints, view, indexes, triggers, and all other database objects if you have them.
-- To keep the project consistent, make sure you have at least 8 tables. Make sure you have the following database objects:
-- At least 1 trigger,
-- At least 1 function or procedure, and
-- At least 1 view.

-- Users Table
CREATE TABLE Users (
    userID INT UNSIGNED AUTO_INCREMENT PRIMARY KEY,
    userName VARCHAR(150) NOT NULL UNIQUE, -- Django default is 150 characters
    password VARCHAR(128) NOT NULL, -- Django's password field is 128 chars long
    email VARCHAR(254) NOT NULL UNIQUE, -- Django's EmailField max_length is 254
    lastLoginTime DATETIME,
    isAdmin BIT DEFAULT 0
);

-- Category Table
CREATE TABLE Category (
    categoryID INT UNSIGNED AUTO_INCREMENT PRIMARY KEY,
    categoryName VARCHAR(50) NOT NULL UNIQUE
);

-- Auction Table
CREATE TABLE Auction (
    auctionID INT UNSIGNED AUTO_INCREMENT PRIMARY KEY,
    title VARCHAR(100) NOT NULL,
    description TEXT,
    price DECIMAL(10,2) NOT NULL,
    categoryID INT UNSIGNED NOT NULL,
    image_url VARCHAR(255),
    creation_time TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    last_updated TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    seller_id INT UNSIGNED,
    watch_status BOOLEAN DEFAULT FALSE,
    list_status BOOLEAN DEFAULT TRUE,
    bid_status BOOLEAN DEFAULT FALSE,
    FOREIGN KEY (seller_id) REFERENCES Users (userID),
    FOREIGN KEY (categoryID) REFERENCES Category (categoryID)
);

-- Comments Table
CREATE TABLE Comments (
    commentID VARCHAR(8) PRIMARY KEY,
    userID INT UNSIGNED,
    headline VARCHAR(20) NOT NULL,
    message VARCHAR(100),
    cm_date DATE,
    auctionID INT UNSIGNED,
    FOREIGN KEY (userID) REFERENCES Users (userID),
    FOREIGN KEY (auctionID) REFERENCES Auction (auctionID)
);

-- Watchlists Table
CREATE TABLE Watchlists (
    watchListID INT UNSIGNED AUTO_INCREMENT PRIMARY KEY,
    userID INT UNSIGNED,
    auctionID INT UNSIGNED,
    added_time TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (userID) REFERENCES Users (userID),
    FOREIGN KEY (auctionID) REFERENCES Auction (auctionID)
);

-- Shipment Table
CREATE TABLE Shipment (
    shipNumber VARCHAR(8) PRIMARY KEY,
    address VARCHAR(100),
    buyerID INT UNSIGNED,
    auctionID INT UNSIGNED,
    FOREIGN KEY (auctionID) REFERENCES Auction (auctionID),
    FOREIGN KEY (buyerID) REFERENCES Users (userID)
);

-- Payment Table
CREATE TABLE Payment (
    paymentID VARCHAR(8) PRIMARY KEY,
    price DECIMAL(10,2),
    buyerID INT UNSIGNED,
    auctionID INT UNSIGNED,
    FOREIGN KEY (auctionID) REFERENCES Auction (auctionID),
    FOREIGN KEY (buyerID) REFERENCES Users (userID)
);

-- Bids Table
CREATE TABLE Bids (
    bidID VARCHAR(8) PRIMARY KEY,
    bidderID INT UNSIGNED NOT NULL,
    auctionID INT UNSIGNED NOT NULL,
    bid_status VARCHAR(10),
    bidPrice DECIMAL(10,2),
    FOREIGN KEY (bidderID) REFERENCES Users (userID),
    FOREIGN KEY (auctionID) REFERENCES Auction (auctionID)
);

-- Trigger
-- automatically set an auction's list_status to FALSE (i.e., close the auction) when a bid exceeds a certain high price threshold. 

DELIMITER //

CREATE TRIGGER CloseAuctionAfterHighBid
AFTER INSERT ON Bids FOR EACH ROW
BEGIN
    IF NEW.bidPrice >= 1000 THEN
        UPDATE Auction SET list_status = FALSE WHERE auctionID = NEW.auctionID;
    END IF;
END; //

DELIMITER ;

-- View
-- lists all auctions along with the total number of bids placed on them can be useful for quick reference.

CREATE VIEW AuctionBidCount AS
SELECT Auction.auctionID, Auction.title, COUNT(Bids.bidID) AS NumberOfBids
FROM Auction
LEFT JOIN Bids ON Auction.auctionID = Bids.auctionID
GROUP BY Auction.auctionID;

-- Stored Procedure
-- calculates the total value of all active bids for a given user.
DELIMITER //

CREATE PROCEDURE TotalActiveBids(IN userID INT)
BEGIN
  SELECT SUM(bidPrice) AS Total
  FROM Bids
  JOIN Auction ON Bids.auctionID = Auction.auctionID
  WHERE bidderID = userID AND Auction.list_status = TRUE;
END; //

DELIMITER ;
