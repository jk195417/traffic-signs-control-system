require "json"

module Config
  class << self
    def path(path)
      @path = path
      if File.exist?(path+'.json')
        @config = JSON.parse(File.read(path+'.json'))
      else
        @config = get_default
      end
    end

    def reset
      @config = get_default
    end

    def update
      File.open(@path+'.json',"w") do |f|
        f.write(JSON.pretty_generate(@config))
      end
    end

    def get
      @config
    end

    def set(conf)
      conf.delete_if {|key, value| value == "" }
      conf.each {|key, value| @config[key]=value }
    end

    private
    
    def get_default
      File.exist?(@path+'_default.json') ? JSON.parse(File.read(@path+"_default.json")) : {}
    end
  end
end