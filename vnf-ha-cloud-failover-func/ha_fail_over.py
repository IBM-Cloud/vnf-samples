"""
#*===================================================================
#*
#* Licensed Materials - Property of IBM
#* IBM Cloud Network
#* Copyright IBM Corporation 2020. All Rights Reserved.
#*
#*===================================================================
"""


from ibm_vpc import VpcV1
from ibm_cloud_sdk_core.authenticators import IAMAuthenticator
from ibm_cloud_sdk_core import ApiException
from flask import Flask, request
import json 
import logging, logging.handlers


app = Flask(__name__)


class HAFailOver(object):
    """
        This is the framework that parses the config.json and updates the custom routes.
    """

    APIKEY = "apikey"
    VPC_ID = "vpc_id"
    VPC_URL = "vpc_url"
    ZONE = "zone"
    HA_PAIR = "ha_pair"
    MGMT_IP = "mgmt_ip"
    EXT_IP = "ext_ip"
    LOCATION_DEFAULT = "/tmp/vnf-ha-cloud-failover-func/"
    CONFIGFILE = "config.json"

    apikey = None
    vpc_url = "https://us-south.iaas.cloud.ibm.com"
    vpc_id =''
    table_id = ''
    route_id = ''
    zone = ''
    ha_pair = {}
    temp_ha_pair = {}
    next_hop_vsi = ""
    update_next_hop_vsi = ""
    mgmt_ip_1 = ''
    mgmt_ip_2 = ''
    ext_ip_1 = ''
    ext_ip_2 = ''
    logger = ''

    config_file = "config.json"
    version = "2020-04-10"
    zone = "us-south-1"

    service = None
    
    def __init__(self):
        print("--------constructor---------")
        logfile = '/tmp/vnf-ha-cloud-failover-func/fail_over.log'
        logging.basicConfig(filename=logfile, format='%(asctime)s:%(levelname)s:%(message)s', datefmt='%m/%d/%Y %I:%M:%S %p', level=logging.INFO)
        loghandler = logging.handlers.TimedRotatingFileHandler(logfile,when="midnight")
        self.logger = logging.getLogger(__name__)
        self.logger.addHandler(loghandler)
        if self.apikey is None:
            self.parse_config_json()
        authenticator = IAMAuthenticator(self.apikey)
        self.service = VpcV1(authenticator=authenticator)
        self.service.set_service_url(self.vpc_url)
        self.service = VpcV1(self.version, authenticator=authenticator) 
        self.logger.info("Initialized vpc service")
         
    def parse_config_json(self):
        # Opening JSON file 
        path = self.LOCATION_DEFAULT + self.CONFIGFILE
        file = open(path, "r")
        self.logger.info("Parsing config file")
        # returns JSON object as  
        # a dictionary 
        config = json.load(file) 
        try:
            for item in config:
                if item == self.APIKEY:
                    self.apikey = config[self.APIKEY]
                    self.logger.info("api key " + self.apikey)
                if item == self.VPC_ID:
                    self.vpc_id = config[self.VPC_ID]
                    self.logger.info("vpc id " + self.vpc_id)
                if item == self.VPC_URL:
                    self.vpc_url = config[self.VPC_URL]
                    self.logger.info("vpc url " + self.vpc_url)
                if item == self.ZONE:
                    self.zone = config[self.ZONE]
                    self.logger.info("zone " + self.zone)
                if item == self.HA_PAIR:
                    self.ha_pair = config[self.HA_PAIR]
                    self.logger.info("ha pair " + json.dumps(self.ha_pair))
                    self.mgmt_ip_1 = config[self.HA_PAIR][0][self.MGMT_IP]
                    self.ext_ip_1 = config[self.HA_PAIR][0][self.EXT_IP]
                    self.mgmt_ip_2 = config[self.HA_PAIR][1][self.MGMT_IP]
                    self.ext_ip_2 = config[self.HA_PAIR][1][self.EXT_IP]
                    self.logger.info("mgmt_ip_1 " + self.mgmt_ip_1)
                    self.logger.info("mgmt_ip_2 " + self.mgmt_ip_2)
                    self.logger.info("ext_ip_1 " + self.ext_ip_1)
                    self.logger.info("ext_ip_2 " + self.ext_ip_2)
        except Exception as e:
            self.logger.info("Exception occurred while parsing config.json", e)
        # Closing file 
        file.close()    
            
            
    def update_vpc_routing_table_route(self):   
        self.logger.info("calling update vpc routing table route")    
        self.logger.info("vpc id " + self.vpc_id) 
        list_tables = ''
        if self.service.list_vpc_routing_tables(self.vpc_id).get_result() is not None:
            list_tables = self.service.list_vpc_routing_tables(self.vpc_id).get_result()['routing_tables']
        update_done = False
        for table in list_tables:
            print(table['id'], "\t",  table['name'])
            table_id_temp = table['id']
            list_routes = self.service.list_vpc_routing_table_routes(vpc_id= self.vpc_id, routing_table_id=table_id_temp)
            routes = list_routes.get_result()['routes']
            for route in routes:
                route_id_temp = route['id']
                if route['next_hop']['address'] == self.next_hop_vsi: 
                    self.logger.info("vpc routing table routes found, id: %s, name: %s: " % (route['id'], route['name']))
                    self.logger.info("vpc routing table route, id: %s, name: %s, zone: %s, next_hop:%s, destination:%s " % (route['id'], route['name'], route['zone']['name'], route['next_hop']['address'], route['destination']))
                    zone_identity_model = {'name': route['zone']['name']}
                    route_next_hop_prototype_model = {'address': self.update_next_hop_vsi}
                    # delete old route
                    self.service.delete_vpc_routing_table_route(vpc_id=self.vpc_id, routing_table_id=table_id_temp, id=route_id_temp)
                    self.logger.info("Deleted route " + route_id_temp)
                    # create new route
                    create_vpc_routing_table_route_response = self.service.create_vpc_routing_table_route(vpc_id=self.vpc_id, routing_table_id=table_id_temp, destination=route['destination'], zone=zone_identity_model, action='deliver', next_hop=route_next_hop_prototype_model, name=route['name'])
                    route = create_vpc_routing_table_route_response.get_result()
                    self.logger.info("Created route " + route['id'])
                    update_done = True
        return update_done       
            
            
    def find_ext_ip_ha_pair(self, remote_addr):
        self.logger.info("find mgmt and ext ip " + json.dumps(self.ha_pair))
        temp_ha_pair = self.ha_pair.copy()
        for pair in temp_ha_pair: 
            print(pair[self.MGMT_IP])
            print(pair[self.EXT_IP])
            if pair[self.MGMT_IP] == remote_addr:
                temp_ha_pair.remove(pair)
                self.update_next_hop_vsi = pair[self.EXT_IP]
                self.next_hop_vsi = temp_ha_pair[0][self.EXT_IP]
                self.logger.info("update_next_hop_vsi " + self.update_next_hop_vsi)
                self.logger.info("next_hop_vsi " + self.next_hop_vsi)
                
# update custom route 
@app.route('/')
def update_custom_route():
    haFailOver = HAFailOver()
    print("request received from " + request.remote_addr)
    remote_addr = request.remote_addr
    haFailOver.find_ext_ip_ha_pair(remote_addr)    
    # find all routes of HA1
    made_update = haFailOver.update_vpc_routing_table_route()
    print('updated routing table route')
    return "Updated Custom Route"    


if __name__ == '__main__':
    app.run(host='0.0.0.0', port=3000)
