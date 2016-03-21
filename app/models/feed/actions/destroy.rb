module Feed::Actions::Destroy
  extend ActiveSupport::Concern

  included do
    after_destroy do
      create_activity :destroy
    end
  end
end
