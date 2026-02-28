CREATE DATABASE IF NOT EXISTS it_support_db;
USE it_support_db;

DROP TABLE IF EXISTS ticket_comments;
DROP TABLE IF EXISTS tickets;
DROP TABLE IF EXISTS devices;
DROP TABLE IF EXISTS users;
DROP TABLE IF EXISTS teams;

CREATE TABLE teams (
  team_id INT AUTO_INCREMENT PRIMARY KEY,
  team_name VARCHAR(100) NOT NULL UNIQUE
);

CREATE TABLE users (
  user_id INT AUTO_INCREMENT PRIMARY KEY,
  full_name VARCHAR(120) NOT NULL,
  email VARCHAR(150) NOT NULL UNIQUE,
  role VARCHAR(30) NOT NULL,
  team_id INT,
  created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
  FOREIGN KEY (team_id) REFERENCES teams(team_id)
);

CREATE TABLE devices (
  device_id INT AUTO_INCREMENT PRIMARY KEY,
  asset_tag VARCHAR(50) NOT NULL UNIQUE,
  device_type VARCHAR(30) NOT NULL,
  os VARCHAR(50),
  assigned_user_id INT,
  purchased_on DATE,
  FOREIGN KEY (assigned_user_id) REFERENCES users(user_id)
);

CREATE TABLE tickets (
  ticket_id INT AUTO_INCREMENT PRIMARY KEY,
  title VARCHAR(200) NOT NULL,
  description TEXT NOT NULL,
  status VARCHAR(20) NOT NULL,
  priority VARCHAR(10) NOT NULL,
  category VARCHAR(30) NOT NULL,
  requester_id INT NOT NULL,
  agent_id INT,
  device_id INT,
  created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
  resolved_at TIMESTAMP NULL,
  FOREIGN KEY (requester_id) REFERENCES users(user_id),
  FOREIGN KEY (agent_id) REFERENCES users(user_id),
  FOREIGN KEY (device_id) REFERENCES devices(device_id)
);

CREATE TABLE ticket_comments (
  comment_id INT AUTO_INCREMENT PRIMARY KEY,
  ticket_id INT NOT NULL,
  author_id INT NOT NULL,
  comment_text TEXT NOT NULL,
  created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
  FOREIGN KEY (ticket_id) REFERENCES tickets(ticket_id),
  FOREIGN KEY (author_id) REFERENCES users(user_id)
);

INSERT INTO teams (team_name) VALUES
('IT Support - Cork'),
('IT Support - Dublin');

INSERT INTO users (full_name, email, role, team_id) VALUES
('Ana Silva', 'ana.silva@example.com', 'EndUser', NULL),
('Bruno Costa', 'bruno.costa@example.com', 'EndUser', NULL),
('Carla Mendes', 'carla.mendes@example.com', 'Agent', 1),
('Daniel OBrien', 'daniel.obrien@example.com', 'Agent', 2);

INSERT INTO devices (asset_tag, device_type, os, assigned_user_id, purchased_on) VALUES
('CORK-LAP-001', 'Laptop', 'Windows 11', 1, '2024-10-01'),
('CORK-LAP-002', 'Laptop', 'macOS', 2, '2023-06-15');

INSERT INTO tickets (title, description, status, priority, category, requester_id, agent_id, device_id)
VALUES
('Cannot connect to Wi-Fi', 'User cannot connect to office Wi-Fi network.', 'Resolved', 'High', 'Network', 1, 3, 1),
('Email access issue', 'Password reset needed for Outlook account.', 'In Progress', 'Medium', 'Access', 2, 3, 2),
('Laptop running slow', 'Performance issue after updates.', 'Open', 'Low', 'Software', 1, NULL, 1);

INSERT INTO ticket_comments (ticket_id, author_id, comment_text) VALUES
(1, 3, 'Checked router and re-registered device on network.'),
(2, 3, 'Requested user verification details for reset.');

USE it_support_db;
SHOW TABLES;
SELECT * FROM tickets;

USE it_support_db;

-- 1) Tickets by status
SELECT status, COUNT(*) AS ticket_count
FROM tickets
GROUP BY status
ORDER BY ticket_count DESC;

-- 2) Open/In Progress tickets with requester and device
SELECT
  t.ticket_id, t.title, t.status, t.priority, t.category,
  u.full_name AS requester,
  d.asset_tag, d.device_type, d.os,
  t.created_at
FROM tickets t
JOIN users u ON u.user_id = t.requester_id
LEFT JOIN devices d ON d.device_id = t.device_id
WHERE t.status IN ('Open', 'In Progress')
ORDER BY FIELD(t.priority,'Urgent','High','Medium','Low'), t.created_at ASC;

-- 3) Workload per agent (assigned tickets)
SELECT
  a.full_name AS agent,
  COUNT(*) AS assigned_tickets
FROM tickets t
JOIN users a ON a.user_id = t.agent_id
GROUP BY a.full_name
ORDER BY assigned_tickets DESC;

-- 4) Average resolution time (hours) for resolved tickets
SELECT
  ROUND(AVG(TIMESTAMPDIFF(HOUR, created_at, resolved_at)), 2) AS avg_resolution_hours
FROM tickets
WHERE resolved_at IS NOT NULL;

-- 5) Tickets by category and priority
SELECT category, priority, COUNT(*) AS ticket_count
FROM tickets
GROUP BY category, priority
ORDER BY category, ticket_count DESC;

-- 6) Tickets with number of comments
SELECT
  t.ticket_id,
  t.title,
  COUNT(c.comment_id) AS comment_count
FROM tickets t
LEFT JOIN ticket_comments c ON c.ticket_id = t.ticket_id
GROUP BY t.ticket_id, t.title
ORDER BY comment_count DESC, t.ticket_id ASC;