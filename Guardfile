# frozen_string_literal: true

require "colorize"

def running_test file, command
  Notifier.notify "Running", title: "#{command} #{file}", image: :pending
end

def guard_all?
  return false unless guard_env_var

  guard_env_var['all'] || guard_env_var[/^a/]
end

def guard_rspec?
  return true if guard_all?
  return true if guard_env_var.nil?

  guard_env_var['spec'] || guard_env_var[/^s/]
end

def guard_rubocop?
  return true if guard_all?
  return false unless guard_env_var

  guard_env_var['rubocop'] || guard_env_var[/^r/]
end

def not_guarding_anything?
  !(guard_rspec? || guard_rubocop?)
end

def guard_env_var
  ENV["GUARD"]
end

if guard_rspec?
  puts "Guarding rspec".green

  guard :rspec, cmd: "bundle exec rspec" do
    watch(%r{^app/(.+)\.rb$}) do |m|
      file = "spec/#{m[1]}_spec.rb"
      file.tap { running_test file, :rspec }
    end

    watch(%r{^lib/(.+)\.rb$}) do |m|
      file = "spec/lib/#{m[1]}_spec.rb"
      file.tap { running_test file, :rspec }
    end

    watch(%r{^spec/(.+_spec.rb)$}) do |m|
      file = m[0]
      file.tap { running_test file, :rspec }
    end
  end

  # Do not run all specs.
  ObjectSpace.each_object(Guard::RSpec) do |object|
    def object.run_all
    end
  end
end

if guard_rubocop?
  puts "Guarding rubocop".green

  guard :rubocop, all_on_start: false do
    watch(/.+\.rb$/)
  end
end

if not_guarding_anything?
  puts 'Not guarding anything!'.red
  exit 1
end
