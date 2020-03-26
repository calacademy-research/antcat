# frozen_string_literal: true

# Show slow scenarios
# Enable like this: `cucumber SHOW_SLOW_SCENARIOS=y`
#
# Use the built-in `cucumber --format usage` for steps finding slow steps.
if ENV["SHOW_SLOW_SCENARIOS"]
  scenarios = {}

  Around do |scenario, block|
    start = Time.current
    block.call
    scenarios[scenario.location.to_s] = {
      duration: (Time.current - start),
      name: scenario.name
    }
  end

  def sort_scenarios_by_runtime scenarios
    scenarios.sort { |a, b| b[1][:duration] <=> a[1][:duration] }
  end

  at_exit do
    puts "Slowest scenarios:".blue
    sort_scenarios_by_runtime(scenarios).each do |key, value|
      puts "#{value[:duration].round(2)} #{key.green} #{value[:name]}"
    end
  end
end
