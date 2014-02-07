# EverydayPlugins

A simple gem plugin system.  Extracted from `mvn2`.  Plugins have to be defined in gems for them to be able to be picked up on automatically.

## Installation

Add this line to your application's Gemfile:

    gem 'everyday-plugins'

And then execute:

    $ bundle

Or install it yourself as:

    $ gem install everyday-plugins

## Usage

###For conditionally running plugin setup code (or other code) based on installed gems
As of version 1.1.0, there is support for running a block of code based on whether or not certain gems are installed.  This is via the `EverydayPlugins::Loader` module.  You can either `extend` it and use the `depend` method like any other plugin setup method, or you can use the static `EverydayPlugins::Loader.depend` method.  The method takes each dependency as a separate argument.  If you want to specify more than just the name of the gem (for example, if you want to require a minimum version), you need to put the parameters for that argument into an array.

Here is an example:

```ruby
EverydayPlugins::Loader.depend(['bundler', '~> 1.5'], 'rake') {
  #do stuff here
}
```

And here is an example using `extend`:

```ruby
class MyLoader
  extend EverydayPlugins::Loader
  
  depend(['bundler', '~> 1.5'], 'rake') {
    #do stuff here
  }
end
```

###For supporting plugins:
See below for info on defining and using plugin types.  As for including plugins, use

```ruby
EverydayPlugins::Plugins.load_plugins '{folder}'
```

where `{folder}` is the folder name you specify for your plugins to be put in.  For example, my `mvn2` gem uses

```ruby
EverydayPlugins::Plugins.load_plugins 'mvn2'
```

###For creating plugins:

The files have to match the pattern `{folder}/plugin/*.plugin.rb` in your gem's `lib/` folder, where `{folder}` is whatever folder path the gem you are adding a plugin to requires.  If you do that, when the gem is installed, the gem accepting plugins will automatically pick up on it and load it.

Two examples of this are my gems `colorconfig` and `mvn2-say`.

The `EverydayPlugins::Plugin` module is used for registering a plugin of a defined type.  It defines the `register` method.  You should use `extend` so that you can define things statically.  There is no need for a `build` method because it automatically adds the plugins at the time you call the method.

Here is an example:

```ruby
register :option, sym: :timer, names: %w(-t --timer), desc: 'display a timer while the build is in progress'
```

And another:

```ruby
register(:before_run, order: 2) { |options|
  EverydayPlugins::Plugins.set_var :time1, Time.now
  EverydayPlugins::Plugins.set_var :thread, options[:timer] ? Thread.new {
    start_time = EverydayPlugins::Plugins.get_var :time1
    while true
      print "\r#{get_timer_message(start_time, Time.now)}"
      sleep(0.05)
    end
  } : nil
}
```

The `register` method takes a first parameter of the plugin type identifier, followed by an optional (but probably necessary) hash of options, and an optional block (usable with most built-in plugin types, required by some).

-----

If you want to define a new plugin type, you can extend the `EverydayPlugins::PluginType`.  This defines the `register_type` and `register_variable` methods.  Technically, you don't really need to register a variable, but if you want to give it a certain starting value, you will need to register it and pass over the value.  `register_type` takes a first parameter of the plugin type identifier, followed by a block.  The block will always take a first parameter of the list of instances, followed by any additional parameters passed to the plugin when it is called.  The block has the task of taking the list of plugin instances and turning it into whatever result the plugin is supposed to have.

Here is an example:

```ruby
register_type(:command_flag) { |list|
  options = EverydayPlugins::Plugins.get_var :options
  flags   = []
  list.each { |flag|
    if flag[:block].nil?
      flags << " #{flag[:options][:flag]}" if flag[:options].has_key?(:option) && options[flag[:options][:option]] == (flag[:options].has_key?(:value) ? flag[:options][:value] : true)
    else
      flag[:block].call(options, flags)
    end
  }
  flags.join
}
```

-----

You might notice in the second plugin example, as well as the plugin type example, methods are called on `EverydayPlugins::Plugins`.  This is the class that stores all of the plugins and types.  It has various methods, but the ones involved in making a plugin are:

* `EverydayPlugins::Plugins.get(type, *args)`
    * Gets the result of a plugin type.  The first parameter is the plugin type identifier, followed by any additional arguments the plugin type takes.
* `EverydayPlugins::Plugins.get_var(name)`
    * Gets a single variable by name
* `EverydayPlugins::Plugins.get_vars(*names)`
    * Gets a list of variables by name.  Useful for getting a lot of variables in one line.
* `EverydayPlugins::Plugins.set_var(name, value)`
    * Sets a single variable of the given name to the given value.
* `EverydayPlugins::Plugins.set_vars(vars = {})`
    * Sets a list of variables to the values specified.  It use a hash format, so you can do something like `EverydayPlugins::Plugins.set_vars found: true, info_line_last: false`

## Contributing

1. Fork it ( http://github.com/henderea/everyday-plugins/fork )
2. Create your feature branch (`git checkout -b my-new-feature`)
3. Commit your changes (`git commit -am 'Add some feature'`)
4. Push to the branch (`git push origin my-new-feature`)
5. Create new Pull Request
