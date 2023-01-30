#!/usr/bin/env python3
# 2023-01-28
# Injabie3
#
# Description:
# iDOLM@STER Cinderella Girls Starlight Stage
# deresute.me JSON to SQL database
# This script parses the JSON file from deresute.me and inserts it into a database.

import argparse
import datetime
import glob
import json
import logging
import os

import mysql.connector

logger = logging.getLogger("DeresuteDb")
if logger.level == logging.NOTSET:
    logger.setLevel(logging.INFO)
    console = logging.StreamHandler()
    console.setFormatter(logging.Formatter("%(asctime)s %(message)s",
                                           datefmt="[%Y/%m/%d %H:%M:%S]"))
    logger.addHandler(console)

class DeresuteUserData:
    """This class is for loading one JSON file from deresute.me"""

    def __init__(self, filename: str) -> None:
        with open(filename, "r") as fileHandle:
            self.content = json.load(fileHandle)
        self.filename: str = filename
        self.logger: logging.Logger = logging.getLogger("DeresuteDb")
        self.timestamp = datetime.datetime.utcfromtimestamp(self.content["timestamp"])
        self.db  = None
        self.cursor = None

    def __del__(self) -> None:
        # TODO Disconnect from DB
        pass

    def __str__(self) -> str:
        return (f"DeresuteUserData ID {self.content['id']} "
                f"Timestamp {self.content['timestamp']}")

    def _connectToDb(self):
        """Connect to the database"""
        self.db = mysql.connector.connect(
            host=os.environ["DB_HOST"],
            user=os.environ["DB_USER"],
            password=os.environ["DB_PASS"],
            database=os.environ["DB_DATABASE"])
        self.cursor = self.db.cursor()

    def _saveBasicInfoToDb(self):
        """Run the query to insert basic data"""
        query = ("REPLACE INTO deresute.basicInfo "
                 "( uid, timestamp, lastLogin, level, fan, prp, `rank`,"
                 "  emblemId, emblemExValue, albumNo, comment, name ) VALUES "
                 "(%s, %s, %s, %s, %s, %s, %s, %s, %s, %s, %s, %s )")
        values = (self.content["id"],
                  self.timestamp,
                  datetime.datetime.utcfromtimestamp(self.content["last_login_ts"]),
                  self.content["level"],
                  self.content["fan"],
                  self.content["prp"],
                  self.content["rank"],
                  self.content.get( "emblem_id", "NULL" ),
                  self.content.get( "emblem_ex_value", "NULL" ),
                  self.content["album_no"],
                  self.content["comment"],
                  self.content["name"],)
        self.cursor.execute(query, values)
        self.logger.debug("Saving basic data")

    def _saveSongData(self, table: str, statType: str):
        if table not in ("fullComboInfo", "clearedInfo"):
            raise ValueError(f"Table {table} is unknown!")
        if statType not in ("cleared", "full_combo"):
            raise ValueError(f"State {statType} is unknown!")

        query = (f"REPLACE INTO {table} "
                 "( uid, timestamp, debut, normal, pro, master, masterplus, "
                 "  light, trick ) VALUES "
                 "(%s, %s, %s, %s, %s, %s, %s, %s, %s)")
        # The following should always exist, otherwise raise KeyError
        stat = self.content[statType]
        values = (self.content["id"],
                  self.timestamp,
                  stat["debut"],
                  stat["normal"],
                  stat["pro"],
                  stat["master"],
                  stat["master_plus"],
                  stat["light"],
                  stat["trick"],)
        self.cursor.execute(query, values)

    def _saveCardData(self, cardType: str, cardAttribute: str = None):
        if cardType not in ("leader_card", "support_cards"):
            raise TypeError(f"Card type {cardType} is unknown!")
        if (cardType == "support_cards" and
            cardAttribute not in ("cute", "passion", "cool", "all")):
            raise TypeError(f"Card attribute {cardAttribute} is unknown!")

        lookup = self.content[ cardType ]
        cType = "leader"
        if cardType == "support_cards":
            lookup = lookup[ cardAttribute ]
            cType = cardAttribute
        query = ("REPLACE INTO cardInfo "
                 f"(uid, timestamp, type, cid, love, level, exp, starRank,"
                 "  skillLevel, imageId, potentialVocal, potentialDance,"
                 "  potentialVisual, potentialLife ) VALUES "
                 "(%s, %s, %s, %s, %s, %s, %s, %s, %s, %s, %s, %s, %s, %s)")
        values = (self.content["id"],
                  self.timestamp,
                  cType,
                  lookup["id"],
                  lookup["love"],
                  lookup["level"],
                  lookup["exp"],
                  lookup["star_rank"],
                  lookup["skill_level"],
                  lookup["image_id"],
                  lookup["potential"]["vocal"],
                  lookup["potential"]["dance"],
                  lookup["potential"]["visual"],
                  lookup["potential"]["life"],)
        self.logger.debug("Saving card type %s", cType)
        self.cursor.execute(query, values)

    def _saveClearedInfoToDb(self):
        """Run the query to insert cleared data"""
        self.logger.debug("Saving cleared data")
        self._saveSongData("clearedInfo", "cleared")

    def _saveFullComboInfoToDb(self):
        """Run the query to insert full combo data"""
        self.logger.debug("Saving full combo data")
        self._saveSongData("fullComboInfo", "full_combo")

    def _saveCardInfoToDb(self):
        """Run the query to insert card data"""
        self.logger.debug("Saving card data")
        self._saveCardData("leader_card")
        self._saveCardData("support_cards", "all")
        self._saveCardData("support_cards", "cool")
        self._saveCardData("support_cards", "cute")
        self._saveCardData("support_cards", "passion")

    def addUserToDb(self) -> None:
        """Add this user to the database

        This must be run once per user ID in order for the saveToDb method to
        work.
        """
        pass

    def saveToDb(self) -> None:
        self.logger.info("Pushing %s to DB", self.filename)
        self._connectToDb()
        self._saveBasicInfoToDb()
        self._saveClearedInfoToDb()
        self._saveFullComboInfoToDb()
        self._saveCardInfoToDb()
        self.db.commit()


if __name__ == "__main__":
    parser = argparse.ArgumentParser(description="Push deresute data in database")
    group = parser.add_mutually_exclusive_group(required=True)
    group.add_argument("--dir", type=str, help="Path to the folder containing *.json "
                        "files obtained from deresute.me.")
    group.add_argument("--file", type=str, help="Path to a single .json file "
                        "obtained from deresute.me.")
    parser.add_argument("--debug", required=False,
                        action="store_true",
                        help="Path to the folder containing *.json "
                        "files obtained from deresute.me.")
    parser.add_argument
    args = parser.parse_args()
    if args.debug:
        logger.setLevel(logging.DEBUG)

    if args.dir:
        if not os.path.isdir(args.dir):
            print("\"{}\" is not a valid input data path!".format(args.inputPath))
            exit()
        path = os.path.abspath(args.dir) # No trailing slash
        filelist = glob.glob("{}/*.json".format(path))
        filelist.sort()
    else:
        filelist = [ args.file ]

    for jsonFilePath in filelist:
        deresute = DeresuteUserData(jsonFilePath)
        deresute.saveToDb()
