# frozen_string_literal: true

class DatabaseTestScript < DatabaseScript
  def results
    Reference.all
  end
end
