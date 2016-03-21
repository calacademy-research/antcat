module Feed::Actions::Update
  extend ActiveSupport::Concern

  included do
    after_update do
      create_activity :update
    end
  end
end
