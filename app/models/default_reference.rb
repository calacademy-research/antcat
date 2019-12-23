class DefaultReference
  def self.get session
    Reference.find_by(id: session[:default_reference_id])
  end

  def self.set session, reference
    session[:default_reference_id] = reference.id
  end
end
