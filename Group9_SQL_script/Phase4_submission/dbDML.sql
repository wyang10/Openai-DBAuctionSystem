-- Make a file containing INSERT statements which populate the table created in Step 9, named dbDML.sql. 
-- This script will contain SQL commands to fill data in your data.  Each table should have around 7 ~ 10 sample data.
-- Users Table
INSERT INTO Users (userName, password, email, lastLoginTime, isAdmin) VALUES 
('JohnDoe', 'hashed_johndoe_pass', 'john.doe@example.com', '2023-01-01 08:00:00', 0),
('JaneSmith', 'hashed_janesmith_pass', 'jane.smith@example.com', '2023-01-02 09:00:00', 0),
('AliceJohnson', 'hashed_alicejohnson_pass', 'alice.johnson@example.com', '2023-01-03 10:00:00', 1),
('BobBrown', 'hashed_bobbrown_pass', 'bob.brown@example.com', '2023-01-04 11:00:00', 0),
('CarolWhite', 'hashed_carolwhite_pass', 'carol.white@example.com', '2023-01-05 12:00:00', 0),
('DaveBlack', 'hashed_daveblack_pass', 'dave.black@example.com', '2023-01-06 13:00:00', 0),
('EveGreen', 'hashed_evegreen_pass', 'eve.green@example.com', '2023-01-07 14:00:00', 0);

-- Category Table
INSERT INTO Category (categoryName) VALUES 
('Chairs'),
('Tables'),
('Sofas'),
('Beds'),
('Storage'),
('Bookcases'),
('Rugs'),
('OutdoorFurniture');

-- Auction Table
INSERT INTO Auction (title, description, price, categoryID, image_url, seller_id, watch_status, list_status, bid_status) VALUES 
('Vintage Mahogany Chair', 'A beautifully carved mahogany chair.', 125.00, 1, 'antique-mahogany-chair.jpg', 1, FALSE, TRUE, TRUE),
('Extendable Dining Table', 'A modern extendable table perfect for family dinners.', 215.00, 2, 'extendable-dining-table.jpg', 2, FALSE, TRUE, TRUE),
('Italian Leather Sofa', 'A luxurious Italian leather sofa that seats four.', 850.00, 3, 'italian-leather-sofa.jpg', 3, FALSE, TRUE, TRUE),
('King-Sized Canopy Bed', 'An elegant canopy bed with a sturdy frame and plush curtains.', 780.00, 4, 'king-canopy-bed.jpg', 4, FALSE, TRUE, TRUE),
('Modular Storage Cubes', 'Versatile storage cubes that can be arranged in multiple ways.', 199.00, 5, 'modular-storage-cubes.jpg', 5, FALSE, TRUE, TRUE),
('Vintage Bookcase', 'A classic wooden bookcase with glass doors.', 320.00, 6, 'vintage-bookcase.jpg', 6, FALSE, TRUE, TRUE),
('Hand-Woven Oriental Rug', 'A hand-woven rug with intricate patterns.', 450.00, 7, 'oriental-rug.jpg', 7, FALSE, TRUE, TRUE),
('Patio Furniture Set', 'A weather-resistant patio furniture set including chairs and a table.', 540.00, 8, 'patio-furniture-set.jpg', 7, FALSE, TRUE, TRUE);

-- Comments Table
INSERT INTO Comments (commentID, userID, headline, message, cm_date, auctionID) VALUES 
('CMT001', 1, 'Good design', 'The details on this chair are incredible!', '2023-11-18', 1),
('CMT002', 2, 'Family Favorite', 'Our family dinners have transformed with this table!', '2023-11-19', 2),
('CMT003', 3, 'Luxury Comfort', 'This sofa adds a touch of luxury to our living room.', '2023-11-20', 3),
('CMT004', 4, 'Sleep Like Royalty', 'The canopy bed is as regal as it is comfortable.', '2023-11-21', 4),
('CMT005', 5, 'Huge help', 'These storage cubes helped me organize my clutter.', '2023-11-22', 5),
('CMT006', 6, 'Classic', 'The bookcase is a timeless addition to my home office.', '2023-11-23', 6),
('CMT007', 7, 'Artistic Touch', 'The oriental rug has brought life and color to our floors.', '2023-11-24', 7);

-- Watchlists Table
INSERT INTO Watchlists (userID, auctionID) VALUES 
(1, 2),
(2, 3),
(3, 4),
(4, 5),
(5, 6),
(6, 7),
(7, 8);

-- Shipment Table
INSERT INTO Shipment (shipNumber, address, buyerID, auctionID) VALUES 
('SHIP001', '101 Oak Street, Springfield', 1, 1),
('SHIP002', '202 Pine Street, South Park', 2, 2),
('SHIP003', '303 Maple Avenue, Gotham', 3, 3),
('SHIP004', '404 Birch Road, Metropolis', 4, 4),
('SHIP005', '505 Cedar Blvd, Star City', 5, 5),
('SHIP006', '606 Elm Way, Central City', 6, 6),
('SHIP007', '707 Willow Lane, Smallville', 7, 7);

-- Payment Table
INSERT INTO Payment (paymentID, price, buyerID, auctionID) VALUES 
('PAY001', 125.00, 1, 1),
('PAY002', 215.00, 2, 2),
('PAY003', 850.00, 3, 3),
('PAY004', 780.00, 4, 4),
('PAY005', 199.00, 5, 5),
('PAY006', 320.00, 6, 6),
('PAY007', 450.00, 7, 7);

-- Bids Table
INSERT INTO Bids (bidID, bidderID, auctionID, bid_status, bidPrice) VALUES 
('BID001', 2, 1, 'Active', 135.00),
('BID002', 3, 2, 'Active', 225.00),
('BID003', 4, 3, 'Active', 900.00),
('BID004', 5, 4, 'Active', 800.00),
('BID005', 6, 5, 'Active', 210.00),
('BID006', 7, 6, 'Active', 350.00),
('BID007', 1, 7, 'Active', 475.00);
