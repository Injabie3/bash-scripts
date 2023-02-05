# 2023-02-04
# Injabie3
#
# Description:
# iDOLM@STER Cinderella Girls Starlight Stage
# deresute.me SQL schema creation script
# This SQL script creates the schema and tables required by deresute-db.py

CREATE DATABASE `deresute` /*!40100 DEFAULT CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci */ /*!80016 DEFAULT ENCRYPTION='N' */;
CREATE TABLE `users` (
  `uid` int NOT NULL COMMENT 'Unique user ID',
  `name` varchar(45) DEFAULT NULL COMMENT 'Name of the person that owns this user ID',
  `creationTs` datetime DEFAULT NULL COMMENT 'Epoch time when this user was created, UTC time.',
  PRIMARY KEY (`uid`),
  UNIQUE KEY `uid_UNIQUE` (`uid`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;
CREATE TABLE `basicInfo` (
  `uid` int NOT NULL COMMENT 'User ID',
  `timestamp` datetime NOT NULL COMMENT 'Epoch timestamp of when this information was retrieved, UTC time.',
  `lastLogin` datetime NOT NULL COMMENT 'Epoch of last time the user logged in, UTC time.',
  `level` int NOT NULL COMMENT 'Producer level',
  `fan` bigint NOT NULL COMMENT 'Total fans',
  `prp` int NOT NULL COMMENT 'PRP',
  `rank` int NOT NULL COMMENT 'User rank, should be:\\\\\\\\n- 1: F\\\\\\\\n- 2: E\\\\\\\\n- 3: D\\\\\\\\n- 4: C\\\\\\\\n- 5: B\\\\\\\\n- 6: A\\\\\\\\n- 7: S\\\\\\\\n- 8: SS\\\\\\\\n- 9: SSS',
  `emblemId` int DEFAULT NULL COMMENT 'No idea what this is.',
  `emblemExValue` varchar(50) DEFAULT NULL COMMENT 'No idea what this is.',
  `albumNo` int NOT NULL COMMENT 'Number of cards in producer album',
  `comment` varchar(200) DEFAULT NULL,
  `name` varchar(50) DEFAULT NULL,
  PRIMARY KEY (`uid`,`timestamp`),
  CONSTRAINT `fk_basicInfo_uid` FOREIGN KEY (`uid`) REFERENCES `users` (`uid`) ON DELETE CASCADE ON UPDATE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;
CREATE TABLE `cardInfo` (
  `uid` int NOT NULL COMMENT 'User ID',
  `timestamp` datetime NOT NULL COMMENT 'Epoch timestamp of when this information was retrieved, UTC time.',
  `type` varchar(10) NOT NULL COMMENT 'The card type, one of: \n- leader\n- cute\n- cool\n- passion',
  `cid` int NOT NULL COMMENT 'Card ID',
  `love` int NOT NULL COMMENT 'Character''s affection.',
  `level` int NOT NULL COMMENT 'Leader card''s level',
  `exp` int NOT NULL COMMENT 'Card experience',
  `starRank` smallint NOT NULL COMMENT 'The card''s star rank.	',
  `skillLevel` int NOT NULL COMMENT 'The card''s skill activation level.',
  `imageId` int NOT NULL COMMENT 'The card''s image ID.',
  `potentialVocal` smallint NOT NULL,
  `potentialDance` smallint NOT NULL,
  `potentialLife` smallint NOT NULL,
  `potentialVisual` smallint NOT NULL,
  PRIMARY KEY (`uid`,`timestamp`,`type`),
  CONSTRAINT `fk_leadercard_uid` FOREIGN KEY (`uid`) REFERENCES `users` (`uid`) ON DELETE CASCADE ON UPDATE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;
CREATE TABLE `fullComboInfo` (
  `uid` int NOT NULL COMMENT 'User ID',
  `timestamp` datetime NOT NULL COMMENT 'Epoch timestamp of when this information was retrieved',
  `debut` int DEFAULT NULL COMMENT 'Basic live: Debut difficulty',
  `normal` int DEFAULT NULL COMMENT 'Basic live: Normal difficulty',
  `pro` int DEFAULT NULL COMMENT 'Basic live: Pro difficulty',
  `master` int DEFAULT NULL COMMENT 'Basic live: Master difficulty',
  `masterplus` int DEFAULT NULL COMMENT 'Basic live: Master+ difficulty',
  `light` int DEFAULT NULL COMMENT 'Smart (vertical) live: Light difficulty',
  `trick` int DEFAULT NULL COMMENT 'Smart (vertical) live: Trick difficulty',
  PRIMARY KEY (`uid`,`timestamp`),
  CONSTRAINT `fk_fullcombo_uid` FOREIGN KEY (`uid`) REFERENCES `users` (`uid`) ON DELETE CASCADE ON UPDATE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;

