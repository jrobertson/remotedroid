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
# ## Device Events
#
# * screen on
#
# ## Sensors
# 
# * proximity (near)
# * shake device
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

m: screen on off
t: screen on
a: webhook

EOF


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
        @remote.control.method(action.to_sym)\
            .call(JSON.parse(json, symbolize_names: true))
        
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
