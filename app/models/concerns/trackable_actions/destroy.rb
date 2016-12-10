module TrackableActions::Destroy
  extend ActiveSupport::Concern

  included do
    after_destroy { create_activity :destroy }
  end
end
