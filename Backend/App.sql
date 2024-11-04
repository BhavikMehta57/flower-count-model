CREATE DATABASE flower_model_db;
USE flower_model_db;

CREATE TABLE users (
    id INT PRIMARY KEY AUTO_INCREMENT,
    username VARCHAR(50) UNIQUE NOT NULL,
    password_hash VARCHAR(255) NOT NULL,
    token VARCHAR(255),
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    application VARCHAR(255),
    disabled BOOLEAN
);

SELECT * FROM users;