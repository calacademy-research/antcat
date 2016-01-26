require_relative '../../../lib/workflow_external_table'
class Taxon < ActiveRecord::Base
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

  def can_be_reviewed_by? user
    $Milieu.user_can_review_changes?(user) && waiting?
  end

  def can_be_approved_by? change, user
    user != change.changed_by && waiting? && $Milieu.user_can_approve_changes?(user)
  end

  # Returns the ID of the most recent change that touches this taxon.
  # TODO: Fix these duplicates once the tests pass
  def last_change
    Change.joins(:versions).where('versions.item_id = ? AND versions.item_type = ?', id, 'Taxon' ).last
  end

  # Returns the ID of the most recent change that touches this taxon.
  # Query that looks at all transactions and picks the latest one
  # used for review change link
  def latest_change
    Change.joins(:versions).where('versions.item_id = ? AND versions.item_type = ?', id, 'Taxon').last
  end

  def last_version
    # it seems to be necessary to reload the association and get its last element
    versions(true).last
  end

end
