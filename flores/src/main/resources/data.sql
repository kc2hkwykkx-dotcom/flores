INSERT INTO flowers(name, description, price, quantity, is_active)
VALUES
('Роза', 'Красная роза', 50, 100, true),
('Тюльпан', 'Жёлтый тюльпан', 30, 150, true),
('Лилия', 'Белая лилия', 70, 80, true)
ON CONFLICT DO NOTHING;

INSERT INTO users(first_name, last_name, phone, email, password, role)
VALUES
('Иван', 'Иванов', '+37360000001', 'ivan@mail.com', '1111', 'USER'),
('Мария', 'Петрова', '+37360000002', 'maria@mail.com', '2222', 'USER')
ON CONFLICT (email) DO NOTHING;

INSERT INTO admins(username, password, email)
VALUES
('admin1', '123456', 'admin1@flowershop.com'),
('admin2', '123456', 'admin2@flowershop.com')
ON CONFLICT DO NOTHING;

INSERT INTO orders(user_id, flower_name, quantity, total_price, status)
VALUES
(1, 'Красная роза', 10, 500.00, 'NEW'),
(1, 'Белая лилия', 5, 350.00, 'PROCESSING'),
(2, 'Тюльпан', 15, 450.00, 'DELIVERED')
ON CONFLICT DO NOTHING;
