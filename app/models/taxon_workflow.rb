# coding: UTF-8
class Taxon < ActiveRecord::Base
  include Workflow
  workflow_column :review_state

  workflow do
    state :old
    state :waiting do
      event :approve, transitions_to: :approved
    end
    state :approved
  end

  delegate :approver, :approved_at, to: :last_change

  def can_be_edited_by? user
    return false unless $Milieu.user_can_edit_catalog?(user)
    return true if old?
    return true if approved?
    raise unless waiting?
    last_editor == user
  end

  def can_be_reviewed_by? user
    $Milieu.user_can_review_changes?(user) && waiting?
  end

  def can_be_approved_by? user
    $Milieu.user_can_approve_changes?(user) && waiting?
  end

  def last_change
    Change.joins(:paper_trail_version).where('versions.item_id = ? AND versions.item_type = ?', id, 'Taxon').first
  end

  def last_version
    # it seems to be necessary to reload the association and get its last element
    versions(true).last
  end

  def last_editor
    last_editor_id = last_version.try :whodunnit
    User.find(last_editor_id) rescue nil
  end

end
