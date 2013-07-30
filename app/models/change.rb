# coding: UTF-8
class Change < ActiveRecord::Base
  include ActionView::Helpers::DateHelper
  belongs_to :paper_trail_version, class_name: 'Version'

  delegate :whodunnit, to: :paper_trail_version

  def reify
    # this dodgy code is from paper_trail_manager's changes_helper.rb
    current = paper_trail_version.next.try :reify
    previous = paper_trail_version.reify rescue nil
    begin
      paper_trail_version.item_type.constantize.find paper_trail_version.item_id
    rescue ActiveRecord::RecordNotFound
      previous || current
    end
  end

  scope :creations, -> {joins(:paper_trail_version).
                        where('versions.event' => 'create').
                        order('created_at DESC')}

  def taxon
    return unless paper_trail_version
    Taxon.find paper_trail_version.item_id
  end
end
