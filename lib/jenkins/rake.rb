
module Jenkins
  module Rake
    def self.install_tasks
      desc "package up stuff into HPI file"
      ::Rake::Task.define_task :package do
        puts "I'm not actually packaging anything"
        puts RUBY_PLATFORM
      end
    end
  end
end