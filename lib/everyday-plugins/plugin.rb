require 'rubygems'
require 'everyday-cli-utils'
EverydayCliUtils.import :maputil

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
            puts e.backtrace.join("\n")
            exit 1 if error_fatal
          end
        }
      rescue Exception => e
        puts 'Error in loading plugins'
        puts e.inspect
        puts e.backtrace.join("\n")
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
  module Loader
    def depend(*deps, &block)
      EverydayPlugins::Loader.depend(*deps, &block)
    end

    def self.depend(*deps, &block)
      met = deps.all? { |dep|
        matches = Gem::Specification.find_all_by_name(*dep)
        !(matches.nil? || matches.empty?)
      }
      block.call if met
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
  module TypeHelper
    def basic_type(list, *args)
      options = Plugins.get_var :options
      list.any? { |item|
        if item[:block].nil?
          flag_boolean(item, options)
        else
          item[:block].call(options, *args)
        end
      }
    end

    def flag_boolean(item, options)
      item[:options].has_key?(:option) && options[item[:options][:option]] == (item[:options].has_key?(:value) ? item[:options][:value] : true)
    end

    def complex_filter(list, options, symbol)
      list.filtermap { |item|
        if item[:block].nil?
          if item[:options].has_key?(symbol) && flag_boolean(item, options)
            item[:options][symbol]
          else
            item[:options].has_key?(:option) && !options[item[:options][:option]].nil? ? options[item[:options][:option]] : false
          end
        else
          rval = item[:block].call(options)
          (rval.nil? || !rval) ? false : rval
        end
      }
    end

    def simple_type(list, *args)
      options = Plugins.get_var :options
      list.sort_by { |v| v[:options][:order] }.each { |item| item[:block].call(options, *args) }
    end

    def simple_type_with_result(list)
      result = Plugins.get_var :result
      simple_type(list, result)
    end

    def get_name(list)
      options = Plugins.get_var :options
      rval    = complex_filter(list.sort_by { |v| -v[:options][:priority] }, options, :name)
      (rval.nil? || rval.empty?) ? false : rval.first
    end
  end
end