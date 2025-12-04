-- Bennys Tuning System SQL Setup
-- Import diese Datei in deine Datenbank für die initialen Tabellen

-- Fahrzeug-Tuning Tabelle
CREATE TABLE IF NOT EXISTS vehicle_tuning (
    id INT AUTO_INCREMENT PRIMARY KEY,
    vehicle_id INT NOT NULL,
    owner_identifier VARCHAR(100) NOT NULL,
    owner_name VARCHAR(100),
    model VARCHAR(50),
    engine_level INT DEFAULT 0,
    brakes_level INT DEFAULT 0,
    transmission_level INT DEFAULT 0,
    wheels_level INT DEFAULT 0,
    suspension_level INT DEFAULT 0,
    exhaust_level INT DEFAULT 0,
    armor_level INT DEFAULT 0,
    paint_level INT DEFAULT 0,
    windows_level INT DEFAULT 0,
    lights_level INT DEFAULT 0,
    total_invested INT DEFAULT 0,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    UNIQUE KEY unique_vehicle_tuning (vehicle_id, owner_identifier),
    INDEX idx_owner (owner_identifier),
    INDEX idx_created (created_at)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- Tuning-Verlauf Tabelle
CREATE TABLE IF NOT EXISTS tuning_history (
    id INT AUTO_INCREMENT PRIMARY KEY,
    vehicle_id INT NOT NULL,
    owner_identifier VARCHAR(100) NOT NULL,
    owner_name VARCHAR(100),
    part_category VARCHAR(50),
    old_level INT,
    new_level INT,
    cost INT,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    INDEX idx_owner (owner_identifier),
    INDEX idx_vehicle (vehicle_id),
    INDEX idx_created (created_at)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- Demo-Daten (optional)
INSERT IGNORE INTO vehicle_tuning (vehicle_id, owner_identifier, owner_name, model, engine_level, brakes_level, total_invested) 
VALUES 
(1, 'char1:12345', 'Demo Player', 'sabregt', 2, 1, 13000),
(2, 'char1:12345', 'Demo Player', 'blade', 1, 2, 8000);

INSERT INTO tuning_history (vehicle_id, owner_identifier, owner_name, part_category, new_level, cost)
VALUES
(1, 'char1:12345', 'Demo Player', 'engine', 2, 8000),
(1, 'char1:12345', 'Demo Player', 'brakes', 1, 3000),
(1, 'char1:12345', 'Demo Player', 'transmission', 1, 4000);
