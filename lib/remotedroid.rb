#!/usr/bin/env ruby

# file: remotedroid.rb

require 'onedrb'
require 'easydom'
require 'app-routes'
require 'sps-sub'
require 'ruby-macrodroid'

# PASTE_START

# Here's what's available so far:
# 
# # Triggers
#
# ## Battery/Power
#
# * Power button toggle
#
# ## Connectivity
#
# ### Wifi State Change
#
# * Connected to Network
#
# ## Device Events
#
# * screen on
#
# ## Sensors
#
# * Activity Recognition
# * proximity (near)
# * shake device
#
# ## User Input
#
# * Swipe Screen
#
# ------------------------------------
#
# # Actions
#
# ## Camera/Photo
#
# * Take Picture
# * Take Screenshot
#
# ## Connectivity
#
# * Enable HotSpot
#
# ## Date/Time
#
# * Say Current Time
#
# ## Device Actions
#
# * Speak text
# * Torch toggle
# * vibrate
#
# ## Location
#
# * Share Location
#
# ## MacroDroid specific
#
# * Enable/Disable Macro
#
# ## Media
#
# * Play sound (Doda)
#
# ## Notification
#
# * Popup Message
#
# ## Screen
#
# * Keep Device Awake
# * Screen On/Off
#

# Variables which can be queried
#
# Description                         Variable
# -------------------                 ----------------
# Foreground app name                 :fg_app_name
# Foreground app package              :fg_app_package
# Current Brightness                  :current_brightness
# Screen timeout (seconds)            :screen_timeout
# Current battery %                   :battery
# Battery temp °C                     :battery_temp
# Power (On/Off)                      :power
# Clipboard text                      :clipboard
# Current IP address                  :ip
# Wifi SSID                           :ssid
# Wifi signal strength                :wifi_strength
# System time                         :system_time
# IMEI                                :imei
# Cell Id                             :cell_id
# Last known location (lat,lon)       :last_loc_latlong
# Last known location (altitude)      :last_loc_alt
# Last known location (link)          :last_loc_link
# Last known location (time)          :last_loc_age_timestamp
# Last known location (kmh)           :last_loc_speed_kmh
# Last known location (mph)           :last_loc_speed_mph
# Current Volume (Alarm)              :vol_alarm
# Current Volume (Media / Music)      :vol_music
# Current Volume (Ringer)             :vol_ring
# Current Volume (Notification)       :vol_notif
# Current Volume (System Sounds)      :vol_system
# Current Volume (Voice Call)         :vol_call
# Current Volume (Bluetooth Voice)    :vol_bt_voice
# Device name                         :device_name
# Device uptime                       :uptime_secs
# Device manufacturer                 :device_manufacturer
# Device model                        :device_model
# Android version                     :android_version
# Android version (SDK Level)         :android_version_sdk
# Storage total (external)            :storage_external_total
# Storage free (external)             :storage_external_free
# Storage total (internal)            :storage_internal_total
# Storage free (internal)             :storage_internal_free


# The macros below are exported to JSON format as a file which is imported into
# the Android device running MacroDroid.

RD_MACROS =<<EOF
m: Camera flash light
t: webhook
a: Torch toggle

m: Torch
t: webhook
a: Torch toggle

m: Toast
v: msg: 
t: WebHook
a:
  Popup Message
    [lv=msg]

m: Say current time
t: webhook
a: Say Current Time

m: Speak text
v: text
t: webhook
a: speak text ([lv=text])

m: vibrate
t: webhook
a: vibrate

m: play doda
t: webhook
a: play: Doda

m: Screen
v: on: false
t: WebHook
a:
  If on = True
    Screen On
  Else
    Screen Off
  End If

m: Hotspot
v: enable: false
t: WebHook
a:
  If enable = True
    Enable Hotspot
  Else
    Disable Hotspot
  End If

m: Take Picture
t: webhook
a:
  Take Picture
    Rear Facing
a: wait 2 seconds
a: webhook

m: stay awake
t: webhook
a: stay awake

m: stay awake off
t: webhook
a: stay awake off

m: Media Next
t: webhook
a:
  Media Next
    Simulate Audio Button
    
m: Media Pause
t: webhook
a:
  Media Pause
    Simulate Audio Button
    
m: Media Play
t: webhook
a:
  Media Play
    Simulate Audio Button
    
m: Media Play Pause
t: webhook
a:
  Media Play/Pause
    Simulate Audio Button

m: Media Previous
t: webhook
a:
  Media Previous
    Simulate Audio Button
    
m: Media Stop
t: webhook
a:
  Media Stop
    Simulate Audio Button

m: Open web page
v: url
t: webhook
a: goto [lv=url]

m: Fill clipboard
v: clipboard
t: webhook
a:
  Fill Clipboard
    [lv=clipboard]

m: click text content
v: content
t: webhook
a:
  UI Interaction
    Click [[lv=content]]    
    
m: Launch by package
v: package
t: webhook
a: Launch [lv=package]
    
m: Take Screenshot
t: webhook
a:
  Take Screenshot
    Save to device
a: wait 2 seconds
a: webhook

m: Voice search
t: webhook
a: Voice search

m: Ask Alexa
t: webhook
a: shortcut Ask Alexa

m: Set Auto Rotate
v: state
t: webhook
a:
  if state = 0
    Auto Rotate On
  Else If state = 1
    Auto Rotate Off
  Else If state = 2
    Auto Rotate Toggle
  end if
  
m: Set Bluetooth
v: state
t: webhook
a:
  if state = 0
    Enable Bluetooth
  Else If state = 1
    Disable Bluetooth
  Else If state = 2
    Toggle Bluetooth
  Else If state = 3
    Connect Audio Device
  Else If state = 4
    Disconnect Audio Device
  end if

m: Set Airplane Mode
v: state
t: webhook
a:
  if state = 0
    Airplane Mode On
  Else If state = 1
    Airplane Mode Off
  Else If state = 2
    Airplane Mode Toggle
  end if 
  
m: Set Wifi
v: state
t: webhook
a:
  if state = 0
    Enable Wifi
  Else If state = 1
    Disable Wifi
  Else If state = 2
    Toggle Wifi
  Else If state = 3
    Connect to Network
  end if  


m: Share location
t: 
  WebHook
    identifier: location
a: Force Location Update    
a:
  Share Location
    coords
a:
  HTTP GET
    identifier: location
    coords: [lv=coords]
    cell: [cell_id]
    ssid: [ssid]
    alt: [last_loc_alt]
    time: [last_loc_age_timestamp]
    mph: [last_loc_speed_mph]
    kph: [last_loc_speed_kmh]
    device: [device_model]
    battery: [battery]
    type: query
    

m: query
t: WebHook
v: qvar
a:
  Set Variable
    var: [[lv=qvar]]
a:    
  HTTP GET
    [lv=qvar]: [lv=var]

m: query setting system
t: WebHook
v: qvar
a:
  Set Variable
    var: [setting_system=[lv=qvar]]
a:    
  HTTP GET
    [lv=qvar]: [lv=var]    
    
m: query setting global
t: WebHook
v: qvar
a:
  Set Variable
    var: [setting_global=[lv=qvar]]
a:    
  HTTP GET
    [lv=qvar]: [lv=var]    
    
m: query setting secure
t: WebHook
v: qvar
a:
  Set Variable
    var: [setting_secure=[lv=qvar]]
a:    
  HTTP GET
    [lv=qvar]: [lv=var]    
    
        
m: shake device
t: shake device
a: webhook

m: Proximity near
t: Proximity near
a:
  webhook
    identifier: proximity
    option: 0
    
m: Power connected
t: Power Connected: Any
a: webhook

m: Screen on
t: screen on
a:
  webhook
    identifier: screen_on_off
    screen_on: true

m: Power Button Toggle3
t: Power Button Toggle (3)
a:
  webhook
    identifier: power-button-toggle
    num_toggles: 3

m: Power Button Toggle4
t: Power Button Toggle (4)
a:
  webhook
    identifier: power-button-toggle
    num_toggles: 4

m: Power Button Toggle5
t: Power Button Toggle (5)
a:
  webhook
    identifier: power-button-toggle
    num_toggles: 5

m: Connected to network
t:
  Connected to network
    Any Network
a: wait 2 seconds    
a:
  webhook
    ssid: [ssid]

m: In Vehicle
t:
  Activity - In Vehicle
    Confidence >= 50%
a:
  webhook
    identifier: activity
    index: 0

m: On Bicycle
t:
  Activity - On Bicycle
    Confidence >= 50%
a:
  webhook
    identifier: activity
    index: 1
    
m: Running
t:
  Activity - Running
    Confidence >= 50%
a:
  webhook
    identifier: activity
    index: 2

m: Walking
t:
  Activity - Walking
    Confidence >= 50%
a:
  webhook
    identifier: activity
    index: 3

m: Still
t:
  Activity - Still
    Confidence >= 83%
a:
  webhook
    identifier: activity
    index: 4
    
m: Swipe top left across
t:
  Swipe Screen
    Top Left - Across
a:
  webhook
    identifier: swipe
    start: 0
    motion: 0

m: Swipe top left diagonal
t:
  Swipe Screen
    Top Left - Diagonal
a:
  webhook
    identifier: swipe
    start: 0
    motion: 1

m: Swipe top left down
t:
  Swipe Screen
    Top Left - Down
a:
  webhook
    identifier: swipe
    start: 0
    motion: 2

m: Swipe top right across
t:
  Swipe Screen
    Top Right - Across
a:
  webhook
    identifier: swipe
    start: 1
    motion: 0    
    

m: Swipe top right diagonal
t:
  Swipe Screen
    Top Right - Diagonal
a:
  webhook
    identifier: swipe
    start: 1
    motion: 1

m: Swipe top right down
t:
  Swipe Screen
    Top Right - Down
a:
  webhook
    identifier: swipe
    start: 1
    motion: 2

m: flip from up to down
t: Flip Device Face Up -> Face Down
a:
  webhook
    identifier: flip_device
    facedown: true

m: flip from down to up
t: Flip Device Face Down -> Face Up
a:
  webhook
    identifier: flip_device
    facedown: false    
EOF


module RemoteDroid
  
  class Server
    
    def initialize(s, drb_host: '127.0.0.1', devices: nil, debug: false)
      
      md = MacroDroid.new(s)
      rdc = RemoteDroid::Controller.new(md, devices: devices, debug: debug)
      @drb = OneDrb::Server.new host: drb_host, port: '5777', obj: rdc
      
    end
    
    def start
      @drb.start
    end

  end
    
  class TriggerSubscriber < SPSSub
    using ColouredText
    
    def initialize(host: 'sps.home', drb_host: '127.0.0.1')
      @remote = OneDrb::Client.new host: drb_host, port: '5777'    
      super(host: host)
      puts 'TriggerSubscriber'.highlight
    end
    
    def subscribe(topic: 'macrodroid/#/trigger')
      
      super(topic: topic) do |msg, topic|
        
        dev_id = topic.split('/')[1]
        trigger, json = msg.split(/:\s+/,2)
        
        a = @remote.trigger_fired trigger.to_sym, 
            JSON.parse(json, symbolize_names: true)
        
        a.each {|msg| self.notice "macrodroid/%s/action: %s" % [dev_id, msg] }
        
      end        
    end
    
  end
  
  class ActionSubscriber < SPSSub
    using ColouredText
    
    def initialize(host: 'sps.home', drb_host: '127.0.0.1')
      @remote = OneDrb::Client.new host: drb_host, port: '5777'    
      super(host: host)
      puts 'ActionSubscriber'.highlight
    end    
    
    def subscribe(topic: 'macrodroid/#/action')
      
      super(topic: topic) do |msg|
        
        context, json = msg.split(/:\s+/,2)
        category, action = context.split('/',2)
        
        h = JSON.parse(json, symbolize_names: true)
        
        if h[:serverside]then
          
          if action == 'force_macro_run' then
            
            a = @remote.run_macro(h)
            a.each {|msg| self.notice 'macrodroid/action: ' + msg }
            
          else
            
            puts 'action: ' + action.inspect
            puts 'h: ' + h.inspect
            r = @remote.local(action.to_sym, h)
            puts 'r: ' + r.inspect
            
          end

        else
          
          @remote.control.method(action.to_sym).call(h)
          
        end
        
      end
      
    end
    
  end
  
  class ResponseSubscriber < SPSSub
    using ColouredText
    
    def initialize(host: 'sps.home', drb_host: '127.0.0.1')
      @remote = OneDrb::Client.new host: drb_host, port: '5777'    
      super(host: host)
      puts 'ResponseSubscriber'.highlight
    end    
    
    def subscribe(topic: 'macrodroid/#/response')
      
      super(topic: topic) do |msg|
        
        #puts 'msg: ' + msg.inspect
        json, id = msg.split(/:\s+/,2).reverse
        
        h = JSON.parse(json, symbolize_names: true)
        id ||= h.keys.first
        #puts '->' + [id, h].inspect
        @remote.update id.to_sym, h
        
      end
      
    end
    
  end


  class Clients
    using ColouredText
    
    attr_reader :devices
    
    def initialize(hostx='127.0.0.1', host: hostx, port: '5777', 
                   sps_host: 'sps.home', sps_port: '59000')  
    
      @drb = OneDrb::Client.new host: host, port: port        
      #sleep 3
      @devices = @drb.devices.keys.inject({}) do |r, name|
        obj = RemoteDroid::Client.new(host: host, port: port, 
                          sps_host: sps_host, sps_port: sps_port, device: name)
        r.merge!(name => obj)
      end
      
    end

    def device(name)
      idx = @devices.index name.to_sym
      @devices[idx] if idx
    end
    
  end
end

# PASTE_END


require 'remotedroid/model'
require 'remotedroid/query'
require 'remotedroid/control'
require 'remotedroid/controller'
require 'remotedroid/client'
