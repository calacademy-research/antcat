module Feed::Actions::Create
  extend ActiveSupport::Concern

  included do
    after_create do
      create_activity :create
    end
  end
end
