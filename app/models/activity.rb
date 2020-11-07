# frozen_string_literal: true

# NOTE: "automated edits" are currently simply activities with `automated_edits`
# set to true and `user` set to a user named "AntCatBot" (`User.find 62`).

class Activity < ApplicationRecord
  include SetRequestUuid

  EDIT_SUMMARY_MAX_LENGTH = 255
  ACTIONS_BY_GROUP = {
    default: [
      CREATE = 'create',
      UPDATE = 'update',
      DESTROY = 'destroy'
    ],
    custom: [
      APPROVE_ALL_REFERENCES =        'approve_all_references',
      CLOSE_FEEDBACK =                'close_feedback',
      CLOSE_ISSUE =                   'close_issue',
      CONVERT_SPECIES_TO_SUBSPECIES = 'convert_species_to_subspecies',
      CREATE_NEW_COMBINATION =        'create_new_combination',
      CREATE_OBSOLETE_COMBINATION =   'create_obsolete_combination',
      ELEVATE_SUBSPECIES_TO_SPECIES = 'elevate_subspecies_to_species',
      EXECUTE_SCRIPT =                'execute_script',
      FINISH_REVIEWING =              'finish_reviewing',
      FORCE_PARENT_CHANGE =           'force_parent_change',
      MERGE_AUTHORS =                 'merge_authors',
      MOVE_ITEMS =                    'move_items',
      MOVE_PROTONYM_ITEMS =           'move_protonym_items',
      REOPEN_FEEDBACK =               'reopen_feedback',
      REOPEN_ISSUE =                  'reopen_issue',
      REORDER_REFERENCE_SECTIONS =    'reorder_reference_sections',
      REORDER_HISTORY_ITEMS =         'reorder_history_items',
      RESTART_REVIEWING =             'restart_reviewing',
      SET_SUBGENUS =                  'set_subgenus',
      START_REVIEWING =               'start_reviewing'
    ],
    deprecated: [
      REORDER_TAXON_HISTORY_ITEMS = 'reorder_taxon_history_items'
    ]
  }
  ACTIONS = ACTIONS_BY_GROUP.values.flatten
  OPTIONAL_USER_TRACKABLE_TYPES = %w[Feedback User]

  self.per_page = 30 # For `will_paginate`.

  belongs_to :trackable, polymorphic: true, optional: true
  belongs_to :user, optional: true # NOTE: Only optional for a few actions.

  validates :action, inclusion: { in: ACTIONS }
  validates :user, presence: true, unless: -> { trackable_type.in?(OPTIONAL_USER_TRACKABLE_TYPES) }

  scope :filter_where, ->(filter_params) do
    results = where(nil)
    filter_params.each do |key, value|
      results = results.where(key => value) if value.present?
    end
    results
  end
  scope :most_recent_first, -> { order(id: :desc) }
  scope :non_automated_edits, -> { where(automated_edit: false) }
  scope :unconfirmed, -> { joins(:user).merge(User.unconfirmed) }
  scope :wiki_page_activities, -> { where(trackable_type: 'WikiPage') }
  scope :issue_activities, -> { where(trackable_type: 'Issue') }

  has_paper_trail
  serialize :parameters, Hash
  strip_attributes only: [:edit_summary], replace_newlines: true

  class << self
    def create_for_trackable trackable, action, user:, edit_summary: nil, parameters: {}
      create!(
        trackable: trackable,
        action: action,
        user: user,
        edit_summary: edit_summary,
        parameters: parameters
      )
    end

    def create_without_trackable action, user, edit_summary: nil, parameters: {}
      create_for_trackable nil, action, user: user, edit_summary: edit_summary, parameters: parameters
    end

    # :nocov:
    # For calling from the console.
    def execute_script_activity user, edit_summary
      raise "You must assign a user." unless user
      raise "You must include an edit summary." unless edit_summary
      create!(trackable: nil, action: Activity::EXECUTE_SCRIPT, user: user, edit_summary: edit_summary)
    end
    # :nocov:
  end

  def pagination_page activities
    index = activities.where("id > ?", id).count
    per_page = self.class.per_page
    (index + per_page) / per_page
  end
end
