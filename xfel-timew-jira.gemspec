# frozen_string_literal: true

require_relative './lib/xfel/timew/version'

Gem::Specification.new do |spec|
  spec.name = 'xfel-timew-jira'
  spec.version = Xfel::Timew::VERSION
  spec.authors = ['Fernando Jascovich']
  spec.email = ['fernando.ej@gmail.com']
  spec.summary = 'Jira sync and report for TimeWarrior'
  spec.description = <<-DESCRIPTION
    This gem generates a Jira ticket oriented summary and it syncs TimeWarrior entries with Jira ticket's worklog.
  DESCRIPTION
  spec.homepage = 'https://github.com/fernando-jascovich/xfel-timew-jira'
  spec.license = 'MIT'
  spec.files = Dir['lib/**/*']
  spec.add_development_dependency 'bundler', '~> 2.1.4'
  spec.add_development_dependency 'rake', '~> 10.0'
  spec.add_development_dependency 'rspec', '~> 3.0'
  spec.add_development_dependency 'simplecov', '~> 0.19.0'
  spec.add_dependency 'terminal-table', '~> 1.8.0'
  spec.required_ruby_version = '>= 2.6'
end
