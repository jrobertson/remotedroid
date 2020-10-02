# Running a kind of MacroDroid macro remotely using the RemoteDroid gem

## Installation

`gem install remotedroid`

## Preparation

In order to run Macros remotely you will need to export the required RemoteDroid macros to MacroDroid. Here's how how to export the macros to the Android device (given it has an FTP server installed on port 2221):

    require 'remotedroid'

    rdc = RemoteDroid::Control.new(deviceid: '18ebcc0d-1c66-1d3e-bd7c-93bd75db3aec', 
           remote_url: 'http://sometargeturl.com/')

    rdc.export 'ftp://user:secret@phone.home:2221/Downloads/m0210.mdr'

## Services setup

In order to respond to a trigger, run a remote macro, and perform an action remotely, the following services should be running:

1. SimplePubSub broker
2. RemoteDroid::Server
3. TriggerSubscriber
4. ActionSubscriber


### RemoteDroid::Server

    require 'remotedroid'

    s ="
    m: popup test
    t: shake device
    a: message popup: hello world
    "

    ser = RemoteDroid::Server.new(s, drb_host: '127.0.0.1', deviceid: '48fbcc0d-4c66-4d3e-be7c-93bd75db3afb')
    ser.start

The above script runs as a DRb server running on port 5777. In this demo the macro included is triggered when the android device is shaken. Which will then display a popup message 'hello world'.

### TriggerSubscriber

    require 'remotedroid'

    ras = RemoteDroid::TriggerSubscriber.new(host: 'sps.home')
    ras.subscribe

The above script connects to the SimplePubSub broker on port 59000 and is used to retrieve new trigger messages (by subscribing to the topic *macrodroid/trigger*) to initiate 1 or more remote macros.

### ActionSubscriber

    require 'remotedroid'

    ras = RemoteDroid::ActionSubscriber.new(host: 'sps.home')
    ras.subscribe

The above script subscribes to the topic *macrodroid/action* to invoke the action on the Android device through an HTTP request to the webhook trigger.


## Testing the macro

To trigger the macro, the Android device was shaken, and the popup message *hello world* was observed.

## Resources

* remotedroid https://rubygems.org/gems/remotedroid

macrodroid simplepubsub webhook trigger action remote gem remotedroid sps
