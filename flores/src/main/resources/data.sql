INSERT INTO flowers(name, description, price, quantity, is_active)
VALUES
('Rose', 'Red rose', 50, 100, true),
('Tulip', 'Yellow tulip', 30, 150, true),
('Lily', 'White lily', 70, 80, true);

INSERT INTO users(first_name, last_name, phone, email, password, role)
VALUES
('Ivan', 'Ivanov', '+37360000001', 'ivan@mail.com', '1111', 'USER'),
('Maria', 'Petrova', '+37360000002', 'maria@mail.com', '2222', 'USER');

INSERT INTO admins(username, password, email)
VALUES
('admin1', '123456', 'admin1@flowershop.com'),
('admin2', '123456', 'admin2@flowershop.com');

INSERT INTO orders(user_id, flower_name, quantity, total_price, status)
VALUES
(1, 'Red rose', 10, 500.00, 'NEW'),
(1, 'White lily', 5, 350.00, 'PROCESSING'),
(2, 'Tulip', 15, 450.00, 'DELIVERED');
