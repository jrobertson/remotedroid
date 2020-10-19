module RemoteDroid

  class Control        
    
    def initialize(dev=nil, deviceid: dev, remote_url: nil, debug: false)
      
      @deviceid, @remote_url, @debug = deviceid, remote_url, debug

    end    
    
    def bluetooth()
      @bluetooth
    end
    
    def camera_flash_light(options={})
      http_exec 'camera-flash-light', options
    end
    
    def disable(macro)
      http_exec 'disable-macro', {name: macro}
    end
    
    def enable(macro)
      http_exec 'enable-macro', {name: macro}
    end    
    
    def hotspot(state=nil)      
      
      if state then
        http_exec 'hotspot', {enable: state == :enable} 
      else        

        def self.enable()
          http_exec 'hotspot', {enable: true}
        end                
        
        def self.on()
          self.enable
        end                
        
        def self.disable()
          http_exec 'hotspot', {enable: false} 
        end
        
        def self.off()
          self.disable
        end         
        
        self
        
      end
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
    
    def location(options={})
      http_exec 'location'
    end    
    
    def say_current_time(options={})
      http_exec 'say-current-time'
    end    
    
    alias say_time say_current_time
    
    def screen(state=nil)      
      
      if state then
        http_exec 'screen', {on: state == :on} 
      else        
        
        def self.on()
          http_exec 'screen', {on: true}
        end
        
        def self.off()
          http_exec 'screen', {on: false} 
        end
        
        self
        
      end
    end
    
    def share_location(options={})
      http_exec 'share-location'
    end
    
    def speak_text(obj)
      
      options = case obj
      when String
        {text: obj}
      when Hash
        obj
      end
    
      http_exec 'speak-text', options
    end
    
    alias say speak_text
    
    def stay_awake(options={})
      http_exec 'stay-awake', options
    end

    def stay_awake_off(options={})
      http_exec 'stay-awake-off', options
    end
    
    def take_picture(options={})
      http_exec 'take-picture', options
    end
    
    alias take_photo take_picture

    
    def toast(options={})
      http_exec :toast, options
    end
    
    def torch(options={})
      http_exec :torch 
    end
    
    def vibrate(options={})
      http_exec :vibrate
    end    


    def write(s)
            
      d = MacroDroid.new(RD_MACROS, deviceid: @deviceid, 
                     remote_url: @remote_url, debug: false)
      
      a = d.macros.select do |macro|
        
        macro.triggers.find {|trigger| trigger.is_a? WebHookTrigger }.nil?
        
      end
      puts 'a: ' + a.length.inspect
      
      aux_macros = %w(Disable Enable).map do |state|
        
        rows = a[1..-1].map do |macro|
        
"  Else If name = #{macro.title}
    #{state} macro
      #{macro.title}"
        end

        "
m: #{state} macro
v: name
t: webhook
a:
  If name = #{a[0].title}
    #{state} macro
      #{a[0].title}
#{rows.join("\n")}
  End If
"     end

      puts aux_macros.join
      d.import aux_macros.join
      
      # disable the non-webhook triggers by default
      a.each(&:disable)
      
      d.export s
      puts 'exported to ' + s
      
    end
    
    alias export write
    
    def method_missing2(method_name, *args)
      http_exec(method_name, args.first)
    end    
    
  end
end
