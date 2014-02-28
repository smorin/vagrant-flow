require 'rubygems'
require 'bundler'
# require 'bundler/setup'    # Was in the example
require 'bundler/gem_tasks'  # Was in the template version

# Immediately sync all stdout so that tools like buildbot can
# immediately load in the output.
$stdout.sync = true
$stderr.sync = true

# Change to the directory of this file.
Dir.chdir(File.expand_path("../", __FILE__))

# This installs the tasks that help with gem creation and
# publishing.
Bundler::GemHelper.install_tasks



namespace :flow do
  desc 'noop does nothing'
  task(:noop) do
    puts("noop\n")
  end

  desc 'Removes testing vagrant box.'
  task(:cleanup) do
    # example running vagrant tasks
    # system('bundle exec vagrant destroy -f')
    # system('bundle exec vagrant box remove vagrant_exec virtualbox')
  end
end
