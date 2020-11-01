module RemoteDroid
  
  class Controller
    
    attr_reader :model, :syslog, :devices
    attr_accessor :title, :macros, :store

    def initialize(mcs, model=MODEL, devices: {}, debug: false)
      
      @debug = debug
      @syslog = []
       
      @devices = devices
      
      @devices.each do |key, deviceid|
        devices[key] = Control.new(deviceid)
      end
      
      @macros = mcs.macros
      
      if model then
        @model = Model.new(model)
      end
      
      @store = {}
      #@query = Query.new(self)
      
      # enable the required triggers on the Android device
      #
      names = @macros.map {|x| x.triggers.first.type}.uniq
      #@control.enable names.first.to_s.gsub('_',' ')
      puts 'Enabling ' + names.join(',')
=begin      
      Thread.new do
        names.each do |title|
          @control.enable title.to_s.gsub('_',' ')
          sleep 0.8
        end
      end
=end
    end
    
    def control(device)
      @devices[device]
    end
    
    def delete_all()
      @macros = []
    end
    
    def export(s, replace: false)
      
      macros = MacroDroid.new(s).macros
      replace ? @macros = macros : @macros.concat(macros)
      
    end
    
    def invoke(device, name, options={})      
      
      if control(device).respond_to? name.to_sym then
        control(device).method(name.to_sym).call(options)
      else
        control(device).http_exec name.to_sym, options
      end
    end
    
    def local(action, options={})
      
      case action.to_sym
      when :open_web_page
        open(options[:url_to_open]).read
      end
    end

    # Object Property (op)
    # Helpful for accessing properites in dot notation 
    # e.g. op.livingroom.light.switch = 'off'
    #    
    def op()
      @model.op
    end
    
    def query(device, id=nil)
      
      return Query.new(device, self) unless id
      
      @store[id] = nil

      sys = %i(accelerometer_rotation)      
      
      global = [:airplane_mode_on, :bluetooth_on, :cell_on, :device_name, \
                :usb_mass_storage_enabled, :wifi_on]       
      
      secure = %i(bluetooth_name flashlight_enabled)

      
      # send http request via macrodroid.com API
      
      identifier, options = if id.downcase.to_sym == :location then
        id
      elsif sys.include? id
        [:'query-setting-system', {qvar: id}]
      elsif global.include? id
        [:'query-setting-global', {qvar: id}]
      elsif secure.include? id
        [:'query-setting-secure', {qvar: id}]
      elsif id.downcase.to_sym == :'take-picture'
        id
      else
        [:query, {qvar: id}]
      end
      
      control(device).http_exec identifier, options
      
      # wait for the local variable to be updated
      # timeout after 5 seoncds
      t = Time.now
      
      begin
        sleep 1
      end until @store[id] or Time.now > t + 10
      
      return {warning: 'HTTP response timeout'} if Time.now > t+5
      
      return @store[id]

      
    end    
    
    def request(s)
      @model.request s
    end
    
    def run_macro(macro_name: '')
      
      found = @macros.find do |macro|
        macro.title.downcase == macro_name.downcase
      end
      
      found.run if found
      
    end
    
    def trigger(name, detail={})
      
      macros = @macros.select do |macro|
        
        puts 'macro: '  + macro.inspect if @debug

        # fetch the associated properties from the model if possible and 
        # merge them into the detail.
        #
        valid_trigger = macro.match?(name, detail, @model.op)
        
        #puts 'valid_trigger: ' + valid_trigger.inspect if @debug
        
        #if valid_trigger then
        #  @syslog << [Time.now, :trigger, name] 
        #  @syslog << [Time.now, :macro, macro.title]
        #end
        
        @syslog << [Time.now, name, detail]
                     
        valid_trigger
        
      end
      
      puts 'macros: ' + macros.inspect if @debug
      
      macros.flat_map(&:run)
    end
    
    alias trigger_fired trigger
    
    def update(id, val)
      
      if @debug then
        puts 'inside update' 
        puts [id, val].inspect
      end
      
      key  = if %i(location take-picture).include? id
        id
      else
        val.keys.first.to_sym
      end
      
      @syslog << [id, val]      
      @store[key] = val   
      
    end
        
  end
end
