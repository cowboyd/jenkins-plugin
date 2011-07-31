
require 'jenkins/plugins/proxies/build_wrapper'

module Jenkins
  module Plugins

    ExportError = Class.new(StandardError)

    # Maps JRuby objects part of the idomatic Ruby API
    # to a plain Java object representation and vice-versa.
    #
    # One of the pillars of Jenkins Ruby plugins is that writing
    # plugins must "feel" like native Ruby, and not merely like
    # scripting Java with Ruby. To this end, jenkins-plugins provides
    # a idiomatic Ruby API that sits on top of the native Jenkins
    # Java API with which plugin developers can interact.
    #
    # This has two consequences. Native Ruby objects authored as part
    # of the plugin must have a foreign (Java) representation with which
    # they can wander about the Jenkins universe and possibly interact
    # with other foreign objects and APIs. Also, Foreign objects
    # coming in from Jenkins at large should be wrapped, where possible
    # to present an idomatic interface..
    #
    # Finally, Native plugin that had been wrapped and are comping home
    # must be unwrapped from their external form.
    #
    # For all cases, we want to maintain referential integrety so that
    # the same object always uses the same external form, etc... so
    # there is one instance of the `Proxies` class per plugin which will
    # reuse mappings where possible.
    class Proxies

      # A weakly referenced list of external forms keyed by native Ruby object.
      attr_reader :wrappers

      def initialize(plugin)
        @plugin = plugin
        @int2ext = java.util.WeakHashMap.new
        @ext2int = java.util.WeakHashMap.new
      end

      # Reflect a foreign Java object into the context of this plugin.
      #
      # If the object is a native plugin object that had been previously
      # exported, then it will unwrapped.
      #
      # Otherwise, we try to choose the best idiomatic API object for
      # this foreign object
      #
      # TODO: //think about the case where the foreign object that is
      # actually a Ruby object native to another ruby plugin.
      #
      # @param [Object] object the object to bring in from the outside
      # @return the best representation of that object for this plugin
      def import(object)
        if ref = @ext2int[object]
          return ref.get() if ref.get()
        end
      end

      # Reflect a native Ruby object into its External Java form.
      #
      # Try to find a suitable form for this object (currently in a very cheesy way)
      # and if one is found then decorate it.

      # If no wrapper class is available, return just return the opaque `RubyObject`.
      # This is probably less than useful, and cause exceptions unless Jenkins is
      # expecting a `java.lang.Object`
      def export(object)
        if ref = @int2ext[object]
          return ref.get() if ref.get()
        end

        cls = object.class
        while cls do
          if proxy_class = @@intcls2extcls[cls]
            proxy = proxy_class.new(@plugin, object)
            link(object, proxy)
            return proxy
          end
          cls = cls.superclass
        end
        raise ExportError, "unable to find suitable Java Proxy for #{object.inspect}"
      end

      def link(internal, external)
        @int2ext.put(internal, java.lang.ref.WeakReference.new(external))
        @ext2int.put(external, java.lang.ref.WeakReference.new(internal))
      end

      def self.clear
        @@intcls2extcls = {}
        @@extcls2intcls = {}
      end
      clear

      def self.register(internal_class, external_class)
        @@intcls2extcls[internal_class] = external_class
        @@extcls2intcls[external_class] = internal_class
      end

    end
  end
end