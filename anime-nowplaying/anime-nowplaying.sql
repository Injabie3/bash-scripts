SELECT * FROM lui.malupdater;CREATE TABLE `malupdater` (
  `ID` int NOT NULL AUTO_INCREMENT,
  `timestamp` timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP COMMENT 'Time in which the update was received.',
  `public` tinyint NOT NULL DEFAULT '1' COMMENT 'Whether this update should be shown on the web portal. Defaults to true.',
  `user` text COLLATE utf8mb3_unicode_ci NOT NULL COMMENT 'MAL Username',
  `animeID` int DEFAULT NULL COMMENT 'The MAL anime ID, which allows for easy link to the MAL page, or perhaps to link other information from the anime.',
  `name` varchar(100) CHARACTER SET utf8mb3 NOT NULL COMMENT 'The name of the Anime series/movie.',
  `season` tinyint DEFAULT '0' COMMENT 'The season of the anime',
  `ep` varchar(10) CHARACTER SET utf8mb3 NOT NULL COMMENT 'Current episode that was played.',
  `eptotal` varchar(10) COLLATE utf8mb3_unicode_ci NOT NULL COMMENT 'Total episodes from the series',
  `picurl` varchar(300) CHARACTER SET utf8mb3 NOT NULL COMMENT 'Anime cover URL. Noted to expire after a certain period as it is from a CDN.',
  PRIMARY KEY (`ID`)
) ENGINE=InnoDB AUTO_INCREMENT=1 DEFAULT CHARSET=utf8mb3 COLLATE=utf8mb3_unicode_ci;
