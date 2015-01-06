# coding: UTF-8
class Change < ActiveRecord::Base
  include ActionView::Helpers::DateHelper
  belongs_to :approver, class_name: 'User'
  has_many :transactions
  has_many :paper_trail_versions, :through => :transactions
  belongs_to :taxon, :foreign_key => :user_changed_taxon_id


  # Joe, friday 1/2 - stopped here. Looks like transactions table is being updated
  #   All this show logic is geared around showing a single taxa, which is no longer
  # correct. It just needs to show itself - or maybe ALL taxa touched?

  scope :creations, -> {joins(:paper_trail_versions).
                        joins('JOIN taxa on taxa.id = versions.item_id').
                        order('CASE review_state ' +
                                'WHEN "waiting" THEN changes.created_at * 1000 ' +
                                'WHEN "approved" THEN changes.approved_at ' +
                              'END DESC'
                             )
                       }


  def reify
    # this dodgy code is from paper_trail_manager's changes_helper.rb
    #if(change_type==:add)
    first_version = paper_trail_versions.first
    current = first_version.next.try :reify
    previous = first_version.reify rescue nil
    begin
      first_version.item_type.constantize.find first_version.item_id
    rescue ActiveRecord::RecordNotFound
      previous || current
    end

  end


  def user
    first_version = paper_trail_versions.first

    user_id = first_version.whodunnit
    user_id ? User.find(user_id) : nil
  end

  # Joe todo: add chane type string restrictions?


end
