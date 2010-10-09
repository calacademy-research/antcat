class Progress
  def self.init on
    $stderr = File.open('/dev/null', 'w') unless on
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
end
