# frozen_string_literal: true

module References
  class DefaultReference
    DEFAULT_REFERENCE_SESSION_KEY = :default_reference_id

    class << self
      def get session
        Reference.find_by(id: session[DEFAULT_REFERENCE_SESSION_KEY])
      end

      def set session, reference
        session[DEFAULT_REFERENCE_SESSION_KEY] = reference.id
      end
    end
  end
end
