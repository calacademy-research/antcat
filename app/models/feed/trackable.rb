# Usage:
# In the model, include Feed::Trackable
# and add `tracked on: :all` (for :create, :update, :destroy)
# or `tracked on: [:create, :destroy]` for single hooks.
#
# To be added:
# Support for `parameters` (for eg saving the name of deleted objects)

module Feed::Trackable
  extend ActiveSupport::Concern

  module ClassMethods
    def tracked on: nil
      if on == :all
        include Feed::Actions::Create,
                Feed::Actions::Update,
                Feed::Actions::Destroy
      else
        Array.wrap(on).each do |action|
          include "Feed::Actions::#{action.capitalize}".constantize
        end
      end
    end
  end

  def create_activity action
    Feed::Activity.create_activity_for_trackable self, action
  end

end