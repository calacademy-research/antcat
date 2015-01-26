# coding: UTF-8
class Change < ActiveRecord::Base
  include ActionView::Helpers::DateHelper
  belongs_to :approver, class_name: 'User'
  has_many :transactions
  has_many :paper_trail_versions, :through => :transactions
  belongs_to :taxon, :foreign_key => :user_changed_taxon_id
  attr_accessible :approver_id, :approved_at, :paper_trail_versions, :paper_trail_version


  scope :creations, -> {joins(:paper_trail_versions).
                        joins('JOIN taxa on taxa.id = versions.item_id').
                        order('CASE review_state ' +
                                'WHEN "waiting" THEN changes.created_at * 1000 ' +
                                'WHEN "approved" THEN changes.approved_at ' +
                              'END DESC'
                             )
                       }


  def get_user_version
    PaperTrail::Version.find_by_sql("select * from versions,changes, transactions
        where changes.user_changed_taxon_id = versions.item_id AND
        transactions.change_id = changes.id  AND
        transactions.paper_trail_version_id = versions.id AND
        changes.id = '"+id.to_s+"'").first
  end

  def reify

    # Pulls only the change attached to the taxon that the user actually edited.
    # We used this for display. This is done to avoid refactoring all the display code.
    user_version = get_user_version


    current = user_version.next.try :reify
    previous = user_version.reify rescue nil
    begin
      user_version.item_type.constantize.find user_version.item_id
    rescue ActiveRecord::RecordNotFound
      previous || current
    end

  end


  def user
    user_id =  get_user_version.whodunnit
    user_id ? User.find(user_id) : nil
  end



end
