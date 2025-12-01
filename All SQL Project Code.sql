CREATE DATABASE finance_tracker;
USE finance_tracker;

CREATE TABLE reminders(
id INT IDENTITY(1,1) PRIMARY KEY,
title NVARCHAR(MAX) NOT NULL,
content NVARCHAR(MAX) NOT NULL,
);
GO

CREATE TABLE expenses (
id INT IDENTITY(1,1) PRIMARY KEY,
amount DECIMAL(10,2) NOT NULL,
note NVARCHAR(MAX) NULL,
date DATETIME DEFAULT GETDATE() NOT NULL
);

ALTER TABLE expenses ALTER COLUMN date DATETIME;

ALTER TABLE expenses 
ADD purchase VARCHAR(255) NOT NULL DEFAULT 'Purchase';

CREATE TABLE categories(
	id INT IDENTITY(1,1) PRIMARY KEY,
	name VARCHAR(20) UNIQUE NOT NULL
);

CREATE TABLE goals(
	id INT IDENTITY(1,1) PRIMARY KEY,
	category_id INT,
	spending_goal INT NOT NULL,
	reoccuring BIT DEFAULT 0,
	end_date DATETIME DEFAULT NULL,
	duration_type NVARCHAR(20) DEFAULT NULL,
	custom_duration INT,
	CONSTRAINT goal_category_fkey FOREIGN KEY (category_id) REFERENCES Categories(id) ON DELETE CASCADE ON UPDATE CASCADE,
	CONSTRAINT check_duration_type CHECK (duration_type IN ('weekly', 'monthly', 'yearly', 'custom') OR duration_type IS NULL),
	CONSTRAINT check_custom_duration CHECK ((duration_type = 'custom' AND custom_duration IS NOT NULL) 
	OR (duration_type != 'custom' AND custom_duration IS NULL))
);

ALTER TABLE reminders ADD goal_id INT;
ALTER TABLE reminders ADD CONSTRAINT reminder_goal_fkey FOREIGN KEY (goal_id) REFERENCES Goals(id) ON DELETE CASCADE ON UPDATE CASCADE;

ALTER TABLE expenses ADD category_id INT;
ALTER TABLE expenses ADD CONSTRAINT expenses_category_fkey FOREIGN KEY (category_id) REFERENCES Categories(id) ON DELETE CASCADE ON UPDATE CASCADE;

INSERT INTO Categories (name)
VALUES 
('Rent'),
('Groceries'),
('Restaurants'),
('Utilities'),
('Gym/Health'),
('Clothes'),
('Entertainment');

INSERT INTO Goals (category_id, spending_goal, reoccuring, end_date, duration_type, custom_duration) VALUES
(1, 50, 1, '2025-12-31', 'monthly', NULL),
(2, 1200, 1, '2025-12-31', 'monthly', NULL),
(3, 400, 1, '2025-12-31', 'monthly', NULL),
(4, 150, 1, '2025-12-31', 'monthly', NULL),
(5, 60, 1, '2025-12-31', 'monthly', NULL),
(6, 100, 1, '2025-12-31', 'monthly', NULL),
(7, 150, 1, '2025-12-31', 'monthly', NULL);

INSERT INTO Expenses (amount, note, date, purchase, category_id) VALUES
(42.99, 'Bought a novel', '2025-01-13', 'Barnes & Noble', 1),
(18.50, 'Online book sale', '2025-02-22', 'Amazon Books', 1),

(1200.00, 'Monthly rent payment', '2025-01-01', 'Apartment Rent', 2),
(1200.00, 'Monthly rent payment', '2025-02-01', 'Apartment Rent', 2),
(1200.00, 'Monthly rent payment', '2025-03-01', 'Apartment Rent', 2),

(152.75, 'Weekly groceries', '2025-01-10', 'Walmart', 3),
(89.33, 'Produce + snacks', '2025-03-16', 'Trader Joes', 3),
(104.20, 'Stock-up groceries', '2025-06-02', 'Costco', 3),
(127.90, 'Weekly groceries', '2025-11-18', 'Aldi', 3),

(96.40, 'Electric + water bill', '2025-02-08', 'City Utilities', 4),
(112.15, 'Gas + electric', '2025-05-12', 'Power Company', 4),
(89.00, 'Internet bill', '2025-09-07', 'ISP Provider', 4),

(45.00, 'Monthly gym membership', '2025-01-15', 'Planet Fitness', 5),
(45.00, 'Monthly gym membership', '2025-02-15', 'Planet Fitness', 5),
(45.00, 'Monthly gym membership', '2025-03-15', 'Planet Fitness', 5),
(32.50, 'Protein powder', '2025-08-04', 'GNC', 5),

(56.20, 'New shirt', '2025-04-21', 'H&M', 6),
(112.49, 'Bought shoes', '2025-07-10', 'Nike Store', 6),
(38.99, 'Sweater on sale', '2025-11-26', 'Old Navy', 6),

(23.90, 'Movie night', '2025-02-19', 'AMC Theaters', 7),
(65.00, 'Mini golf with friends', '2025-05-30', 'Putt-Putt Fun Center', 7),
(12.00, 'Arcade tokens', '2025-09-14', 'Dave & Busters', 7),
(48.75, 'Bowling night', '2025-12-08', 'Bowling Alley', 7),
(14.99, 'Paperback on sale', '2025-01-27', 'Amazon Books', 7),
(28.50, 'Study guide', '2025-03-05', 'Barnes & Noble', 7),
(9.99, 'Used book', '2025-06-18', 'ThriftBooks', 7),
(22.95, 'Cookbook purchase', '2025-09-25', 'Books-A-Million', 7),
(74.20, 'Jacket on sale', '2025-02-03', 'Gap', 6),
(19.99, 'T-shirt', '2025-03-29', 'Target', 6),
(88.00, 'Running shoes', '2025-06-14', 'Foot Locker', 6),
(42.90, 'Jeans', '2025-10-09', 'American Eagle', 6),
(15.00, 'Socks pack', '2025-12-12', 'Walmart', 6),
(35.00, 'Live music cover charge', '2025-01-19', 'Local Bar', 7),
(11.50, 'Ice cream outing', '2025-04-03', 'Ben & Jerry’s', 7),
(76.00, 'Theme park day pass', '2025-07-22', 'Adventure Park', 7),
(24.99, 'Board game', '2025-08-15', 'GameStop', 7),
(30.00, 'Karaoke night', '2025-10-30', 'Karaoke Bar', 7),
(18.60, 'Snacks & drinks for movie night', '2025-12-19', 'AMC Theaters', 7),
(133.20, 'Weekly groceries', '2025-02-14', 'Kroger', 3),
(97.80, 'Mid-week grocery trip', '2025-04-09', 'Aldi', 3),
(151.40, 'Stocking up for guests', '2025-07-01', 'Costco', 3),
(84.90, 'Produce & dairy', '2025-10-11', 'Whole Foods', 3),
(119.99, 'Bulk essentials', '2025-12-05', 'Sam’s Club', 3),
(63.25, 'Quick trip', '2025-08-28', 'Trader Joe’s', 3),
(29.99, 'Vitamins', '2025-03-08', 'CVS Pharmacy', 5),
(45.00, 'Gym membership', '2025-04-15', 'Planet Fitness', 5),
(45.00, 'Gym membership', '2025-05-15', 'Planet Fitness', 5),
(45.00, 'Gym membership', '2025-06-15', 'Planet Fitness', 5),
(18.50, 'Energy bars', '2025-09-03', 'GNC', 5),
(62.00, 'Massage therapy session', '2025-11-02', 'Wellness Spa', 5),
(1200.00, 'Monthly rent payment', '2025-04-01', 'Apartment Rent', 2),
(1200.00, 'Monthly rent payment', '2025-05-01', 'Apartment Rent', 2),
(1200.00, 'Monthly rent payment', '2025-06-01', 'Apartment Rent', 2),
(1200.00, 'Monthly rent payment', '2025-07-01', 'Apartment Rent', 2),
(1200.00, 'Monthly rent payment', '2025-08-01', 'Apartment Rent', 2),
(1200.00, 'Monthly rent payment', '2025-09-01', 'Apartment Rent', 2),
(102.40, 'Gas bill', '2025-01-12', 'Gas Co', 4),
(91.75, 'Water bill', '2025-03-10', 'City Water', 4),
(132.60, 'Electric bill', '2025-06.03', 'Electric Co', 4),
(89.99, 'Internet bill', '2025-08-07', 'ISP Provider', 4),
(95.10, 'Electric bill', '2025-10-06', 'Power Co', 4),
(110.00, 'Heating bill', '2025-12-03', 'Heating Co', 4);

INSERT INTO Reminders (title, content, goal_id) VALUES
('Read 2 books this month', 'Finish reading "The Great Gatsby" and "1984"', 1),
('Buy new novels', 'Check Amazon for discounts on new releases', 1),

('Pay April Rent', 'Remember to transfer rent by 1st of the month', 2),
('Rent increase review', 'Check lease for new year changes', 2),

('Weekly grocery shopping', 'Buy essentials and check pantry stock', 3),
('Monthly budget review', 'Sum up groceries spending to stay within $400', 3),

('Pay electricity bill', 'Due by 10th of the month', 4),
('Check internet plan', 'Consider upgrading or switching plan', 4),

('Gym session reminder', 'Attend at least 3 times a week', 5),
('Buy protein supplements', 'Check GNC or Amazon for deals', 5),

('Seasonal clothing review', 'Decide what to buy this season', 6),
('Check online sales', 'Look for discounts on clothes', 6),

('Plan weekend outing', 'Pick one fun activity to stay within budget', 7),
('Movie night', 'Check listings for a fun movie to watch', 7),

('Backup financial data', 'Make sure to export latest transactions', NULL),
('Pay credit card', 'Check balance and pay before due date', NULL),
('Check bank statements', 'Review for any errors or unexpected charges', NULL),
('Set emergency fund', 'Decide initial deposit for safety net', NULL);

