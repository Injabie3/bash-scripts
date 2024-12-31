#!/usr/bin/env python3
# 2023-10-29
# Injabie3
#
# Description:
# BC Hydro
# BC Hydro CSV to SQL database
# This script parses a CSV file from bchydro.com and inserts it into a database.

from collections import namedtuple
import argparse
import datetime
import glob
import csv
import logging
import os

import mysql.connector
from mysql.connector.connection import MySQLConnection
from mysql.connector.cursor import MySQLCursor

logger = logging.getLogger("BcHydroDb")
if logger.level == logging.NOTSET:
    logger.setLevel(logging.INFO)
    console = logging.StreamHandler()
    console.setFormatter(
        logging.Formatter("%(asctime)s %(message)s", datefmt="[%Y/%m/%d %H:%M:%S]")
    )
    logger.addHandler(console)

PowerData = namedtuple(
    "PowerData",
    (
        "user",
        "accId",
        "meterNum",
        "timestamp",
        "timeOfDayPeriod",
        "inflow",
        "outflow",
        "netConsumption",
        "demand",
        "powerFactor",
        "estUsage",
        "addr",
        "city",
    ),
)


class BcHydroData:
    """This class is for loading CSV file from BC Hydro"""

    def __init__(self, filename: str) -> None:
        self.fileHandle = open(filename, "r")
        self._reader = csv.reader(self.fileHandle)
        # Skip the first header line
        next(self._reader)

        def dataGenerator() -> PowerData:
            """Generator for reading the BC Hydro data"""
            for line in self._reader:
                yield PowerData(*line)

        self.logger: logging.Logger = logging.getLogger("BcHydroDb")
        self.data = dataGenerator()
        self.cursor: MySQLCursor = None
        self.db: MySQLConnection = None
        self.filename: str = filename
        self._connectToDb()

    def __del__(self) -> None:
        self.fileHandle.close()
        self.db.disconnect()

    def _connectToDb(self) -> None:
        """Connect to the database"""
        self.db = mysql.connector.connect(
            host=os.environ["DB_HOST"],
            user=os.environ["DB_USER"],
            password=os.environ["DB_PASS"],
            database=os.environ["DB_DATABASE"],
        )
        self.cursor = self.db.cursor()

    def _saveHourlyUsageToDb(self) -> None:
        """Run the query to insert basic hourly usage data to DB"""
        query = (
            "REPLACE INTO bchydro.usage "
            "( id, timestamp, `usage` ) VALUES "
            "(%s, %s, %s)"
        )
        self.logger.info("Saving hourly data")
        for row in self.data:
            try:
                usage = float(row.netConsumption)
            except ValueError:
                self.logger.error(
                    "Unable to convert usage to float, got %s, " "skipping %s",
                    row.netConsumption,
                    row.timestamp,
                )
                continue
            values = (row.accId, row.timestamp, usage)
            self.cursor.execute(query, values)
            self.logger.debug("Saving basic data for %s: %s", row.accId, row.timestamp)

    def addUserToDb(self) -> None:
        """Add this user to the database

        This must be run once per user ID in order for the saveToDb method to
        work.
        """
        pass

    def saveToDb(self) -> None:
        self.logger.info("Pushing %s to DB", self.filename)
        self._saveHourlyUsageToDb()
        self.db.commit()


if __name__ == "__main__":
    parser = argparse.ArgumentParser(description="Push BC Hydro data in database")
    group = parser.add_mutually_exclusive_group(required=True)
    group.add_argument(
        "--dir",
        type=str,
        help="Path to the folder containing *.csv files obtained from BC Hydro. "
        "Useful if you have exported data over time.",
    )
    group.add_argument(
        "--file", type=str, help="Path to a single .csv file obtained from BC Hydro."
    )
    # TODO
    # group.add_argument(
    #     "--add-user",
    #     action="store_true",
    #     help="Add the user to the database. This is done using the first data row "
    #     "of the CSV file.",
    # )
    parser.add_argument(
        "--debug",
        required=False,
        action="store_true",
        help="Enable debug logging.",
    )
    parser.add_argument
    args = parser.parse_args()
    if args.debug:
        logger.setLevel(logging.DEBUG)

    if args.dir:
        if not os.path.isdir(args.dir):
            print(f'"{args.inputPath}" is not a valid input data path!')
            exit()
        path = os.path.abspath(args.dir)  # No trailing slash
        filelist = glob.glob("{}/*.csv".format(path))
        filelist.sort()
    else:
        filelist = [args.file]

    for csvFilePath in filelist:
        try:
            bcHydro = BcHydroData(csvFilePath)
            bcHydro.saveToDb()
        except mysql.connector.errors.IntegrityError as error:
            logger.error(
                "The user is not in the database, please add them first!", exc_info=True
            )
        except ValueError:
            logger.error("%s has an error, skipping", csvFilePath)
            raise
