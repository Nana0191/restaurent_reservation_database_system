TRUNCATE TABLE order_menuitem, orders, reservations, menu_item, staff, customers, restaurent_tables
RESTART IDENTITY CASCADE;


INSERT INTO restaurent_tables (table_number, capacity, dining_section) VALUES
(1, 2, 'Indoor'),
(2, 4, 'Indoor'),
(3, 6, 'Outdoor'),
(4, 8, 'Private Room');



INSERT INTO customers (full_name, phone, email) VALUES
('Ahmed Hassan', '01011111111', 'ahmed@mail.com'),  
('Sara Youssef', '01022222222', DEFAULT),             
('Omar Khaled', '01033333333', 'omar@mail.com'),      
('Laila Mostafa', '01044444444', 'laila@mail.com'),   
('Youssef Adel', '01055555555', DEFAULT);   



INSERT INTO staff (full_name, phone, staff_role, hire_date) VALUES
('Mona Adel', '01099999999', 'Host', '2023-01-15'),      -- 1
('Karim Fathy', '01088888888', 'Waiter', '2024-03-01'),  -- 2
('Nour Samir', '01077777777', 'Manager', '2022-06-10');  -- 3



INSERT INTO menu_item (category, price, stock_quantity) VALUES
('Appetizer', 45.00, 20),  -- 1
('Main', 120.00, 15),      -- 2
('Dessert', 35.00, 10),    -- 3
('Beverage', 20.00, 30);



INSERT INTO reservations (customer_id, table_number, staff_id, reservation_date, start_time, end_time, party_size, stage_state)
VALUES (5, 3, 2, CURRENT_DATE, '20:00', '21:30', 5, 'seated');


INSERT INTO reservations (customer_id, table_number, staff_id, reservation_date, start_time, end_time, party_size, stage_state)
VALUES (4, 4, 3, CURRENT_DATE + 1, '19:00', '20:00', 6, 'pending');


INSERT INTO reservations (customer_id, table_number, staff_id, reservation_date, start_time, end_time, party_size, stage_state)
VALUES (4, 2, 1, CURRENT_DATE - 3, '18:00', '19:00', 2, 'canceled');   -- #4

INSERT INTO reservations (customer_id, table_number, staff_id, reservation_date, start_time, end_time, party_size, stage_state)
VALUES (4, 3, 1, CURRENT_DATE - 5, '18:00', '19:00', 2, 'canceled');   -- #5

-- ============================================
INSERT INTO orders (reservation_id) VALUES (1);  -- order_id 1, status defaults to 'Open'

INSERT INTO order_menuitem (order_id, menu_item_id, quantity_recorded) VALUES (1, 1, 2);  -- Appetizer x2
INSERT INTO order_menuitem (order_id, menu_item_id, quantity_recorded) VALUES (1, 2, 1);  -- Main x1

UPDATE orders SET status = 'closed' WHERE order_id = 1;

-- Order for reservation #2 (Youssef, table 3)
INSERT INTO orders (reservation_id) VALUES (2);  -- order_id 2

INSERT INTO order_menuitem (order_id, menu_item_id, quantity_recorded) VALUES (2, 1, 3);  -- Appetizer x3
INSERT INTO order_menuitem (order_id, menu_item_id, quantity_recorded) VALUES (2, 2, 2);  -- Main x2
INSERT INTO order_menuitem (order_id, menu_item_id, quantity_recorded) VALUES (2, 4, 4);  -- Beverage x4

UPDATE orders SET status = 'closed' WHERE order_id = 2;

-- Order for reservation #3 (Laila, table 4)
INSERT INTO orders (reservation_id) VALUES (3);  -- order_id 3

INSERT INTO order_menuitem (order_id, menu_item_id, quantity_recorded) VALUES (3, 2, 5);  -- Main x5
INSERT INTO order_menuitem (order_id, menu_item_id, quantity_recorded) VALUES (3, 3, 1);  -- Dessert x1


SELECT * FROM today_schedule;
SELECT * FROM customer_history ORDER BY customer_id;
SELECT * FROM flagged_customers;
SELECT * FROM revenue;
SELECT * FROM most_ordered_items;

INSERT INTO orders (reservation_id) VALUES (1);  -- order_id 1, status defaults to 'Open'

INSERT INTO order_menuitem (order_id, menu_item_id, quantity_recorded) VALUES (1, 1, 2);  -- Appetizer x2
INSERT INTO order_menuitem (order_id, menu_item_id, quantity_recorded) VALUES (1, 2, 1);  -- Main x1

UPDATE orders SET status = 'closed' WHERE order_id = 1;

-- Order for reservation #2 (Youssef, table 3)
INSERT INTO orders (reservation_id) VALUES (2);  -- order_id 2

INSERT INTO order_menuitem (order_id, menu_item_id, quantity_recorded) VALUES (2, 1, 3);  -- Appetizer x3
INSERT INTO order_menuitem (order_id, menu_item_id, quantity_recorded) VALUES (2, 2, 2);  -- Main x2
INSERT INTO order_menuitem (order_id, menu_item_id, quantity_recorded) VALUES (2, 4, 4);  -- Beverage x4

UPDATE orders SET status = 'closed' WHERE order_id = 2;

-- Order for reservation #3 (Laila, table 4)
INSERT INTO orders (reservation_id) VALUES (3);  -- order_id 3

INSERT INTO order_menuitem (order_id, menu_item_id, quantity_recorded) VALUES (3, 2, 5);  -- Main x5
INSERT INTO order_menuitem (order_id, menu_item_id, quantity_recorded) VALUES (3, 3, 1);  -- Dessert x1

UPDATE orders SET status = 'closed' WHERE order_id = 3;

SELECT * FROM today_schedule;
SELECT * FROM customer_history ORDER BY customer_id;
SELECT * FROM flagged_customers;
SELECT * FROM revenue;
SELECT * FROM most_ordered_items;



--test trigger overllaping time 
INSERT INTO reservations (customer_id, table_number, staff_id, reservation_date, start_time, end_time, party_size, stage_state)
VALUES (2, 2, 1, CURRENT_DATE, '19:30', '20:00', 2, 'confirmed');


INSERT INTO reservations (customer_id, table_number, staff_id, reservation_date, start_time, end_time, party_size, stage_state)
VALUES (1, 2, 1, CURRENT_DATE, '19:30', '20:00', 2, 'confirmed');

-- SHOULD FAIL: not enough stock
INSERT INTO order_menuitem (order_id, menu_item_id, quantity_recorded) VALUES (1, 3, 999);





INSERT INTO orders (reservation_id) VALUES (
    (SELECT reservation_id FROM reservations LIMIT 1 OFFSET 0)  -- or use a known valid id, e.g. 1
);

-- check the new order_id first
SELECT * FROM orders ORDER BY order_id DESC LIMIT 1;

-- add items (replace 4 with whatever order_id just got created)
INSERT INTO order_menuitem (order_id, menu_item_id, quantity_recorded) VALUES (4, 1, 2);  -- Appetizer x2 = 90.00
INSERT INTO order_menuitem (order_id, menu_item_id, quantity_recorded) VALUES (4, 4, 3);  -- Beverage x3 = 60.00

-- close it — should trigger bill calculation
UPDATE orders SET status = 'closed' WHERE order_id = 4;

-- verify: expected bill = (45*2) + (20*3) = 150.00
SELECT order_id, bill FROM orders WHERE order_id = 4;





INSERT INTO reservations (customer_id, table_number, staff_id, reservation_date, start_time, end_time, party_size, stage_state)
VALUES (5, 4, 2, CURRENT_DATE+10, '20:00', '21:30', 12, 'seated');

