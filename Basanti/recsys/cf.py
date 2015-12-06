import MySQLdb
import numpy as np
from scipy.sparse import csr_matrix
import pandas as pd
from scipy import *
import time
import logging
import datetime
import execute_sql_script


investor_table_query = """select investor_id,borrower_district as dim1 , fractionamt , 'act' as tb from pie_district 
UNION select investor_id,borrower_state as dim1 , fractionamt, 'st' as tb from pie_state 
UNION select investor_id,activity as dim1 , fractionamt, 'act' as tb from pie_activity 
UNION select investor_id,month1 as dim1 , fractionamt, 'mo' as tb from pie_month ORDER BY 2;"""

borrower_table_query = """SELECT id as brid, borrower_district as dim2, 1.0 as rating from loan_profiles
UNION
SELECT id as brid, borrower_state as dim2, 1.0 as rating from loan_profiles
UNION
SELECT id as brid, SUBSTR(published_date,6,2) as dim2, 1.0 as rating from loan_profiles
UNION
SELECT id as brid, activity as dim2, 1.0 as rating from loan_profiles ORDER BY 2;"""


class CachedCfRecommendation:
    def getInvestorFrame(self):
        cursor = self.db.cursor()
        cursor.execute(investor_table_query)
        investor_feature_tuples = cursor.fetchall()
#        investor_list = [ seq[0] for seq investor_feature_tuples ]
        long_frame = pd.DataFrame(data=list(investor_feature_tuples), columns=["id", "Attribute", "Score", "something"])
        wide_frame = long_frame.pivot_table(values='Score', index='id', columns='Attribute', aggfunc='sum')
        return wide_frame

    def getBorrowerFrame(self):
        cursor = self.db.cursor()
        cursor.execute(borrower_table_query)
        borrower_feature_tuples = cursor.fetchall()
#        borrower_list = [ seq[0] for seq in borrower_feature_tuples ]
        long_frame = pd.DataFrame(data=list(borrower_feature_tuples), columns=["id", "Attribute", "Score"])
        wide_frame = long_frame.pivot_table(values='Score', index='id', columns='Attribute', aggfunc='sum')
        return wide_frame

    def calculateFrame(self):
        investor_frame = self.getInvestorFrame()
        borrower_frame = self.getBorrowerFrame().transpose()
        return investor_frame.fillna(0.0).astype(float).dot(borrower_frame.fillna(0.0).astype(float))

    def get_cached_frame(self):
        if (self.cached_frame is None or time.time() - self.cached_time > self.refresh_interval):
            execute_sql_script.execute_from_file("recsys/build_temp_tables.sql", self.db.cursor)
            self.cached_frame = self.calculateFrame();
        return self.cached_frame

    def fetch(self, userid):
        final_frame = self.get_cached_frame()
        return final_frame.ix[int(userid)].order(ascending=False).nlargest(10).to_json()

    def __init__(self, configs):
        self.db = MySQLdb.connect(configs["db_host"], configs["db_user"], configs["db_password"], "rangde")
        self.refresh_interval = configs["refresh_interval"]
        self.cached_frame = None
        self.cached_time = time.time()
        self.logger = logging.getLogger("Rotating Log")
