module TrackableActions::Update
  extend ActiveSupport::Concern

  included do
    after_update { create_activity :update }
  end
end
