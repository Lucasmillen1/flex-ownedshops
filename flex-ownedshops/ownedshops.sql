CREATE TABLE IF NOT EXISTS `ownedshops` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `shopname` varchar(255) NOT NULL,
  `owner` varchar(50) NOT NULL,
  `owned` tinyint(1) NOT NULL DEFAULT 0,
  `stock` longtext DEFAULT NULL,
  `bank_account_balance` decimal(10,2) NOT NULL DEFAULT 0.00,
  `last_updated` timestamp NOT NULL DEFAULT current_timestamp() ON UPDATE current_timestamp(),
  `bank` tinyint(1) NOT NULL DEFAULT 0,
  KEY `owner` (`owner`),
  KEY `id` (`id`),
  KEY `last_updated` (`last_updated`)
) ENGINE=InnoDB AUTO_INCREMENT=5 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;
