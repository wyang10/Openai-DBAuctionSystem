-- View
-- lists all auctions along with the total number of bids placed on them can be useful for quick reference.

CREATE VIEW AuctionBidCount AS
SELECT a.id, a.title, COUNT(b.id) AS NumberOfBids
FROM dbapp_auction a
LEFT JOIN dbapp_bid b ON a.id = b.auction_id
GROUP BY a.id;

SELECT * FROM AuctionBidCount;