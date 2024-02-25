
### Steps to setup F5 VNF

### Standalone Setup

[Standalone setup](https://github.com/IBM-Cloud/vnf-samples/blob/master/f5-vnf-ha-failover/Standalone_steps.md)


### Cluster Setup 

[Cluster setup](https://github.com/IBM-Cloud/vnf-samples/blob/master/f5-vnf-ha-failover/same-zone-ha-setup.md)

### Failover HA Application

[Setup failover HA Application](https://github.com/IBM-Cloud/vnf-samples/tree/master/f5-vnf-ha-failover/failover-script-using-code-engine)

### VNF Integration with IBM Event Notification 

In the context of a failover script, the incorporation of IBM Cloud Event Notifications with the Custom Email Destination feature provides a valuable tool for improving the response to issues in a VNF (Virtual Network Function).
Here's how it can work:
When a VNF goes down or encounters an issue, the failover script can be configured to trigger an automatic notification. This notification can be sent as an email to the designated admin or operator responsible for managing the VNF.
The operator, upon receiving the email notification, can promptly investigate the issue with the VNF that went down. With timely information at their fingertips, they can take the necessary steps to bring the VNF up and resolve the issue efficiently.
By using the Custom Email Destination feature in IBM Cloud Event Notifications, businesses can extend the capabilities of their failover scripts and enhance their incident response procedures. This approach aligns with the broader theme of leveraging technology to optimize operations and improve customer satisfaction, as discussed in the previous example.
Example request for sending notifications:

```
curl -X POST — location — header "Authorization: Bearer {iam_token}" — header "Content-Type: application/json" "{base_url}/v1/instances/{instance_id}/notifications"
```

Example JSON body for sending notifications to various destinations:

```
{
    "id": "b2198eb8-04b1-48ec-a78c-ee87694dd845",
    "time": "06/06/2022, 14:23:01",
    "type": "com.ibm.cloud.sysdig-monitor.alert:downtime",
    "message_text": "Hi, Welcome from the IBM Cloud - Event Notifications service!",
    "source": "apisource/git",
    "specversion": "1.0",
    "ibmensourceid": "d6f08a53-05f6-465f-903e-03db3fa91b64:api",
    "data": {
      "greet": "Afternoon",
     "create_time": "2022-07-06T09:19:45.213429645Z",
     "create_timestamp": 1657099185,
     "issuer": "IBM Cloud VNC",
     "issuer_url": "https://cloud.ibm.com/vnc,
     "long_description": "Success! Your Event Notifications instance is configured with IBM Cloud VNC",
     "payload_type": "test",
     "reported_by": {
       "id": "compliance",
       "title": "IBM Cloud VNC",
       "url": "https://cloud.ibm.com/vnc"
     },
     "severity": "LOW",
     "short_description": "Success! Your Event Notifications instance is configured with IBM Cloud VNC.",
     "transaction_id": "e539778e-4915-4586-b4c9-48e44af5c010",
     "name": "IBM Cloud Event Notifications",
     "price": "100",
     "rating": "4.9"
    },
    "datacontenttype": "application/json",
    "ibmendefaultlong": "This is a original long message",
    "ibmendefaultshort": "IBM Cloud Event Notifications is a routing service that provides information about critical events in your IBM Cloud account",
    "ibmenfcmbody": "{\"notification\":{\"title\":\"Hello Pradeep, Your Order summary - Hot Chilli Manchurian ($20) and French Fries ($11) is on its way!\",\"time_to_live\":100}}",
    "ibmenpushto": "{\"platforms\":[\"push_chrome\"]}",
    "ibmenmailto": "[\"pgopalgo@in.ibm.com\"]",
    "personalization": {
      "pgopalgo@in.ibm.com": {
        "name": "Pradeep"
      }
    }
}

```

In summary, integrating IBM Cloud Event Notifications with Custom Email Destination in failover scripts enhances operational efficiency and allows for a swift response to VNF issues, minimizes downtime and potential disruptions to services, ultimately benefiting both the business and its customers by ensuring uninterrupted services. It empowers operators with real-time alerts, enabling them to take proactive measures to maintain the stability and reliability of the network. Furthermore, customers have the flexibility to choose from a range of notification options, including PD (PagerDuty), SMS, Slack, and more, in addition to the custom email notifications, ensuring they receive alerts in the manner that best suits their needs and preferences.
For more detailed information on implementing such notifications and utilizing IBM Cloud Event Notifications for VNF integration, you can refer to the provided documentation and example request: https://cloud.ibm.com/docs/event-notifications
