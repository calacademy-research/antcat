# frozen_string_literal: true

class DefaultReference
  DEFAULT_REFERENCE_SESSION_KEY = :default_reference_id

  def self.get session
    Reference.find_by(id: session[DEFAULT_REFERENCE_SESSION_KEY])
  end

  def self.set session, reference
    session[DEFAULT_REFERENCE_SESSION_KEY] = reference.id
  end
end
