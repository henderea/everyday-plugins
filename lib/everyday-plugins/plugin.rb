module EverydayPlugins
  class Plugins
    def self.instance
      @instance ||= Plugins.new
    end

    def self.load_plugins(path, error_fatal = false)
      begin
        Gem.find_latest_files("/#{path}/plugin/*.plugin.rb").each { |plugin|
          #noinspection RubyResolve
          begin
            require plugin
          rescue LoadError => e
            puts "Error in loading plugin '#{plugin}'"
            puts e.inspect
            exit 1 if error_fatal
          end
        }
      rescue Exception => e
        puts 'Error in loading plugins'
        puts e.inspect
        exit 1 if error_fatal
      end
    end

    def initialize
      @ext   = {}
      @types = {}
      @vars  = {}
    end

    def register(type, options = {}, &block)
      @ext[type] ||= []
      @ext[type] << { options: options, block: block }
    end

    def register_type(type, &block)
      @types[type] = block
    end

    def register_variable(name, value = nil)
      @vars[name] = value
    end

    def [](type)
      @ext[type] || []
    end

    def get(type, *args)
      @types[type].call(self[type], *args)
    end

    def self.get(type, *args)
      instance.get(type, *args)
    end

    def get_var(name)
      @vars[name] || nil
    end

    def get_vars(*names)
      names.map { |name| get_var(name) }
    end

    def set_var(name, value)
      @vars[name] = value
    end

    def set_vars(vars = {})
      vars.each { |v| set_var(*v) }
    end

    def self.get_var(name)
      instance.get_var(name)
    end

    def self.get_vars(*names)
      instance.get_vars(*names)
    end

    def self.set_var(name, value)
      instance.set_var(name, value)
    end

    def self.set_vars(vars = {})
      instance.set_vars(vars)
    end
  end
  module Plugin
    def register(type, options = {}, &block)
      EverydayPlugins::Plugins.instance.register(type, options, &block)
    end
  end
  module PluginType
    def register_type(type, &block)
      EverydayPlugins::Plugins.instance.register_type(type, &block)
    end

    def register_variable(name, value = nil)
      EverydayPlugins::Plugins.instance.register_variable(name, value)
    end
  end
end