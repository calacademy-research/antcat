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

  def can_be_edited?
    old? || approved?
  end

  def last_change
    Change.joins(:paper_trail_version).where('versions.item_id = ? AND versions.item_type = ?', id, 'Taxon').first
  end

  def last_version
    # it seems to be necessary to reload the association and get its last element
    versions(true).last
  end

end
