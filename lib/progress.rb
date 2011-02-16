# Progress.init total_items, show_progress
# Progress.puts 'Importing...'
# ...
# Progress.tally_and_show_progress increment

class Progress
  def self.init on, total_count = nil
    $stderr = File.open('/dev/null', 'w') unless on
    @start = Time.now
    @processed_count = 0
    @total_count = total_count
  end

  def self.open_log name
    file = File.open name, 'w'
    file.sync = true
    @logger = Logger.new file
  end

  def self.tally
    @processed_count += 1
  end

  def self.puts string = ''
    print string + "\n"
  end

  def self.print string
    $stderr.print string
  end

  def self.dot
    print '.'
  end

  def self.info object
    string = "INFO: #{format_object(object)}"
    log string
  end

  def self.error object
    string = "ERROR: #{format_object(object)}"
    puts string
    log string
  end

  def self.log string
    @logger.info string if @logger
    Rails.logger.info string
  end

  def self.format_object object
    object.kind_of?(String) ? object : object.inspect
  end

  def self.rate processed_count = nil
    processed_count ||= @processed_count
    sprintf "%.2f/sec", rate_per_sec(processed_count)
  end

  def self.time_left total_count = nil, processed_count = nil
    total_count ||= @total_count
    processed_count ||= @processed_count
    mins_left = (total_count - processed_count).to_f / rate_per_sec(processed_count) / 60
    mins_left = [mins_left, 1.0].max unless processed_count == total_count
    sprintf "#{mins(mins_left)} left", mins_left
  end

  def self.mins mins
    noun = 'min'
    noun << 's' if mins > 1
    sprintf "%.0f #{noun}", mins
  end

  def self.percent numerator, denominator = @processed_count
    sprintf "%.0f%%", numerator * 100.0 / denominator
  end

  def self.elapsed
    mins [(elapsed_secs.to_f / 60), 1.0].max
  end

  def self.count count, total, label
    "#{count} (#{percent(count, total)}) #{label}"
  end

  def self.show_count count, total, label
    puts count count, total, label
  end

  def self.processed_count
    @processed_count
  end

  def self.total_count
    @total_count
  end

  def self.show_progress increment = nil
    return unless increment.nil? or processed_count % increment == 0
    puts progress_message
  end

  def self.progress_message
    if total_count
      count = "#{processed_count}/#{total_count}".rjust(12)
      rate = self.rate.rjust(10)
      time_left = self.time_left.rjust(11)
      "#{count} #{rate} #{time_left}"
    else
      count = "#{processed_count}".rjust(8)
      rate = self.rate.rjust(9)
      "#{count} #{rate}"
    end
  end

  def self.tally_and_show_progress increment = nil
    tally
    show_progress increment
  end

  def self.show_results
    puts results_string
  end

  def self.results_string
    "#{processed_count} processed in #{elapsed} #{rate}"
  end

  private
  def self.elapsed_secs
    Time.now - @start
  end

  def self.rate_per_sec count
    count.to_f / elapsed_secs
  end
end
