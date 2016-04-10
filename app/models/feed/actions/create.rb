module Feed::Actions::Create
  extend ActiveSupport::Concern

  included do
    after_create do
      # FIX Currently required in tests.
      unless Rails.env.test? && !Feed::Activity.enabled?
        create_activity :create
      end
    end
  end
end
