module RemoteDroid

  class Client
    using ColouredText
    
    def initialize(hostx='127.0.0.1', host: hostx, port: '5777', sps_host: 'sps.home', sps_port: '59000')
      @drb = OneDrb::Client.new host: host, port: port    
      @sps = SPSPub.new host: sps_host, port: sps_port
    end
    
    def control
      @drb.control
    end
    
    def export(s)
      @drb.export(s)
    end
    
    def invoke(s, *args)
      @drb.invoke(s, *args)
    end
    
    def macros()
      @drb.macros
    end
    
    def query(id=nil)
      
      return @drb.query unless id
      t = Time.now
      h = @drb.query(id)
      h.merge({latency: (Time.now - t).round(3)})
      
    end
    
    def run_macro(name)
      a = @drb.run_macro name
      a.each {|msg| @sps.notice 'macrodroid/action: ' + msg }
    end
    
    def update(key, val)
      @drb.update key.to_sym, val
    end
    
    def store()
      @drb.store
    end
    
    def syslog()
      @drb.syslog
    end
    
    # -- helpful methods -----------------
    
    def ask_alexa()
      control.ask_alexa
    end
    
    def battery()
      query.battery
    end
    
    def cell_tower()
      query.cell_tower
    end
    
    def click(s)
      control.click content: s
    end
    
    def control_media(option='Play/Pause')
      control.control_media({option: option})
    end    
    
    def disable(macro)
      control.disable macro
    end
    
    def enable(macro)
      control.enable macro
    end    

    def fill_clipboard(text)
      control.fill_clipboard clipboard: text
    end
    
    alias copy fill_clipboard
    
    def hotspot(state=nil)      
      control.hotspot state
    end

    def launch_activity(app)
            
      package = APPS[app]
      
      if package then
        control.launch_package package: package
      else       
        r = APPS.find {|k,v| k =~ /#{app}/i}
        control.launch_package(package: r[1]) if r
      end        

    end
    
    def launch_package(name)
      
      control.launch_package(package: name)

    end    
    
    alias launch launch_activity
    
    def location()
      query.location
    end
    
    def location_watch(refresh: '1 minute', interval: refresh, 
                       duration: '30 minutes')
      
      d = ChronicDuration.parse(duration)
      seconds = ChronicDuration.parse(interval)
      puts ("monitoring location every %s for %s" % [interval, duration]).info

      Thread.new do      
        
        t = Time.now + d

        begin

          query.location
          sleep seconds

        end until Time.now >= t
        
      end
      
    end
    
    def open_website(url)
      control.open_website url: url
    end
    
    alias goto open_website
    alias visit open_website
    
    def ip()
      query.ip
    end

    def next()
      control_media('Next')
    end
    
    def pause()
      control_media('Pause')
    end    

    def play()
      control_media('Play')
    end    
    
    def play_pause()
      control_media('Play/Pause')
    end
    
    def photo()
      take_picture
    end
    
    def previous()
      control.control_media(option: 'Previous')
    end    
    
    def say(text)
      control.speak_text text
    end
    
    def say_time()
      control.say_time
    end
    
    alias saytime say_time
    
    def screen(state=nil)      
      control.screen state
    end
    
    def screen_on()
      screen :on
    end
    
    def screen_off()
      screen :off
    end
    
    def set_auto_rotate(state=nil)
      control.set_auto_rotate state
    end
    
    def set_auto_rotate_on()
      control.set_auto_rotate 0
    end    
    
    def set_auto_rotate_off()
      control.set_auto_rotate 1
    end
    
    def set_auto_rotate_toggle()
      control.set_auto_rotate 2
    end

    def stay_awake()
      control.stay_awake
    end
    
    def stay_awake_off()
      control.stay_awake_off
    end
    
    alias awake_off stay_awake_off
    
    def stop()
      control_media(option: 'Stop')
    end
    
    def take_picture(ftp_src: nil, fileout: '.')
      
      #screen.on
      #launch 'camera'
            
      if ftp_src then
        
        r = query.take_picture        
        # give the device a second to write the image to file
        sleep 1
        
        credentials, dir = ftp_src.match(/(ftp:\/\/[^\/]+)\/([^$]+)/).captures
        ftp = MyMediaFTP.new(credentials)
        ftp.cd dir
        filename = ftp.ls.sort_by {|x| x[:ctime]}.last[:name]
        ftp.cp filename, fileout
        
      else
        
        contro.take_picture
        
      end
      
    end   
    
    alias take_photo take_picture
    
    def take_screenshot(ftp_src: nil, fileout: '.')
      
      #screen.on
 
            
      if ftp_src then
         
        r = query.take_screenshot
        # give the device a second to write the image to file
        sleep 1
        
        credentials, dir = ftp_src.match(/(ftp:\/\/[^\/]+)\/([^$]+)/).captures
        ftp = MyMediaFTP.new(credentials)
        ftp.cd dir
        filename = ftp.ls.sort_by {|x| x[:ctime]}.last[:name]
        ftp.cp filename, fileout
        
      end
      
    end      
    
    def torch()
      control.torch
    end    
    
    def vibrate
      control.vibrate
    end
    
    def voice_search
      control.voice_search
    end    
    
    def volume(context=nil)      
      query.volume context
    end

    alias vol volume
      
  end
  
  
  class WebServer < AppHttp
    
    def initialize(port: 9292)
      super(RemoteDroid::Client.new, port: port)
    end
    
  end
  
end
