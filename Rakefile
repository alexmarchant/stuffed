require 'bundler'
Bundler::GemHelper.install_tasks

desc "Build the project"
task :default => 'test'

desc "Run tests"
task :test do
    sh "bundle exec rspec"
end
