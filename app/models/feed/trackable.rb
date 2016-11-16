# Usage:
# In the model, include Feed::Trackable and add:
#
# `tracked on: :all` (for :create, :update, :destroy)
# `tracked on: [:create, :destroy]` (for those hooks)
# `tracked` (no hooks, but mixes in #create_activity)
#
# To save additional parameters:
# `tracked on: :all,
#   parameters: ->(journal) do { name: journal.name } end`

module Feed::Trackable
  extend ActiveSupport::Concern

  # TODO investigate using an instance variable instead so
  # `tracked on: :all, parameters: ->(task) do { title: task.title } end`
  #  would become
  # `tracked on: :all, parameters: -> do { title: self.title } end`
  included do
    class_attribute :activity_parameters
  end

  module ClassMethods
    def tracked on: nil, parameters: Proc.new {}
      self.activity_parameters = parameters

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

  def create_activity action, parameters = activity_parameters.call(self)
    Feed::Activity.create_activity_for_trackable self, action, parameters
  end
end
