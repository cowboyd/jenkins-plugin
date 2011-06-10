
require 'pathname'

module Jenkins
  # Acts as the primary gateway between Ruby and Jenkins
  # There is one instance of this object for the entire
  # plugin
  #
  # On the Java side, it contains a reference to an instance
  # of RubyPlugin. These two objects talk to each other to
  # get things done.
  class Plugin

    # A list of all the hudson.model.Descriptor objects
    # of which this plugin is aware *indexed by Wrapper class*
    #
    # This is used so that wrappers can always have a single place
    # to go when they are asked for a descriptor. That way, wrapper
    # instances can always return the descriptor associated with
    # their class.
    #
    # This may go away.
    attr_reader :descriptors

    # Initializes this plugin by reading the models.rb
    # file. This is a manual registration process
    # Where ruby objects register themselves with the plugin
    # In the future, this process will be automatic, but
    # I haven't decided the best way to do this yet.
    #
    # @param [RubyPlugin] java a native java RubyPlugin
    def initialize(java)
      @java = java
      @start = @stop = proc {}
      @descriptors = {}
      @wrappers = {}
      load_models
      script = 'support/hudson/plugin/models.rb'
      self.instance_eval @java.read(script), script

    end

    # Called once when Jenkins first initializes this plugin
    # currently does nothing, but plugin startup hooks would
    # go here.
    def start
      @start.call()
    end

    # Called one by Jenkins (via RubyPlugin) when this plugin
    # is shut down. Currently this does nothing, but plugin
    # shutdown hooks would go here.
    def stop
      @stop.call()
    end

    # Reflect an Java object coming from Jenkins into the context of this plugin
    # If the object is originally from the ruby plugin, and it was previously
    # exported, then it will unwrap it. Otherwise, it will just use the object
    # as a normal Java object.
    #
    # @param [Object] object the object to bring in from the outside
    # @return the best representation of that object for this plugin
    def import(object)
      object.respond_to?(:unwrap) ? object.unwrap : object
    end

    # Prepare an object for its journey into the outside world of Jenkins.
    # It will try to find a suitable wrapper for the object (currently in a very cheesy way)
    # and if one is found then it decorate it with that wrapper.
    #
    # This decoration is necessary so that the object can provide the Java interface which Jenkins
    # needs to operate, but the underlying Ruby object can look and act like a normal Ruby object.
    #
    # If no wrapper class is available, then it will return just return the native ruby object. This
    # is probably not the best behavior, since it will appear as an opaque `RubyObject` which
    # can't do much in the context of Jenkins.
    #
    # @param [Object] object the object
    def export(object)
      return @wrappers[object] if @wrappers[object]
      case object
        when Hudson::Plugin::Cloud
          puts "it's a cloud, I'm going to wrap it"
          wrapper = Hudson::Plugin::Cloud::Wrapper.new(self, object)
          puts "wrapper created: #{wrapper}"
          return wrapper
        when Hudson::Plugin::BuildWrapper
          puts "it's a build wrapper, I'm going to wrap it"
          wrapper = Hudson::Plugin::BuildWrapper::Wrapper.new(self, object)
        else object
      end
    end

    def load_models
      for filename in Dir["#{model_path}/**/*.rb"]
        load filename
      end
    end

    def model_path
      Pathname(__FILE__).dirname.join('../../../plugin/models')
    end

  end
end
