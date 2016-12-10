module TrackableActions::Create
  extend ActiveSupport::Concern

  included do
    after_create { create_activity :create }
  end
end
