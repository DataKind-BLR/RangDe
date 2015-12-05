import MySQLdb
import numpy as np
from scipy.sparse import csr_matrix
import pandas as pd
from scipy import *
import time
import logging
import datetime

class CachedCfRecommendation:
    def refreshBorrowerVsOccupationFrame(self):
        cursor = self.db.cursor()
        cursor.execute('SELECT id, activity FROM rangde.loan_profiles;')
        id_activities = cursor.fetchall()
        id_list = [ seq[0] for seq in id_activities ]
        activity_list = [ seq[1] for seq in id_activities ]
        return pd.get_dummies(activity_list)

    def getBorrowerVsOccupationFrame(self):
        if (self.cached_frame is None or time.time() - self.cached_time > self.refresh_interval):
            self.logger.info("DataFrame refreshed at %s", datetime.datetime.now())
            self.cached_frame = self.refreshBorrowerVsOccupationFrame();
        return self.cached_frame

    def fetch(self, userid):
        borrower_occupation_frame = self.getBorrowerVsOccupationFrame()
        return ['42','43']

    def __init__(self, configs):
        self.db = MySQLdb.connect(configs["db_host"], configs["db_user"], configs["db_password"], "rangde")
        self.refresh_interval = configs["refresh_interval"]
        self.cached_frame = None
        self.cached_time = time.time()
        self.logger = logging.getLogger("Rotating Log")
    
