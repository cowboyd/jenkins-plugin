
#require 'jenkins/plugin/version'

module Jenkins
  class Plugin
    module Tools
      class Manifest
        MAX_LENGTH = 72.to_i

        def initialize(spec)
          @spec = spec
        end

        def write_hpi(io)
          io.puts "Manifest-Version: 1.0"
          io.puts "Created-By: #{Jenkins::Plugin::VERSION}"
          io.puts "Build-Ruby-Platform: #{RUBY_PLATFORM}"
          io.puts "Build-Ruby-Version: #{RUBY_VERSION}"

          io.puts "Group-Id: org.jenkins-ci.plugins"
          io.puts "Short-Name: #{@spec.name}"
          io.puts "Long-Name: #{@spec.name}" # TODO: better name
          io.puts "Url: http://jenkins-ci.org/" # TODO: better value

          io.puts "Plugin-Class: ruby.RubyPlugin"
          io.puts "Plugin-Version: #{@spec.version}"
          io.puts "Jenkins-Version: 1.426"

          io.puts "Plugin-Dependencies: " + @spec.dependencies.map{|k,v| "#{k}:#{v}"}.join(",")
        end

        def write_hpl(io, loadpath)
          write_hpi(io)

          io.puts manifest_truncate("Load-Path: #{loadpath.to_a.join(':')}")
          io.puts manifest_truncate("Lib-Path: #{Dir.pwd}/lib/")
          io.puts manifest_truncate("Models-Path: #{Dir.pwd}/models")
          # Stapler expects view erb/haml scripts to be in the JVM ClassPath
          io.puts manifest_truncate("Class-Path: #{Dir.pwd}/views") if File.exists?("#{Dir.pwd}/views")
          # Directory for static images, javascript, css, etc. of this plugin.
          # The static resources are mapped under #CONTEXTPATH/plugin/SHORTNAME/
          io.puts manifest_truncate("Resource-Path: #{Dir.pwd}/static")

        end

        def manifest_truncate(message)
          if message.length < MAX_LENGTH
            return message
          end

          line = message[0 ... MAX_LENGTH] + "\n"
          offset = MAX_LENGTH

          while offset < message.length
            line += " #{message[offset ... (offset + MAX_LENGTH - 1)]}\n"
            offset += (MAX_LENGTH - 1)
          end
          return line
        end
      end
    end
  end
end
