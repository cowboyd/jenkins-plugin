require 'bundler'
Bundler::GemHelper.install_tasks

require 'rspec/core/rake_task'
RSpec::Core::RakeTask.new(:spec)

require 'jenkins/war'
ClassPath =  FileList[File.join(ENV['HOME'], '.jenkins', 'wars', Jenkins::War::VERSION, "**/*.jar")].to_a.join(':')

desc "compile java source code"
task "compile" => "target" do
  puts command = "javac -classpath #{ClassPath} #{FileList['src/**/*.java']} -d target"
  system(command)
end

require 'rake/clean'
directory "target"
CLEAN.include("target")