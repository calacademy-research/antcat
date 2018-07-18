class Progress
  def self.create options = {}
    ProgressBar.create default_options.merge(options)
  end

  private

    def self.default_options
      { format: "%a %e %P% Processed: %c from %C", throttle_rate: 0.5 }
    end
    private_class_method :default_options
end
