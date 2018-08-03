require "colorize"

def running_test file, command
  Notifier.notify "Running", title: "#{command} #{file}", image: :pending
end

guard :rspec, cmd: "bundle exec rspec" do
  watch(%r{^app/(.+)\.rb$}) do |m|
    file = "spec/#{m[1]}_spec.rb"
    file.tap { running_test file, :rspec }
  end

  watch(%r{^lib/(.+)\.rb$}) do |m|
    file = "spec/lib/#{m[1]}_spec.rb"
    file.tap { running_test file, :rspec }
  end

  watch(%r{^spec/(.+\_spec.rb)$}) do |m|
    file = m[0]
    file.tap { running_test file, :rspec }
  end
end

if ENV["LINT"]
  guard :rubocop, all_on_start: false do
    watch(/.+\.rb$/)
  end

  ObjectSpace.each_object(::Guard::RuboCop) do |object|
    def object.run_all
    end
  end
end

# Disable running of all tests for plugins that does not support `run_all: false`.
ObjectSpace.each_object(::Guard::RSpec) do |object|
  def object.run_all
  end
end
