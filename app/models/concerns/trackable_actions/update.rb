module TrackableActions::Update
  extend ActiveSupport::Concern

  included do
    after_update do
      # FIX Currently required in tests.
      unless Rails.env.test? && !Feed.enabled?
        create_activity :update
      end
    end
  end
end
