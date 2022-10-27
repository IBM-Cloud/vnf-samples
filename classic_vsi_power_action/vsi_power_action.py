import SoftLayer
import os


def main():
    vsi_ids = []
    api_key = os.environ['API_KEY']
    user_name = os.environ['USER_NAME']
    power_action = os.environ['POWER_ACTION']

    for vsi in range(1, 100):
        try:
            vsi_ids.append(os.environ['VSI_' + str(vsi)])
        except:
            break
    print('vsi ids: {}'.format(vsi_ids))

    """
    # Your softlayer API username and key.
    # Generate an API key at the softlayer Customer Portal:
    # control.softlayer.com
    """
    # Declare a new API service object
    client = SoftLayer.Client(username=user_name, api_key=api_key)

    for vsi_id in vsi_ids:
        print()
        print('------------------')
        print("Powering {} VSI ID: {}".format(power_action, vsi_id))
        try:
            if power_action == "off":
                # Power off the virtual guest
                response = client['SoftLayer_Virtual_Guest'].powerOff(
                    id=vsi_id)
                if response == True:
                    print("VSI {} powered off".format(vsi_id))
                else:
                    print('Failed to power off vsi {}'.format(vsi_id))
            elif power_action == "on":
                # Power on the virtual guest
                response = client['SoftLayer_Virtual_Guest'].powerOn(
                    id=vsi_id)
                if response == True:
                    print("vsi {} powered on.".format(vsi_id))
                else:
                    print('Failed to power on vsi {}'.format(vsi_id))
        except SoftLayer.SoftLayerAPIError as e:
            print("Unable to power on/off the virtual guest. code: {}, response: {}".format(
                e.faultCode, e.faultString))
            if e.faultCode == 'SoftLayer_Exception_Virtual_Guest_AlreadyHalted':
                continue
    return {"Status": "OK"}


if __name__ == "__main__":
    main()
