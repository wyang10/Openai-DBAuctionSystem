CREATE TABLE dbapp_user (
	id INT AUTO_INCREMENT PRIMARY KEY,
	password VARCHAR(128) NOT NULL,
	last_login DATETIME(6) NULL,
	is_superuser BOOLEAN NOT NULL,
	username VARCHAR(150) NOT NULL UNIQUE,
	first_name VARCHAR(30) NOT NULL,
	last_name VARCHAR(150) NOT NULL,
	email VARCHAR(254) NOT NULL,
	is_staff BOOLEAN NOT NULL,
	is_active BOOLEAN NOT NULL,
	date_joined DATETIME(6) NOT NULL
);

CREATE TABLE dbapp_category (
	id INT AUTO_INCREMENT PRIMARY KEY,
	title VARCHAR(64) NOT NULL
);

CREATE TABLE dbapp_auction (
	id INT AUTO_INCREMENT PRIMARY KEY,
	title VARCHAR(64) NOT NULL,
	description TEXT NOT NULL,
	starting_bid DECIMAL(9,2) DEFAULT 0.00 NOT NULL,
	current_bid DECIMAL(9,2) DEFAULT 0.00 NOT NULL,
	category_id INT NULL,
	imageURL VARCHAR(2048) NULL,
	seller_id INT NOT NULL,
	closed BOOLEAN NOT NULL DEFAULT FALSE,
	creation_date DATETIME(6) NOT NULL,
	update_date DATETIME(6) NULL,
	FOREIGN KEY (category_id) REFERENCES dbapp_category(id),
	FOREIGN KEY (seller_id) REFERENCES dbapp_user(id)
);


CREATE TABLE dbapp_bid (
	id INT AUTO_INCREMENT PRIMARY KEY,
	bider_id INT NOT NULL,
	bid_date DATETIME(6) NOT NULL,
	bid_price DECIMAL(9,2) NOT NULL,
	auction_id INT NOT NULL,
	FOREIGN KEY (bider_id) REFERENCES dbapp_user(id),
	FOREIGN KEY (auction_id) REFERENCES dbapp_auction(id)
);

CREATE TABLE dbapp_comment (
	id INT AUTO_INCREMENT PRIMARY KEY,
	user_id INT NOT NULL,
	headline VARCHAR(64) NOT NULL,
	message TEXT NOT NULL,
	cm_date DATETIME(6) NOT NULL,
	auction_id INT NOT NULL,
	FOREIGN KEY (user_id) REFERENCES dbapp_user(id),
	FOREIGN KEY (auction_id) REFERENCES dbapp_auction(id)
);

CREATE TABLE dbapp_watchlist (
	id INT AUTO_INCREMENT PRIMARY KEY,
	user_id INT NOT NULL UNIQUE,
	FOREIGN KEY (user_id) REFERENCES dbapp_user(id)
);

CREATE TABLE dbapp_watchlist_auctions (
	watchlist_id INT NOT NULL,
	auction_id INT NOT NULL,
	PRIMARY KEY (watchlist_id, auction_id),
	FOREIGN KEY (watchlist_id) REFERENCES dbapp_watchlist(id),
	FOREIGN KEY (auction_id) REFERENCES dbapp_auction(id)
);