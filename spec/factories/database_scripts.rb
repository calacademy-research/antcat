class DatabaseTestScript < DatabaseScript
  def results
    Reference.all
  end
end
