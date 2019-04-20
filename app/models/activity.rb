# TODO move `user` to controllers.
#
# NOTE "automated edits" are currently simply activities with `automated_edits`
# set to true and `user` set to a user named "AntCatBot" (`User.find 62`).

class Activity < ApplicationRecord
  include FilterableWhere

  EDIT_SUMMARY_MAX_LENGTH = 255
  ACTIONS = %w[
    create
    update
    destroy

    approve_all_changes
    approve_all_references
    approve_change
    close_feedback
    close_issue
    convert_species_to_subspecies
    create_obsolete_combination
    custom
    elevate_subspecies_to_species
    execute_script
    finish_reviewing
    force_parent_change
    merge_authors
    move_items
    reopen_feedback
    reopen_issue
    reorder_taxon_history_items
    restart_reviewing
    start_reviewing
    undo_change
  ]

  self.per_page = 30 # For `will_paginate`.

  belongs_to :trackable, polymorphic: true
  belongs_to :user

  validates :action, presence: true, inclusion: { in: ACTIONS }

  scope :ids_desc, -> { order(id: :desc) }
  scope :most_recent, ->(number = 5) { ids_desc.limit(number).include_associations }
  scope :include_associations, -> { includes(:trackable, :user) }
  scope :non_automated_edits, -> { where(automated_edit: false) }

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

  # :nocov:
  # For calling from the console.
  def self.execute_script_activity user, edit_summary
    raise "You must assign a user." unless user
    raise "You must include an edit summary." unless edit_summary
    create! trackable: nil, action: :execute_script, user: user, edit_summary: edit_summary
  end
  # :nocov:

  def pagination_page activities
    index = activities.where("id > ?", id).count
    per_page = self.class.per_page
    (index + per_page) / per_page
  end
end
