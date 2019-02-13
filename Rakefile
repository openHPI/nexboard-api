require 'bundler/gem_tasks'
require 'rspec/core/rake_task'

RSpec::Core::RakeTask.new(:spec) do | task |
  task.pattern = "spec/lib/*.rb"
end
task default: :spec

RSpec::Core::RakeTask.new(:pact) do | task |
  task.pattern = "spec/pacts/nexboard_api_pact_spec.rb"
end
