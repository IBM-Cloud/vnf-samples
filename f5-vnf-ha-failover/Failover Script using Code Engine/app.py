from flask import Flask
from flask import request
from dotenv import load_dotenv
import ha_fail_over

app = Flask(__name__)
load_dotenv('env')

@app.route("/")
def welcome():
        
        app.logger.info("GET Request triggered by VNF: " + request.remote_addr)
        return "Hello World!! Failover Script Running.", 200

@app.route("/f5/failover")
def home():
        app.logger.info("GET Request for Failover Script triggered by VNF with address: " + request.remote_addr)
        return ha_fail_over.update_custom_route(request.remote_addr, app), 200

if __name__ == "__main__":
        app.run(host="0.0.0.0", port=int("3000"), debug=True)