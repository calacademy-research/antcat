class Taxon < ApplicationRecord
  include Workflow
  include Workflow::ExternalTable

  has_one :taxon_state

  workflow do
    state TaxonState::OLD
    state TaxonState::WAITING do
      event :approve, transitions_to: TaxonState::APPROVED
    end
    state TaxonState::APPROVED
  end

  delegate :approver, :approved_at, to: :last_change

  def can_be_reviewed?
    waiting?
  end

  def can_be_approved_by? change, user
    return false unless user && change
    return false unless waiting? && user.is_editor?

    user != change.changed_by
  end

  def last_change
    Change.joins(:versions).where("versions.item_id = ? AND versions.item_type = 'Taxon'", id).last
  end
end
