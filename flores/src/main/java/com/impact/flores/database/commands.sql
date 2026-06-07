--роли сотрудников
CREATE TABLE roles(
  role_id SERIAL PRIMARY KEY,
  role_name VARCHAR(50)NOT NULL
);
--Сотрудники
CREATER TABLE employees(
  employee_id SERIAL PRIMARY KEY,
  first_name VARCHAR(50) NOT NULL,
  last_name VARCHAR(50) NOT NULL,
  phone VARCHAR(20),
  role_id