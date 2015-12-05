import MySQLdb
import numpy as np
from scipy.sparse import csr_matrix
import pandas as pd
from scipy import *

db = MySQLdb.connect("localhost","root","root","rangde")

def fetch(userid):
    borrower_occupation_frame = getBorrowerVsOccupationFrame()
    return ['42','43']


def getBorrowerVsOccupationFrame():
    cursor = db.cursor()
    cursor.execute('SELECT id, activity FROM rangde.loan_profiles;')
    id_activities = cursor.fetchall()
    id_list = [ seq[0] for seq in id_activities ]
    activity_list = [ seq[1] for seq in id_activities ]
    return pd.get_dummies(activity_list)
