if Rails.env.development?
  MAX_LOG_SIZE = 2.megabytes
  
  logs = File.join(Rails.root, 'log', '*.log')
  if Dir[logs].any? {|log| File.size?(log).to_i > MAX_LOG_SIZE }
    $stdout.puts "Runing rake log:clear"
    `rake log:clear`
  end 
end
