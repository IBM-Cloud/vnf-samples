from ibm_vpc import VpcV1
from ibm_cloud_sdk_core.authenticators import IAMAuthenticator
from os import environ as env

class HAFailOver(object):
   # Parameter to be passed while creating a Code Engine Instance.
    API_KEY = "API_KEY"
    VPC_ID = "VPC_ID"
    VPC_URL = "VPC_URL"
    ZONE = "ZONE"
    ROUTING_TABLE_NAME = "ROUTING_TABLE_NAME"
    MGMT_IP_1 = "MGMT_IP_1"
    EXT_IP_1 = "EXT_IP_1"
    MGMT_IP_2 = "MGMT_IP_2"
    EXT_IP_2 = "EXT_IP_2"
    LOCATION_DEFAULT = "/tmp/vnf-ha-cloud-failover-func/"

    apikey = None
    vpc_url = ""
    vpc_id =''
    table_id = ''
    route_id = ''
    zone = ''
    routing_table_name = ""
    next_hop_vsi = ""
    update_next_hop_vsi = ""
    mgmt_ip_1 = ''
    mgmt_ip_2 = ''
    ext_ip_1 = ''
    ext_ip_2 = ''
    logger = ''

    #config_file = "config.json"
    version = "2022-09-13"
    #zone = "us-south-1"

    service = None
    
    def __init__(self, app):
        app.logger.info("--------Constructor---------")
        if self.apikey is None:
            self.parse_config(app)
        authenticator = IAMAuthenticator(self.apikey, url='https://iam.cloud.ibm.com')
        self.service = VpcV1(authenticator=authenticator)
        self.service.set_service_url(self.vpc_url)
        app.logger.info("Initialized VPC service!!")

    def parameterException(missingParameter):
        raise Exception("Please!!! provide " + missingParameter)
         
    def parse_config(self, app):
        try:
            if self.API_KEY in env:
                self.apikey = env[self.API_KEY]
                app.logger.info(self.API_KEY + ": " + self.apikey)
            else:
                self.parameterException(self.API_KEY)
            
            if self.VPC_ID in env:
                self.vpc_id = env[self.VPC_ID]
                app.logger.info(self.VPC_ID + ": " + self.vpc_id)
            else:
                self.parameterException(self.VPC_ID)
            
            if self.VPC_URL in env:
                self.vpc_url = env[self.VPC_URL]
                app.logger.info(self.VPC_URL + ": " + self.vpc_url)
            else:
                self.parameterException(self.VPC_URL)

            if self.ZONE in env:
                self.zone = env[self.ZONE]
                app.logger.info(self.ZONE + ": " + self.zone)
            else:
                self.parameterException(self.ZONE)
            
            if self.ROUTING_TABLE_NAME in env:
                self.routing_table_name = env[self.ROUTING_TABLE_NAME]
                app.logger.info(self.ROUTING_TABLE_NAME +  ": " + self.routing_table_name)
            else:
                self.parameterException(self.ROUTING_TABLE_NAME)

            if self.MGMT_IP_1 in env:
                self.mgmt_ip_1 = env[self.MGMT_IP_1]
                app.logger.info("Managment IP 1: " + self.mgmt_ip_1)
            else:
                self.parameterException(self.MGMT_IP_1)

            if self.EXT_IP_1 in env:
                self.ext_ip_1 = env[self.EXT_IP_1]
                app.logger.info("External IP 1: " + self.ext_ip_1)
            else:
                self.parameterException(self.EXT_IP_1)

            if self.MGMT_IP_2 in env:
                self.mgmt_ip_2 = env[self.MGMT_IP_2]
                app.logger.info("Managment IP 1: " + self.mgmt_ip_2)
            else:
                self.parameterException(self.MGMT_IP_2)

            if self.EXT_IP_2 in env:
                self.ext_ip_2 = env[self.EXT_IP_2]
                app.logger.info("External IP 1: " + self.ext_ip_2)
            else:
                self.parameterException(self.EXT_IP_2)

        except Exception as e:
            app.logger.info("--Parameter Missing Exception-- ", e)    
            
    def update_vpc_routing_table_route(self, app):   
        app.logger.info("Calling update vpc routing table route method.")    
        app.logger.info("VPC ID: " + self.vpc_id) 
        list_tables = ''
        authenticator = IAMAuthenticator(self.apikey, url='https://iam.cloud.ibm.com')
        self.service = VpcV1(authenticator=authenticator)
        self.service.set_service_url(self.vpc_url)
        if self.service.list_vpc_routing_tables(self.vpc_id).get_result() is not None:
            list_tables = self.service.list_vpc_routing_tables(self.vpc_id).get_result()['routing_tables']
        update_done = False
        app.logger.info("Iterating through below Table Name and Table ID!!")
        for table in list_tables:
            if update_done:
                break
            app.logger.info("Name: " + table['name'] + "\tID: " +  table['id'])
            if (table['name'] != self.routing_table_name):
                continue
            table_id_temp = table['id']
            list_routes = self.service.list_vpc_routing_table_routes(vpc_id= self.vpc_id, routing_table_id=table_id_temp)
            routes = list_routes.get_result()['routes']
            for route in routes:
                route_id_temp = route['id']
                app.logger.info ("Route ID: " + route['id'])
                app.logger.info ("Next hop address of above Route ID: " + str(route['next_hop']))
                if route['next_hop']['address'] == self.ext_ip_1 or route['next_hop']['address'] == self.ext_ip_2:
                    self.find_the_current_and_next_hop_ip(route['next_hop']['address'], app)
                    app.logger.info("VPC routing table route found!!, ID: %s, Name: %s, zone: %s, Next_Hop:%s, Destination:%s " % (route['id'], route['name'], route['zone']['name'], route['next_hop']['address'], route['destination']))
                    zone_identity_model = {'name': route['zone']['name']}
                    route_next_hop_prototype_model = {'address': self.update_next_hop_vsi}
                    #Delete old route
                    self.service.delete_vpc_routing_table_route(vpc_id=self.vpc_id, routing_table_id=table_id_temp, id=route_id_temp)
                    app.logger.info("Deleted old route: " + route_id_temp)
                    #Create new route
                    create_vpc_routing_table_route_response = self.service.create_vpc_routing_table_route(vpc_id=self.vpc_id, routing_table_id=table_id_temp, destination=route['destination'], zone=zone_identity_model, action='deliver', next_hop=route_next_hop_prototype_model, name=route['name'])
                    route = create_vpc_routing_table_route_response.get_result()
                    app.logger.info("Created new route: " + route['id'])
                    update_done = True
        return update_done       
            
            
    def find_the_current_and_next_hop_ip(self, route_address, app):
        if route_address == self.ext_ip_1:
            #To be updated with IP address.
            self.update_next_hop_vsi = self.ext_ip_2
            #Current Hop IP address.
            self.next_hop_vsi = self.ext_ip_1
        else:
            #To be updated with IP address.
            self.update_next_hop_vsi = self.ext_ip_1
            #Current IP address.
            self.next_hop_vsi = self.ext_ip_2
        app.logger.info("Current next hop IP is: " + self.next_hop_vsi)
        app.logger.info("Update next hop IP to: " + self.update_next_hop_vsi)
                
def update_custom_route(remote_addr, app):
    haFailOver = HAFailOver(app)
    app.logger.info("Request received from: " + remote_addr)
    made_update = haFailOver.update_vpc_routing_table_route(app)
    app.logger.info('Updated routing table route!!')
    return "Updated Custom Route: " + str(made_update)