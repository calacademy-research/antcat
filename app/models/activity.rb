# TODO move `user` to controllers.
#
# NOTE "automated edits" are currently simply activities with `automated_edits`
# set to true and `user` set to a user named "AntCatBot" (`User.find 62`).

class Activity < ActiveRecord::Base
  include ActiveModel::ForbiddenAttributesProtection
  include FilterableWhere

  EDIT_SUMMARY_MAX_LENGTH = 255
  ACTIONS = %w(
    create
    update
    destroy

    approve_all_changes
    approve_all_references
    approve_change
    close_feedback
    close_issue
    convert_species_to_subspecies
    custom
    elevate_subspecies_to_species
    execute_script
    finish_reviewing
    merge_authors
    reopen_feedback
    reopen_issue
    reorder_taxon_history_items
    replace_missing_reference
    restart_reviewing
    start_reviewing
    undo_change
  )

  self.per_page = 30 # For `will_paginate`.

  belongs_to :trackable, polymorphic: true
  belongs_to :user

  validates :action, inclusion: { in: ACTIONS, allow_nil: true } # TODO do not allow nil.

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
