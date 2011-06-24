
module Jenkins
  module Rake
    def self.install_tasks
      ::Rake::Task.define_task :package do
        puts "I'm not actually packaging anything"
      end
    end
  end
end