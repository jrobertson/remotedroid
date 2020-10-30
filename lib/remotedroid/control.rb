module RemoteDroid

  class Control        
    
    def initialize(dev=nil, deviceid: dev, remote_url: nil, debug: false)
      
      @deviceid, @remote_url, @debug = deviceid, remote_url, debug

    end    
    
    def airplane_mode()
      
      def self.enable()
        http_exec 'set-airplane-mode', {state: 0}
      end                
      
      def self.on()
        self.enable
      end                
      
      def self.disable()
        http_exec 'set-airplane-mode', {state: 1}
      end
      
      def self.off()
        self.disable
      end         
      
      def self.toggle()
        http_exec 'set-airplane-mode', {state: 2}
      end      
      
      self
    end    
    
    def ask_alexa(options={})
      http_exec 'ask-alexa', options
    end

    def autorotate()
      
      def self.enable()
        http_exec 'set-auto-rotate', {state: 0}
      end                
      
      def self.on()
        self.enable
      end                
      
      def self.disable()
        http_exec 'set-auto-rotate', {state: 1}
      end
      
      def self.off()
        self.disable
      end         
      
      def self.toggle()
        http_exec 'set-auto-rotate', {state: 2}
      end      
      
      self
    end    
    
    def bluetooth()
      
      def self.enable()
        http_exec 'set-bluetooth', {state: 0}
      end                
      
      def self.on()
        self.enable
      end                
      
      def self.disable()
        http_exec 'set-bluetooth', {state: 1}
      end
      
      def self.off()
        self.disable
      end         
      
      def self.toggle()
        http_exec 'set-bluetooth', {state: 2}
      end      
      
      self
    end
    
    def camera_flash_light(options={})
      http_exec 'camera-flash-light', options
    end
    
    def click(options={content: ''})
      http_exec 'click-text-content', options
    end
    
    def control_media(options={})      
      http_exec 'media-' + options[:option].downcase.gsub(/\W/,'-')
    end
    
    def disable_airplane_mode()
      http_exec 'set-airplane-mode', {state: 1}
    end
    
    def disable_bluetooth()
      http_exec 'set-bluetooth', {state: 1}
    end    
        
    def disable_macro(macro)
      http_exec 'disable-macro', {name: macro}
    end
    
    def disable_wifi()
      http_exec 'set-wifi', {state: 1}
    end        

    def enable_airplane_mode()
      http_exec 'set-airplane-mode', {state: 0}
    end
    
    def enable_bluetooth()
      http_exec 'set-bluetooth', {state: 0}
    end        
    
    def enable_macro(macro)
      http_exec 'enable-macro', {name: macro}
    end
    
    def enable_wifi()
      http_exec 'set-wifi', {state: 0}
    end    
    
    def fill_clipboard(options={})
      http_exec 'fill-clipboard', options
    end    
    
    def force_macro_run(options={})
      http_exec option[:macro_name].downcase.gsub(/ /,'-')
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
    
    def launch_activity(options={app: ''})
      
      return if options[:app].empty?
      
      app = options[:app]
      
      package = APPS[app]
      
      if package then
        launch_package package: package
      else       
        r = APPS.find {|k,v| k =~ /#{app}/i}
        launch_package(package: r[1]) if r
      end      
      
    end
    
    def launch_package(options={package: 'com.google.android.chrome'})
      http_exec 'launch-by-package', options
    end    
    
    def location(options={})
      http_exec 'location'
    end    
    
    def open_web_page(options={url: ''})
      http_exec 'open-web-page', options
    end
    
    alias open_website open_web_page
    alias goto open_web_page
    alias visit open_web_page
    
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
    
    def set_auto_rotate(state=nil)
      
      if state then
        http_exec 'set-auto-rotate', {state: state} 
      else        
        
        def self.on()
          http_exec 'set-auto-rotate', {state: 0}
        end
        
        def self.off()
          http_exec 'set-auto-rotate', {state: 1} 
        end
        
        def self.toggle()
          http_exec 'set-auto-rotate', {state: 2} 
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

    def take_screenshot(options={})
      http_exec 'take-screenshot', options
    end    
    
    def toast(options={})
      http_exec :toast, options
    end
    
    def torch(options={})
      http_exec :torch 
    end
    
    def vibrate(options={})
      http_exec :vibrate
    end    
        
    def voice_search(options={})
      http_exec 'voice-search'
    end    

    def wifi()
      
      def self.enable()
        http_exec 'set-wifi', {state: 0}
      end                
      
      def self.on()
        self.enable
      end                
      
      def self.disable()
        http_exec 'set-wifi', {state: 1}
      end
      
      def self.off()
        self.disable
      end         
      
      def self.toggle()
        http_exec 'set-wifi', {state: 2}
      end      
      
      self
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
