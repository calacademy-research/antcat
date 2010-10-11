class Progress
  def self.init on
    $stderr = File.open('/dev/null', 'w') unless on
    @start = Time.now
  end

  def self.puts string = ''
    $stderr.puts string
  end

  def self.print string
    $stderr.print string
  end

  def self.dot
    print '.'
  end

  def self.rate count
    sprintf "%.2f/sec", rate_per_sec(count)
  end

  def self.time_left processed_count, total_count
    mins_left = (total_count - processed_count).to_f / rate_per_sec(processed_count) / 60
    mins_left = [mins_left, 1.0].max unless processed_count == total_count
    sprintf "%.0f mins left", mins_left
  end

  def self.percent numerator, denominator
    sprintf "%.0f%%", numerator * 100.0 / denominator
  end

  def self.elapsed
    sprintf "%.0f mins", [(elapsed_secs.to_f / 60), 1.0].max
  end

  def self.count count, total, label
    "#{count} (#{percent(count, total)}) #{label}"
  end

  private
  def self.elapsed_secs
    Time.now - @start
  end

  def self.rate_per_sec count
    count.to_f / elapsed_secs
  end
end
