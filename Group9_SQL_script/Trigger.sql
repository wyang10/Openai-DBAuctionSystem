-- Trigger
-- automatically set an auction's status "closed" to TRUE when a bid exceeds a certain high price threshold. 
DROP TRIGGER IF EXISTS CloseAuctionAfterHighBid;

DELIMITER //

CREATE TRIGGER CloseAuctionAfterHighBid
AFTER INSERT ON dbapp_bid FOR EACH ROW
BEGIN
    DECLARE startingPrice DECIMAL(9,2);
    -- Retrieve the starting bid of the auction
    SELECT starting_bid INTO startingPrice FROM dbapp_auction WHERE id = NEW.auction_id;
    -- Check if the new bid is at least double the starting bid
    IF NEW.bid_price >= startingPrice * 2 THEN
        UPDATE dbapp_auction SET closed = TRUE WHERE id = NEW.auction_id;
    END IF;
END; //

DELIMITER ;
