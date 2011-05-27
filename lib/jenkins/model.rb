
module Jenkins
  module Model

    module Included
      def included(cls)
        super(cls)
        if cls.class == Module
          cls.extend(Included)
        else
          cls.extend(ClassMethods)
          cls.send(:include, InstanceMethods)
        end
      end
    end
    extend Included
    
    module InstanceMethods
      def display_name
        self.class.display_name
      end
    end
    
    module ClassMethods
      def display_name(name = nil)
        name.nil? ? @display_name || self.name : @display_name = name.to_s
      end
      
      def transient(*properties)
        properties.each do |p|
          transients[p.to_sym] = true
        end
      end
      
      def transient?(property)
        transients.keys.member?(property.to_sym) || (superclass < Model && superclass.transient?(property))
      end
      
      def transients
        @transients ||= {}
      end
    end
  end
end