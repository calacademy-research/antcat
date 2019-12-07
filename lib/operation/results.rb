# `Results` belong to a single instance of an `Operation`.

module Operation
  class Results < OpenStruct
    def fail!
      self.failure = true
    end

    def failure?
      failure || false
    end

    def success?
      !failure?
    end
  end
end
