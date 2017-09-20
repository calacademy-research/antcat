# TODO validate `action` to `Activity.uniq.pluck(:action)`. Something like:
# ```
# ACTIONS = [:destroy, :update, :create, :approve_change ... ]
# validates :action, presence: true, inclusion: { in: ACTIONS }
# ```
#
# TODO move `user` to controllers.
#
# NOTE "automated edits" are currently simply activities with `automated_edits`
# set to true and `user` set to a user named "AntCatBot" (`User.find 62`).

class Activity < ActiveRecord::Base
  include ActiveModel::ForbiddenAttributesProtection
  include FilterableWhere

  EDIT_SUMMARY_MAX_LENGTH = 255

  self.per_page = 30 # For `will_paginate`.

  belongs_to :trackable, polymorphic: true
  belongs_to :user

  scope :ids_desc, -> { order(id: :desc) }
  scope :most_recent, ->(number = 5) { ids_desc.limit(number).include_associations }
  scope :include_associations, -> { includes(:trackable, :user) }

  has_paper_trail
  serialize :parameters, Hash

  def self.create_for_trackable trackable, action, edit_summary: nil, parameters: {}
    return unless Feed.enabled?

    create! trackable: trackable, action: action,
      user: User.current, edit_summary: edit_summary,
      parameters: parameters
  end

  def self.create_without_trackable action, edit_summary: nil, parameters: {}
    create_for_trackable nil, action, edit_summary: edit_summary, parameters: parameters
  end

  def pagination_page
    index = Activity.ids_desc.pluck(:id).index(id)
    per_page = self.class.per_page
    (index + per_page) / per_page
  end
end
