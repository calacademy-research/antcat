# coding: UTF-8
# Progress.init show_progress, total_items
# Progress.puts 'Importing...'
# ...
# Progress.tally_and_show_progress increment

class Progress

  #################################################################################
  # initialization

  def self.init show_progress, total_count = nil, log_file_name = nil, append_to_log_file = false
    new_init show_progress: show_progress, total_count: total_count, log_file_name: log_file_name, append_to_log_file: append_to_log_file
  end

  def self.new_init options = {}
    @show_progress = options[:show_progress]
    @start = Time.now
    @processed_count = 0
    @total_count = options[:total_count]
    open_log options[:log_file_name], options[:append_to_log_file], options[:log_file_directory]
  end

  #################################################################################
  # basic output

  def self.print string
    log string
    display string
  end

  def self.puts string = "\n"
    if string[-1, 1] == "\n"
      print string
    else
      print string + "\n"
    end
  end

  def self.display string
    $stdout.print string if @show_progress
  end

  def self.dot
    display '.'
  end

  def self.log object, prefix = nil
    string = format_object object
    string = prefix + ': ' + string if prefix
    string = string[0..-2] if string[-1] == "\n"
    @logger.info string if @logger
    Rails.logger.info string
  end

  def self.info object
    log object, "INFO"
  end

  def self.warning object
    log object, "WARNING"
  end

  def self.error object
    log object, "ERROR"
  end

  #################################################################################
  # formatting

  def self.format_object object
    object.kind_of?(String) ? object : object.inspect
  end

  def self.count count, total, label
    "#{count} (#{percent(count, total)}) #{label}"
  end

  def self.show_count count, total, label
    puts count count, total, label
  end

  def self.percent numerator, denominator = @processed_count
    sprintf "%.0f%%", numerator * 100.0 / denominator
  end

  def self.mins mins
    noun = 'min'
    noun << 's' if mins > 1
    sprintf "%.0f #{noun}", mins
  end

  def self.method
    string = caller[0].to_s
    string = string.match(/`(.*?)'/)[1].to_s
    info ">> " + string
  end

  #################################################################################
  # tallying and reporting

  def self.tally
    @processed_count += 1
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

  def self.elapsed
    mins [(elapsed_secs.to_f / 60), 1.0].max
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

  ##########################################################################

  private

  def self.open_log file_name, append, directory
    return unless file_name
    file_name = make_file_name file_name, directory
    file = File.open file_name, append ? 'a' : 'w'
    file.sync = true
    @logger = Logger.new file
    log "\n#{Time.now}" if append
  end

  def self.make_file_name file_name, directory
    file_name = file_name.gsub /::/, '_'
    file_name = file_name.underscore
    file_name = Rails.root.join (directory ? directory : 'log') + '/' + file_name + "-#{Rails.env}.log"
    file_name
  end

  def self.elapsed_secs
    Time.now - @start
  end

  def self.rate_per_sec count
    count.to_f / elapsed_secs
  end
end
