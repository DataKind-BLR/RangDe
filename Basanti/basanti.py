from flask import Flask
from flask import jsonify
import recsys.cf as cf
app = Flask(__name__)

@app.route('/user/<userid>/recommendations')
def serve_recommendation(userid):
    recos = cf.fetch(userid)
    reco_dict = { "borrower_ids" : recos }
    return jsonify(reco_dict)

if __name__ == "__main__":
    app.debug = True  # This is an internal API. This will come in handy.
    app.run()
