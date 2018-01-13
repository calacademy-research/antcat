class Taxon < ApplicationRecord
  include Workflow
  include Workflow::ExternalTable

  has_one :taxon_state

  workflow do
    state :old
    state :waiting do
      event :approve, transitions_to: :approved
    end
    state :approved
  end

  delegate :approver, :approved_at, to: :last_change

  def can_be_reviewed?
    waiting?
  end

  # Allow optional `changed_by` for performance reasons.
  def can_be_approved_by? change, user, changed_by = nil
    return unless user && change
    return unless waiting? && user.can_review_changes?

    changed_by ||= change.changed_by
    user != changed_by
  end

  # Returns the most recent change that touches this taxon.
  def last_change
    Change.joins(:versions).where("versions.item_id = ? AND versions.item_type = 'Taxon'", id).last
  end

  def last_version
    versions.reload.last
  end
end
