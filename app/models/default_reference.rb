# TODO namespace under `References`.

class DefaultReference
  def self.get session
    Reference.find session[:default_reference_id] rescue nil
  end

  def self.set session, reference
    session[:default_reference_id] = reference.id
  end
end
