# coding: UTF-8
class Taxon < ActiveRecord::Base
  include Workflow
  #workflow_column :review_state
  has_one :taxon_state


  workflow do
    state :old
    state :waiting do
      event :approve, transitions_to: :approved
    end
    state :approved
  end

  delegate :approver, :approved_at, to: :last_change


  def load_workflow_state
    @workflow_state = taxon_state.review_state
  end

  def persist_workflow_state(new_value)
    @workflow_state = new_value
    taxon_state.review_state = new_value
    taxon_state.save!

  end

  def can_be_edited_by? user
    return false unless $Milieu.user_can_edit?(user)
    return true if old?
    return true if approved?
    raise unless waiting?
    true
  end

  def can_be_reviewed_by? user
    $Milieu.user_can_review_changes?(user) && waiting?
  end

  def can_be_approved_by? user
    user != added_by && waiting? && $Milieu.user_can_approve_changes?(user)
  end

  # Returns the ID of the most recent change that touches this taxon.
  # Query that looks at all transactions and picks the latest one that has this
  # change ID.
  def last_change
    Change.joins(:paper_trail_versions).where('versions.item_id = ? AND versions.item_type = ?', id, 'Taxon').first
  end

  def last_version
    # it seems to be necessary to reload the association and get its last element
    versions(true).last
  end

  def added_by
    last_change.user
  end

end
