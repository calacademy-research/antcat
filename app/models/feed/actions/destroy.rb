module Feed::Actions::Destroy
  extend ActiveSupport::Concern

  included do
    after_destroy do
      # FIX Currently required in tests.
      unless Rails.env.test? && !Feed::Activity.enabled?
        create_activity :destroy
      end
    end
  end
end
