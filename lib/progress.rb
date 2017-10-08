class Progress
  def self.create options = {}
    ops = {
      format: "%a %e %P% Processed: %c from %C",
      throttle_rate: 0.5
    }.merge(options)

    ProgressBar.create ops
  end
end
