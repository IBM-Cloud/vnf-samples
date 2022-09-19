import os
import requests
import threading
import time
from datetime import timedelta, datetime
import sys

_token_lock = threading.Lock()
# {apikey: {'token': 'xxx', 'update_at': 'xxx'}}
_tokens = {}

BASE_URL = "https://us-south.iaas.cloud.ibm.com/v1/"
URL_PARAMS= "?version=2022-08-02&generation=2"

def request(auth_token, method, url, headers=None,
                             data=None, params=None, timeout=60, max_retries=1):
    '''
         This function is used as api client.
         INPUT:
             - HTTP request method, including GET, POST, PUT, PATCH, DELETE
             - url is api endpoint include base endpoint
             - iam_token is a token with ibm cloud
             - headers request headers is Dict formate
             - data request body, Must be string
             - params query string
             - timeout connection timeout
         OUTPUT:
             response from cf
    '''

    if "Bearer " not in auth_token:
        auth_token = "Bearer " + auth_token
    my_headers = {
        "Content-Type": "application/json",
        "Authorization": auth_token
    }

    if headers:
        for key in headers.keys():
            my_headers[key] = headers[key]

     
    try:
        ##print("url is %s and method is %s" % (url, method))
        if data is not None:
            print("data is %s" % (data))
        resp = _excute_with_valid_token(method,
                                        url,
                                        my_headers,
                                        data,
                                        params,
                                        timeout)
        ##print(
        ##    "resp of %s %s status is %d" %
        ##    (method, url, resp.status_code))
        try:
            if resp.status_code not in [
                200, 201, 202]:
                print(
                    "resp json of {0} {1} is {2} .".format(
                        method, url, resp.text))
        except Exception as e:
            print("exception when read response")
            print(resp.text)
     
    except Exception as e:
        print("Exception occurred %s" % (e))
        resp.json.return_value = {'message': 'Severe internal error'}
        resp.status_code = 410

    return resp   
        
def _excute_with_valid_token(method,
                             url,
                             my_headers,
                             data,
                             params,
                             timeout):
    max_retries = 10
    
    func = getattr(requests, method.lower())

    resp = None
    for retries in range(max_retries + 1):
        try:
            resp = func(url, headers=my_headers, data=data,
                        params=params, timeout=timeout)
            if resp.status_code not in [200, 201, 202, 400, 404, 406, 409]:
                print("{} {} got code {} resp body {}".format(
                    method, url, resp.status_code, resp.text))
            if resp.status_code in [401]:
                time.sleep(10)
                print("token expired for operation {} {}".format(method, url))
                auth_token = get_auth_token()
                if "Bearer " not in auth_token:
                    auth_token = "Bearer " + auth_token
                my_headers["Authorization"] = auth_token
                my_headers["Content-Type"] = "application/json"
                continue
        except requests.exceptions.Timeout:
            print("{} {} request timeout".format(method, url))
            time.sleep(10)
            print("retry on timeout {} {} {}".format(retries, method, url))
            continue
        except requests.exceptions.RequestException as e:
            print("{} {} got exception {}".format(method, url, e))
            time.sleep(10)
            print("retry on exception {} {} {}".format(retries, method, url))
            continue
        return resp

    return resp        


def get_iam_token(url, apiKey, force_iam=False):
    ##print("waiting token lock")
    with _token_lock:
        if _tokens.get(apiKey, None) and (not force_iam):
            if _tokens.get(apiKey).get('update_at', None):
                update_at = _tokens.get(apiKey).get('update_at')
                t = datetime.now()
                if t - update_at < timedelta(minutes=30):
                    if _tokens.get(apiKey).get('token', None):
                        return _tokens.get(apiKey).get('token')
        access_token = get_iam_token2(url, apiKey)
        _tokens[apiKey] = {"token": access_token, "update_at": datetime.now()}
        return access_token


def get_iam_token2(url, apiKey):
    headers = {
        'Content-Type': 'application/x-www-form-urlencoded',
        'Accept': 'application/json'
    }
    data = {
        'grant_type': 'urn:ibm:params:oauth:grant-type:apikey',
        'response_type': 'cloud_iam',
        'apikey': apiKey
    }
    ##print("get token from IAM")
    for retry in range(10):
        try:
            resp = requests.post(url, auth=('bx', 'bx'), headers=headers, data=data)
            if resp.status_code in [500, 503, 504, 524, 400, 429]:  # 429 for rate limit
                print(
                    "get IAM token timeout or reach rate limit code {}, retry {}".format(resp.status_code, retry))
                time.sleep(10)
                continue
            if resp.status_code == 200:
                return resp.json()["access_token"]
        except Exception as e:
            print("get IAM token got exception {} retry {}".format(e, retry))
            time.sleep(10)
            continue
        error_msg = "get IAM get token get invalid code {} resp body {}".format(resp.status_code, resp.text)
        print(error_msg)
        raise Exception(error_msg)

def get_auth_token():
    iam_url = "https://iam.cloud.ibm.com/identity/token"
    api_key = os.getenv("RIAS_API_KEY")
    auth_token = get_iam_token(iam_url, api_key)
    return auth_token


def get_lb_subnet_names(subnet_id_list, auth_token):
    lb_sub_name =[]
    for subnet in subnet_id_list:
        subnet_ep = BASE_URL+"subnets/"+subnet['id']+URL_PARAMS
        sub_resp = request(auth_token,
            "GET", subnet_ep, headers=None)
        #print(sub_resp.json()['name'])
        lb_sub_name.append(sub_resp.json()['name'])
    return lb_sub_name
    
    
def  get_lb_details(auth_token, lb_domain):
    endpoint = BASE_URL+"load_balancers"+URL_PARAMS
    resp = request(auth_token,
        "GET", endpoint, headers=None)
    #print("Response of LIST LB {0}".format(resp))
    result = resp.json()['load_balancers']
    for lb in result:
        #id = lb['id']
        #name = lb['name']
        #is_public = lb['is_public']
        #print(id, name, is_public)
        if lb['hostname'] == lb_domain:
            return lb['id']
    return None
       
    
def get_subnet_details_priv_lb(private_lb_id, auth_token):
    endpoint = BASE_URL+"load_balancers/"+private_lb_id+URL_PARAMS
    resp = request(auth_token,
            "GET", endpoint, headers=None)

    #print("Response of GET LB is {0}".format(resp))
    result = resp.json()['subnets']
    #print("Result is {0}".format(result))
    return result

def create_tf_var_file(lb_sub_names):
    file1 = open('terraform.tfvars', 'w')
    file1.write("client_vpn_gateway_subnet=\"subnet-demo-think-peer-1\"\n")
    file1.write("server_vpn_gateway_subnet1=\""+lb_sub_names[0]+"\"\n")
    file1.write("server_vpn_gateway_subnet2=\""+lb_sub_names[1]+"\"\n")
    file1.write("region=\"us-south\"\n")
    file1.write("generation=2\n")
    file1.close()
    print("terraform.tfvars created\n")
    
    
lb_domain = sys.argv[1]
print("Hostname of LB is {0}\n".format(lb_domain))
auth_token = get_auth_token()
lb_id = get_lb_details(auth_token, lb_domain)

if lb_id is not None:
    print("LB Id is: {0}\n\n".format(lb_id))
    lb_sub = get_subnet_details_priv_lb(lb_id, auth_token)
    #print("subnet ids are:")
    #for subnet in lb_sub:
    #    print(subnet['id'])
    
    lb_sub_names = get_lb_subnet_names(lb_sub, auth_token) 
    print("subnet names are:")
    print(lb_sub_names)
    print("\n")
    create_tf_var_file(lb_sub_names)
else:
    print("No LB, hence ending!!")