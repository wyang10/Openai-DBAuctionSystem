-- Stored Procedure
-- calculates the total value of all active bids for a given user.
DELIMITER //

CREATE PROCEDURE TotalActiveBids(IN userID INT)
BEGIN
  SELECT b.bider_id AS user_id, SUM(bid_price) AS Total
  FROM dbapp_bid b
  JOIN dbapp_auction a ON a.id = b.auction_id
  WHERE a.seller_id = b.bider_id AND a.closed = FALSE;
END; //

DELIMITER ;