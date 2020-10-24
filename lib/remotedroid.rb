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
# * Disable Macro
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
# * Screen On
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

m: Launch Google Play Music
t: webhook
a: Launch Google Play Music


m: Media Next
t: webhook
a:
  Media Next
    Simulate Media Button (Google Play Music)
    
m: Media Pause
t: webhook
a:
  Media Pause
    Simulate Media Button (Google Play Music)
    
m: Media Play
t: webhook
a:
  Media Play
    Simulate Media Button (Google Play Music)
    
m: Media Play Pause
t: webhook
a:
  Media Play/Pause
    Simulate Media Button (Google Play Music)

m: Media Previous
t: webhook
a:
  Media Previous
    Simulate Media Button (Google Play Music)
    
m: Media Stop
t: webhook
a:
  Media Stop
    Simulate Media Button (Google Play Music)    

m: Open website
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
a: webhook

m: Power Button Toggle4
t: Power Button Toggle (4)
a: webhook

m: Power Button Toggle5
t: Power Button Toggle (5)
a: webhook

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
s='
    
m: click text content
v: content
t: webhook
a:
  UI Interaction
    Click [[[lv=content]]]
    '

module RemoteDroid
  
  class Server
    
    def initialize(s, drb_host: '127.0.0.1', deviceid: nil)
      
      md = MacroDroid.new(s)
      rdc = RemoteDroid::Controller.new(md, deviceid: deviceid)
      @drb = OneDrb::Server.new host: drb_host, port: '5777', obj: rdc
      
    end
    
    def start
      @drb.start
    end

  end
    
  class TriggerSubscriber < SPSSub
    
    def initialize(host: 'sps.home', drb_host: '127.0.0.1')
      @remote = OneDrb::Client.new host: drb_host, port: '5777'    
      super(host: host)
    end
    
    def subscribe(topic: 'macrodroid/trigger')
      
      super(topic: topic) do |msg|
        
        trigger, json = msg.split(/:\s+/,2)
        a = @remote.trigger_fired trigger.to_sym, 
            JSON.parse(json, symbolize_names: true)
        a.each {|msg| self.notice 'macrodroid/action: ' + msg }
        
      end        
    end
    
  end
  
  class ActionSubscriber < SPSSub
    
    def initialize(host: 'sps.home', drb_host: '127.0.0.1')
      @remote = OneDrb::Client.new host: drb_host, port: '5777'    
      super(host: host)
    end    
    
    def subscribe(topic: 'macrodroid/action')
      
      super(topic: topic) do |msg|
        
        context, json = msg.split(/:\s+/,2)
        category, action = context.split('/',2)
        
        h = JSON.parse(json, symbolize_names: true)
        
        if action == 'force_macro_run' and h[:serverside] then
          
          a = @remote.run_macro(h)
          a.each {|msg| self.notice 'macrodroid/action: ' + msg }

        else
          
          @remote.control.method(action.to_sym).call(h)
          
        end
        
      end
      
    end
    
  end
  
  class ResponseSubscriber < SPSSub
    
    def initialize(host: 'sps.home', drb_host: '127.0.0.1')
      @remote = OneDrb::Client.new host: drb_host, port: '5777'    
      super(host: host)
    end    
    
    def subscribe(topic: 'macrodroid/response')
      
      super(topic: topic) do |msg|
        
        json, id = msg.split(/:\s+/,2).reverse
        
        h = JSON.parse(json, symbolize_names: true)
        id ||= h.keys.first
        @remote.update id.to_sym, h
        
      end
      
    end
    
  end  
end

# PASTE_END


require 'remotedroid/model'
require 'remotedroid/query'
require 'remotedroid/control'
require 'remotedroid/controller'
require 'remotedroid/client'
