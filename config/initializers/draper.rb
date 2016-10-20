module Draper
  class HelperProxy
    # Makes it possible to call eg `helpers.reference_path(reference)` in decorators.
    include Rails.application.routes.url_helpers
  end
end
