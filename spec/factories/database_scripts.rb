class DatabaseTestScript
  include DatabaseScripts::DatabaseScript

  def results
    Reference.all
  end
end
