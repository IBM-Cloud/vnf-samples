## Configuring f5 Big-IP VE (HA within same zone)

In cloud.ibm.com, create 2 VSIs with 1 primary NIC and 3 secondary NICs. Note that the VSIs are created with primary and secondary subnets in the same range as shown below.

#### VPC: f5-test-vpc-same-zone
#### f5-same-zone-1 (150.239.87.172):
- f5-01-mgmt-sub (10.241.1.4) management ip address
- f5-01-int-sub (10.241.2.4) internal ip address
- f5-01-ext-sub (10.241.3.4) external ip address
- f5-01-ha-sub (10.241.0.4) ha ip address
#### f5-same-zone-2 (52.116.127.246):
- f5-01-mgmt-sub (10.241.1.6) management ip address
- f5-01-int-sub (10.241.2.6) internal ip address
- f5-01-ext-sub (10.241.3.5) external ip address
- f5-01-ha-sub (10.241.0.6) ha ip address

1.	Activating the device license: For _f5-same-zone-1_, Login to https://150.239.87.172/ using admin id and password that you gave during VSI setup and activate the licenses for your VSI either using the manual or automatic method. On the left panel, select _Licensing > License_. Click on _Activate_. Following page will open.

    ![activate_license](../images/ha-config/activate_license_1.png)

    1.	If you choose _Automatic_ activation method, paste the license key in _Base Registration Key_ field and click on _Next_.

    2.	For _Manual_ activation method, paste the license key in _Base Registration Key_ field and click on next, copy the dossier from _Step 1: Dossier_ and click on the link given in _Step 2: Licensing Server_ to access F5 licensing server, paste your copied dossier in the text area and click on _Next_.

    ![activate_license](../images/ha-config/activate_license_2.png)

    ![activate_license](../images/ha-config/activate_license_3.png)
    
    Copy the generated key and paste it in _Step 3: License_. Click _Next_. You will be required to login again if your license has been activated successfully. Check your license otherwise. Do the same for _f5-same-zone-02_ VSI.

    ![activate_license](../images/ha-config/activate_license_4.png)

2.	Check VLAN configuration: Go to _Network-> VLANs_. VLANs should get auto configured when activating the license, just verify whether the configuration has been setup correctly. Check the same for _f5-same-zone-02_ VSI.

![vlan_config](../images/ha-config/vlan_config.png)

3.	Check Self IPs configuration: Go to _Network-> Self IPs_. Self IPs should get auto configured when activating the license, just verify whether the configuration has been setup correctly. Check the same for _f5-same-zone-02_ VSI.

![selfip_config](../images/ha-config/selfip_config.png)

4.	Now, let’s do HA configuration.

    1. Change device name(optional): For VSI 1, Under _Device Management –> Devices -> Properties_, select _Change the device name_ and provide _bigipA.f5.com_ and click _Update_. Similarly, for VSI 2, change the device name to _bigipB.f5.com_ and click _Update_.

    ![change_device_name](../images/ha-config/change_device_name.png)

    2. Change config sync: For VSI 1, Under _Device Management –> Devices –> ConfigSync_, select HA IP Address as Local Address. Click _Update_.

    ![change_config_sync](../images/ha-config/change_config_sync.png)

    3. Change Network Failover: For VSI 1, Under _Device Management –> Devices –> Network Failover_, add HA IP address, click _Repeat_ to add Management IP address (private IP and not the floating IP) and then click on _Finished_. Finally, click on _Update_.

    ![change_network_failover](../images/ha-config/change_network_failover.png)

    4. Mirroring: For VSI 1, Under _Device Management –> Devices –>Mirroring_. Select,
        - Primary Local Mirror Address => HA IP Address
        - Secondary Local Mirror Address => Internal IP Address
    Click on Update. Repeat steps 2 to 4 for _f5-same-zone-02_ VSI.

    ![change_mirroring_config](../images/ha-config/change_mirroring_config.png)

    5. Now, let’s peer the VSIs. Add both VSIs in a device group. Go to VSI1, _Device Management –> Device Trust –> Device Trust Members -> Add_. Select _Device Type_ as _Peer_ and give the management IP address (private IP) of VSI 2 in the Device IP Address field. Provide the _Administrator Username_ and _Administrator Password_ of VSI 2 (admin/xxxx) and click on _Retrieve Device Information_ and then on _Device Certificate Matches_. Now you can see that the host _f5-same-zone-02_ is automatically retrieved and is updated in the _Add Device Name_ field. Replace the name with _bigipB.f5.com_ and click on _Add Device_. 

        ![add_peer](../images/ha-config/add_peer.png)
        
        Go to _Device Management -> Devices -> Device List_ to verify that both the Big IP devices are visible. You can find the same in VSI 2 as well as they belong to the same device trust.

        ![peered_devices](../images/ha-config/peered_devices.png)
        
        Let’s add device subgroup. In VSI 1, Go to _Device Management –> Device Groups –> Create_. Select group type as _Sync-Failover_. Name it as _f5-same-zone-device-group_, and include the 2 members: _bigipA.f5.com_, _bigipA.f5.com_. Select Sync Type as _Automatic with Incremental Sync_. Click _Finished_. 

        ![device_group](../images/ha-config/device_group.png)
        
        Now, your HA configuration is done. You can see that VSI 1 is in Active status and VSI 2 is in Standby status.

    6.	Now, let’s test the failover sync. In VSI 1, go to _Device Management –> Traffic Groups –> traffic-group-1_ and click _Force to Standby_. You can see that VSI 1 is in Standby status and VSI 2 is in Active status. Thus, we have created a cluster of 2 f5 VSIs with high availability.








