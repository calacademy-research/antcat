# coding: UTF-8
class Change < ActiveRecord::Base
  include ActionView::Helpers::DateHelper
  belongs_to :paper_trail_version, class_name: 'Version'
  belongs_to :approver, class_name: 'User'
  delegate :whodunnit, to: :paper_trail_version

  scope :creations, -> {joins(:paper_trail_version).
                        where('versions.event' => 'create').
                        order('updated_at DESC')}

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

  def taxon
    return unless paper_trail_version
    Taxon.find paper_trail_version.item_id
  end

  def user
    user_id = paper_trail_version.whodunnit
    user_id ? User.find(user_id) : nil
  end

end
