from flask import Flask
from flask import jsonify
import recsys.cf as cf
import yaml
app = Flask(__name__)

def fetch_configs():
    with open("config.yaml", 'r') as stream:
        configs = yaml.load(stream)
        return configs

cf_provider = cf.CachedCfRecommendation(fetch_configs())

@app.route('/user/<userid>/recommendations')
def serve_recommendation(userid):
    recos = cf_provider.fetch(userid)
    reco_dict = { "borrower_ids" : recos }
    return jsonify(reco_dict)

if __name__ == "__main__":
    app.debug = fetch_configs()["debug_mode"]
    if app.debug is not True:   
        import logging
        from logging.handlers import RotatingFileHandler
        file_handler = RotatingFileHandler('basanti.log', maxBytes=1024 * 1024 * 100, backupCount=20)
        app.logger.addHandler(file_handler)
    app.run()
