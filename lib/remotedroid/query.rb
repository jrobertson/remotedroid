module RemoteDroid

  class Query
    
    attr_accessor :locations
    
    def initialize(callback)
      @callback = callback
      @locations = []
    end
    
    def airplane_mode_enabled?()
      q(:airplane_mode_on).to_i > 0 
    end
    
    def battery()      
      q(:battery).to_i
    end
    
    def current_brightness()      
      q(:current_brightness).to_i
    end

    alias brightness current_brightness
    
    def cell_id()      
      q(:cell_id)
    end
    
    alias cell_tower cell_id
    
    def ip()      
      q(:ip)
    end    
    
    def location()      
      
      r = @callback.query(:location)
      return r if r.nil? or r.empty? or r[:coords].nil?
      
      r[:coords] = r[:coords].split(',')
      r[:time] = Time.parse(r[:time])
      @locations << r
      @locations.shift if @locations.length > 1000
      
      return r
    end    

    def take_picture()      
      @callback.query(:'take-picture')
    end
    
    def take_screenshot()      
      @callback.query(:'take-screenshot')
    end    
    
    private
    
    def q(id)
      @callback.query(id)[id]
    end
    
  end
end
