-- 1. List all active auction listings in a given (e.g., 'Tables') category.
SELECT * FROM Auction
JOIN Category ON Auction.categoryID = Category.categoryID
WHERE Category.categoryName = 'Tables' AND Auction.list_status = TRUE;

-- 2. List all auction listings closing within 7 days.
SELECT * FROM Auction
WHERE DATE_ADD(creation_time, INTERVAL 7 DAY) >= NOW();

-- 3. List all auction listings with no bids.
SELECT * FROM Auction
LEFT JOIN Bids ON Auction.auctionID = Bids.auctionID
WHERE Bids.bidID IS NULL;

-- 4. List all auction listings created by a specific user (e.g., user with userID = 1).
SELECT * FROM Auction
WHERE seller_id = 1;

-- 5. List all bids placed by a specific user (e.g., user with userID = 1).
SELECT * FROM Bids
WHERE bidderID = 1;

-- 6. List all comments made by a specific user (e.g., user with userID = 1).
SELECT * FROM Comments
WHERE userID = 1;

-- 7. List all watchlist items for a specific user (e.g., user with userID = 1).
SELECT * FROM Watchlists
JOIN Auction ON Watchlists.auctionID = Auction.auctionID
WHERE userID = 1;

-- 8. Show the current highest bid amount for a specific auction listing (e.g., auctionID = 1).
SELECT MAX(bidPrice) AS HighestBid FROM Bids
WHERE auctionID = 1;

-- 9. Show all bids placed on a specific auction listing (e.g., auctionID = 1).
SELECT * FROM Bids
WHERE auctionID = 1
ORDER BY bidPrice DESC;

-- 10. Show all comments made on a specific auction listing (e.g., auctionID = 1).
SELECT * FROM Comments
WHERE auctionID = 1;

-- 11. Show the winner (highest bidder) for a closed auction listing (e.g., auctionID = 1).
SELECT bidderID FROM Bids
WHERE auctionID = 1 AND bid_status = 'Closed'
ORDER BY bidPrice DESC
LIMIT 1;

-- 12. Show the total number of bids placed by a specific user (e.g., user with userID = 1).
SELECT COUNT(*) AS TotalBids FROM Bids
WHERE bidderID = 1;

-- 13. Show the total number of active auction listings in each category.
SELECT Category.categoryName, COUNT(Auction.auctionID) AS ActiveListings
FROM Category
LEFT JOIN Auction ON Category.categoryID = Auction.categoryID AND Auction.list_status = TRUE
GROUP BY Category.categoryName;

-- 14. Show the most recent closed auction from the admin side.
SELECT * FROM Auction
WHERE list_status = FALSE
ORDER BY last_updated DESC
LIMIT 1;

-- 15. Show the total number of closed auction listings per month.
SELECT YEAR(last_updated) AS Year, MONTH(last_updated) AS Month, COUNT(*) AS ClosedAuctions
FROM Auction
WHERE list_status = FALSE
GROUP BY YEAR(last_updated), MONTH(last_updated)
ORDER BY Year DESC, Month DESC;
