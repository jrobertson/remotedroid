#!/usr/bin/env ruby

# file: remotedroid.rb

require 'onedrb'
require 'easydom'
require 'app-routes'
require 'sps-sub'
require 'ruby-macrodroid'


# Here's what's available so far:
# 
# # Triggers
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
# ## Date/Time
#
# * Say Current Time
#
# ## Device Actions
#
# * Speak text
# * Torch toggle
#
# ## Notification
# * Popup Message



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

m: shake device
t: shake device
a: webhook

m: Proximity near
t: Proximity near
a:
  webhook
    identifier: proximity
    option: 0

EOF

module RemoteDroid

  class Model
    include AppRoutes

    def initialize(obj=nil, root: 'device1', debug: false)

      super()
      @root, @debug = root, debug
      @location = nil
      
      if obj then
        
        s = obj.strip
        
        puts 's: ' + s.inspect if @debug
        
        if s[0] == '<' or s.lines[1][0..1] == '  ' then
          
          puts 'before easydom' if @debug
          
          s2 = if s.lines[1][0..1] == '  ' then
          
            lines = s.lines.map do |line|
              line.sub(/(\w+) +is +(\w+)$/) {|x| "#{$1} {switch: #{$2}}" }
            end
            
            lines.join
            
          else
            s
          end
          
          @ed = EasyDom.new(s2)
        else
          build(s, root: root) 
        end

      end

    end

    def build(raw_requests, root: @root)

      @ed = EasyDom.new(debug: false, root: root)
      raw_requests.lines.each {|line| request(line) }

    end
    
    
    def get_thing(h)
      
      h[:thing].gsub!(/ /,'_')
      
      if not h.has_key? :location then
        location = false
        h[:location] = find_path(h[:thing]) 
      else
        location = true
      end
      
      puts 'h: ' + h.inspect if @debug
      
      a = []
      a += h[:location].split(/ /)
      a << h[:thing]
      status = a.inject(@ed) {|r,x| r.send(x)}.send(h[:action])
      
      if location then
        "The %s %s is %s." % [h[:location], h[:thing], status]
      else
        "%s is %s." % [h[:thing].capitalize, status]
      end
      
    end          

    # Object Property (op)
    # Helpful for accessing properites in dot notation 
    # e.g. op.livingroom.light.switch = 'off'
    #
    def op()
      @ed
    end

    def query(s)
      @ed.e.element(s)
    end
    
    # request accepts a string in plain english 
    # e.g. request 'switch the livingroom light on'
    #
    def request(s)

      params = {request: s}
      requests(params)
      h = find_request(s)

      method(h.first[-1]).call(h).gsub(/_/,' ')
      
    end      
    
    def set_thing(h)

      h[:thing].gsub!(/ /,'_')
      h[:location] = find_path(h[:thing]) unless h.has_key? :location
      
      a = []
      a += h[:location].split(/ /)
      a << h[:thing]
      
      a.inject(@ed) {|r,x| r.send(x)}.send(h[:action], h[:value])
      
    end       

    def to_sliml(level: 0)
      
      s = @ed.to_sliml

      return s if level.to_i > 0
      
      lines = s.lines.map do |line|
        
        line.sub(/\{[^\}]+\}/) do |x|
          
          a = x.scan(/\w+: +[^ ]+/)
          if a.length == 1 and x[/switch:/] then

            val = x[/(?<=switch: ) *["']([^"']+)/,1]
            'is ' + val
          else
            x
          end

        end
      end
      
      lines.join
      
    end

    def to_xml(options=nil)
      @ed.xml(pretty: true).gsub(' style=\'\'','')
    end
    
    alias xml to_xml
    
    # to_xml() is the preferred method

    protected      

    def requests(params) 

      # e.g. switch the livingroom gas_fire off
      #
      get /(?:switch|turn) the ([^ ]+) +([^ ]+) +(on|off)$/ do |location, device, onoff|
        {type: :set_thing, action: 'switch=', location: location, thing: device, value: onoff}
      end
      
      # e.g. switch the gas _fire off
      #
      get /(?:switch|turn) the ([^ ]+) +(on|off)$/ do |device, onoff|
        {type: :set_thing, action: 'switch=', thing: device, value: onoff}
      end            
      
      # e.g. is the livingroom gas_fire on?
      #
      get /is the ([^ ]+) +([^ ]+) +(?:on|off)\??$/ do |location, device|
        {type: :get_thing, action: 'switch', location: location, thing: device}
      end
      
      # e.g. enable airplane mode
      #
      get /((?:dis|en)able) ([^$]+)$/ do |state, service|
        {type: :set_thing, action: 'switch=', thing: service, value: state + 'd'}
      end
      
      # e.g. switch airplane mode off
      #
      get /switch (.*) (on|off)/ do |service, rawstate|        
        
        state = rawstate == 'on' ? 'enabled' : 'disabled'
        {type: :set_thing, action: 'switch=', thing: service, value: state}
        
      end               
      
      # e.g. is airplane mode enabed?
      #
      get /is (.*) +(?:(?:dis|en)abled)\??$/ do |service|
        {type: :get_thing, action: 'switch', thing: service.gsub(/ /,'_')}
      end      

      # e.g. is the gas_fire on?
      #
      get /is the ([^ ]+) +(?:on|off)\??$/ do |device|
        location = find_path(device)        
        {type: :get_thing, action: 'switch', location: location, thing: device}
      end            
      
      # e.g. fetch the livingroom temperature reading
      #
      get /fetch the ([^ ]+) +([^ ]+) +(?:reading)$/ do |location, device|
        {type: :get_thing, action: 'reading', location: location, thing: device}
      end

      # e.g. fetch the temperature reading
      #
      get /fetch the ([^ ]+) +(?:reading)$/ do |device|
        location = find_path(device)        
        {type: :get_thing, action: 'reading', location: location, thing: device}
      end          

    end
    
    private
    
    def find_path(s)
      puts 'find_path s: ' + s.inspect if @debug
      found = query('//'+ s)
      return unless found
      a = found.backtrack.to_xpath.split('/')
      a[1..-2].join(' ')            
    end
        
    alias find_request run_route    

  end

  class Controller
    
    attr_reader :model, :control
    attr_accessor :title, :macros

    def initialize(mcs, model=MODEL, deviceid: nil, debug: false)
      
      @debug = debug
      @syslog = []
            
      @control = Control.new(deviceid)
      @macros = mcs.macros
      
      if model then
        @model = Model.new(model)
      end

    end
    
    def export(s)
      @macros = MacroDroid.new(s).macros
    end
    
    def invoke(name, options={})      
      @control.method(name.to_sym).call(options)
    end

    # Object Property (op)
    # Helpful for accessing properites in dot notation 
    # e.g. op.livingroom.light.switch = 'off'
    #    
    def op()
      @model.op
    end
    
    def request(s)
      @model.request s
    end
    
    
    def trigger(name, detail={time: Time.now})
      
      macros = @macros.select do |macro|
        
        puts 'macro: '  + macro.inspect if @debug

        # fetch the associated properties from the model if possible and 
        # merge them into the detail.
        #
        valid_trigger = macro.match?(name, detail, @model.op)
        
        puts 'valid_trigger: ' + valid_trigger.inspect if @debug
        
        if valid_trigger then
          @syslog << [Time.now, :trigger, name] 
          @syslog << [Time.now, :macro, macro.title]
        end
                     
        valid_trigger
        
      end
      
      puts 'macros: ' + macros.inspect if @debug
      
      macros.flat_map(&:run)
    end
    
    alias trigger_fired trigger

  end

  class Service
    def initialize(callback)
      @callback = callback
    end
  end
  
  class Bluetooth
    def enable()
    end
  end
  
  class Toast < Service
        
    def invoke()
      @callback.call :toast
    end
    
  end  
  
  class Torch < Service
        
    def toggle()
      @callback.http_exec :torch      
    end
    
  end

  class Control        
    
    def initialize(dev=nil, deviceid: dev, remote_url: nil, debug: false)
      
      @deviceid, @remote_url, @debug = deviceid, remote_url, debug
      @torch = Torch.new(self)
    end
    
    def bluetooth()
      @bluetooth
    end
    
    def camera_flash_light(options={})
      http_exec 'camera-flash-light', options
    end
        
    def http_exec(command, options={})
      
      url = "https://trigger.macrodroid.com/%s/%s" % [@deviceid, command]
      
      if options and options.any? then
        h = options
        url += '?' + \
            URI.escape(h.map {|key,value| "%s=%s" % [key, value]}.join('&'))
      end
      
      s = open(url).read
      
    end
    
    def say_current_time(options={})
      http_exec 'say-current-time'
    end    
    
    alias say_time say_current_time
    
    def speak_text(options={})
      http_exec 'speak-text', options
    end
    
    def toast(options={})
      http_exec :toast, options
    end
    
    def torch(options={})
      http_exec :torch 
    end

    def write(s)
            
      MacroDroid.new(RD_MACROS, deviceid: @deviceid, 
                     remote_url: @remote_url, debug: @debug).export s
      
    end
    
    alias export write
    
    def method_missing(method_name, *args)
      http_exec(method_name, args.first)
    end    
    
  end
  
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
  
  
end
