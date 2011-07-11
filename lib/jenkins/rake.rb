require 'zip/zip'
# TODO: how do I differentiate runtime dependency and rake task dependency?
# I don't need rubyzip during runtime. Only during the build time of the user plugins.

module Jenkins
  module Rake
    def self.install_tasks
      desc "package up stuff into HPI file"
      ::Rake::Task.define_task :package do
        Dir.mkdir "target" if !File.exists?("target")
        File.delete "target/the.hpi" if File.exists?("target/the.hpi")

        Zip::ZipFile.open("target/the.hpi", Zip::ZipFile::CREATE) do |zipfile|
          zipfile.get_output_stream("META-INF/MANIFEST.MF") do |f|
            f.puts "Manifest-Version: 1.0"
            f.puts "Created-By: jenkins-plugins.rb v.???" # TODO: how do we know our own version?
            f.puts "Build-Ruby-Platform: #{RUBY_PLATFORM}"
            f.puts "Build-Ruby-Version: #{RUBY_VERSION}"

            f.puts "Group-Id:"
            f.puts "Short-Name:"
            f.puts "Long-Name:"
            f.puts "Url:"
            # f.puts "Compatible-Since-Version:"
            f.puts "Plugin-Version:"
            f.puts "Jenkins-Version:"
            f.puts "Plugin-Dependencies:"
            f.puts "Plugin-Developers:"
          end
          zipfile.mkdir("WEB-INF/classes")

          Dir.glob("lib/**/*") do |f|
            if !File.directory? f
              zipfile.add("WEB-INF/classes/#{f[4..-1]}",f)
            end
          end
        end
      end
    end
  end
end