# Usage:
# In the model, include `Trackable` and call:
# `tracked on: :all`                        for :create, :update, :destroy
# `tracked on: [:create, :destroy]`         for those hooks
# `tracked on: :mixin_create_activity_only` no hooks
#
# To save additional parameters:
# `tracked on: :all, parameters: proc { { name: name } }`

module Trackable
  extend ActiveSupport::Concern

  included do
    class_attribute :activity_parameters
  end

  module ClassMethods
    def tracked on:, parameters: Proc.new {}
      self.activity_parameters = parameters

      case on
      when :all
        include TrackableActions::Create,
                TrackableActions::Update,
                TrackableActions::Destroy
      when :mixin_create_activity_only
        # Was mixed-in when module was included,
        # but this makes the code easier to understand.
      else
        Array.wrap(on).each do |action|
          include "TrackableActions::#{action.capitalize}".constantize
        end
      end
    end
  end

  def create_activity action, parameters = nil
    # HACK to make specs pass, because `Taxon` and `SpeciesGroupTaxon`
    # don't implement `#parent` which raises `NameError`.
    return unless Feed.enabled?

    parameters ||= instance_eval &activity_parameters
    Activity.create_for_trackable self, action, parameters
  end
end
