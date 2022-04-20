+++
title = "Using Knative Eventing To Drive Carbon Black Cloud Workload Protection"
date = "2022-04-20"
author: RichMason
description = "Using Knative Eventing To Drive Carbon Black Cloud Workload Protection"
tags = [
    "knative",
    "kubernetes",
    "veba",
    "carbon black"
]
categories = [
    "automation"
]
thumbnail = "clarity-icons/code-144.svg"
+++

[VMware Carbon Black Cloud Workload](https://docs.vmware.com/en/VMware-Carbon-Black-Cloud-Workload/1.1/carbonblack_workload/GUID-38D28E17-CDDF-4E60-9164-7FDFD60938FB.html) provides an agentless experience that alleviates installation and management overhead. Once the VMware Carbon Black Cloud Workload Plug-in for vCenter Server is deployed and configured the virtual machine inventory is shown in Carbon Black Cloud. With this in place you can easily monitor and protect the data center workloads from the Carbon Black Cloud console. As well as offering the workload management capability through the console there is a fully featured [workload management API](https://developer.carbonblack.com/reference/carbon-black-cloud/workload-protection/).

The [VMware Event Router](https://github.com/vmware-samples/vcenter-event-broker-appliance/tree/master/vmware-event-router) can be used to connect to various VMware event providers (i.e. "sources") and forward these events to different event processors (i.e. "sinks"). Knative is a solution to build serverless and event driven applications and can act as an event processor. In this article we explore using Knative Eventing triggered by vCenter events to drive actions in Carbon Black Cloud.

## Example Use Case

You might want to control which Virtual Machines get enabled with specific sensors via console. There might be other occasions when you want to simply enable automatically. For the purpose of demonstration we'll look to trigger when a Virtual Machine is created and call the Carbon Black Cloud API to enable workload protection. Similarly when a Virtual Machine is deleted we can look to call the Carbon Black Cloud API to remove the stale inventory object.

## VMware Event Broker Appliance

The [VMware Event Broker Appliance (VEBA)](https://vmweventbroker.io/) is a very simple way to get started using the Knative eventing using the VMware Event Router. It is [shipped as fully functioning OVA via VMware Flings program](https://flings.vmware.com/vmware-event-broker-appliance). When deployed the OVA is passed parameters to configure its networking and form connections to vCenter Server and/or Horizon. Once the appliance is deployed and configured you are ready to deploy functions to meet your usecase.

## Knative Trigger Filter

The [Knative trigger](https://knative.dev/docs/eventing/broker/triggers/#trigger-filtering) resource can be configured with a filter so it only fires when a specific CloudEvent with a specific attribute is received by the Broker. This is also configured with an association to the Knative service resource. In this example we are configuring a trigger which filters for events from the VMware Event Router (com.vmware.event.router/event) and the CloudEvent subject matches string 'VMCreatedEvent' and calls service named kn-py-cb.

```yaml
apiVersion: eventing.knative.dev/v1
kind: Trigger
metadata:
  name: veba-py-cb-trigger
  labels:
    app: veba-ui
spec:
  broker: default
  filter:
    attributes:
      type: com.vmware.event.router/event
      subject: VmCreatedEvent
  subscriber:
    ref:
      apiVersion: serving.knative.dev/v1
      kind: Service
      name: kn-py-cb
```

## Kubernetes Service Resource

To add

## Knative Service Resource

When a [Knative service](https://github.com/knative/specs/blob/main/specs/serving/knative-api-specification-1.0.md#service) is called by a trigger it executes a container image. In this example we are configuring the service named kn-py-cb which is called by the trigger. We define relationship with a container image and a secret containing the environment variables.

```yaml
apiVersion: serving.knative.dev/v1
kind: Service
metadata:
  name: kn-py-cb
  labels:
    app: veba-ui
spec:
  template:
    metadata:
      annotations:
        autoscaling.knative.dev/maxScale: "1"
        autoscaling.knative.dev/minScale: "1"
    spec:
      containers:
        - image: ghcr.io/darrylcauldwell/kn-py-cb:1.0
          envFrom:
            - secretRef:
                name: kn-py-cb-secret
```

## Container Image

When Knative Eventing triggers an HTTP POST occurs with the CloudEvent as its payload. The container image therefore needs to run as a web service which performs action based on the contents of the event. In this case, make an authenticated POST to the Carbon Black Cloud API using credentials stored as Kubernetes secret and passed at execution time as environment variables. It then waits for the newly created VM to become visible. Wait for the VM guest OS to start and become eligible for enablement and finally initiate enablement.

```Python
from flask import Flask, request
from cloudevents.http import from_http
from cbc_sdk import CBCloudAPI
from cbc_sdk.workload.vm_workloads_search import ComputeResource
import logging,json,os,time
logging.basicConfig(level=logging.DEBUG,format='%(asctime)s %(levelname)s %(name)s %(threadName)s : %(message)s')

app = Flask(__name__)
@app.route("/", methods=["POST"])

def home():
    # Extract  VM Name From CloudEvent Data
    event = from_http(request.headers, request.get_data(),None)
    app.logger.debug(f"Full event contents {event}")
    data  = event.data
    app.logger.info(f"Found event ID {event['id']} triggered by {event['subject']} event for VM {data['Vm']['Name']}")

    #Output Carbon Black Cloud SDK Authentication Environment Variables
    app.logger.debug(f"Environment variable CBC_URL value is " + os.environ['CBC_URL'])
    app.logger.debug(f"Environment variable CBC_TOKEN value is " + os.environ['CBC_TOKEN'])
    app.logger.debug(f"Environment variable CBC_ORK_KEY value is " + os.environ['CBC_ORG_KEY'])
    #Output Sensor Version Environment Variable
    app.logger.debug(f"Environment variable SENSOR_VER value is " + os.environ['SENSOR_VER'])

    # Establish SDK session to workload API
    workloadApi = CBCloudAPI()
    app.logger.debug(f"Carbon Black Cloud API {workloadApi}")

    # Search CBC workload API for VM which event relates to
    vmName = str(data['Vm']['Name'])
    app.logger.debug(f"Virtual Machine name to search for is {vmName}")

    cbcComputeResourceQuery = workloadApi.select(ComputeResource).set_name([vmName])
    app.logger.debug(f"CBC compute resource query object is {cbcComputeResourceQuery}")

    # Get VM objectc from CBC instane, if not immediatly available wait and retry
    tries = 5
    while tries >=0:
        for vm in cbcComputeResourceQuery:
            vmId = vm.id
            app.logger.debug(f"CBC compute resource object ID is " + vmId)
            if vmId is None or tries == 0:
                app.logger.debug(f"Resource not found in CBS instance,  retrying")
                time.sleep(5)
                tries -= 1
            else:
                app.logger.debug(f"Found VM in CBS instance")
                tries = 0
    if vmId is None:
        app.logger.debug(f"VM not found in CBS instance")
        return "", 404    

    # Query VM objet sensor install eligibility status, if not immediatly eligible wait and retry
    tries = 5
    while tries >=0:
        if vm.eligibility == 'ELIGIBLE':
            app.logger.debug(f"VM is eligible for sensor installatioin")
            workloadApi.select(ComputeResource,vm.id).install_sensor(os.environ['SENSOR_VER'],config_file=os.environ['CBC_CONFIG_INI'])
            app.logger.debug(f"Attempting installation of sensors on VM")
            return "", 202
        else:
            app.logger.debug(f"VM not eligible for sensor installation,  retrying")
            time.sleep(30)
            tries -= 1

if __name__ == "__main__":
    app.run()
```
