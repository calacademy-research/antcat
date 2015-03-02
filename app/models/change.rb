# coding: UTF-8
class Change < ActiveRecord::Base
  include ActionView::Helpers::DateHelper
  belongs_to :approver, class_name: 'User'
  has_many :transactions
  has_many :paper_trail_versions, :through => :transactions
  belongs_to :taxon, :foreign_key => :user_changed_taxon_id
  attr_accessible :approver_id,
                  :approved_at,
                  :paper_trail_versions,
                  :paper_trail_version,
                  :approver

  #  self.joins(:paper_trail_versions).
  #     joins('JOIN taxon_states on taxon_states.taxon_id = versions.item_id').
  #     order('CASE review_state ' +
  #               'WHEN "waiting" THEN changes.created_at * 1000 ' +
  #               'WHEN "approved" THEN changes.approved_at ' +
  #               'END DESC').uniq


  def self.creations
    # self.joins(:paper_trail_versions).
    #          joins('JOIN taxon_states on taxon_states.taxon_id = versions.item_id').
    #          order('CASE review_state ' +
    #                    'WHEN "waiting" THEN changes.created_at * 1000 ' +
    #                    'WHEN "approved" THEN changes.approved_at ' +
    #                    'END DESC').uniq


    self.joins('JOIN taxon_states on taxon_states.taxon_id = changes.user_changed_taxon_id').
        order('CASE review_state ' +
                  'WHEN "waiting" THEN changes.created_at * 1000 ' +
                  'WHEN "approved" THEN changes.approved_at ' +
                  'END DESC').uniq

  end


  def get_user_version change_id
    # PaperTrail::Version.find_by_sql("select * from versions,changes, transactions
    #     where changes.user_changed_taxon_id = versions.item_id AND
    #     transactions.change_id = changes.id  AND
    #     transactions.paper_trail_version_id = versions.id AND
    #     changes.id = '"+change_id.to_s+"'").first


    # PaperTrail::Version.find_by_sql("select * from versions
    #   join changes on  changes.user_changed_taxon_id = versions.item_id and changes.id = '"+change_id.to_s+"'
    #   join transactions on transactions.change_id = changes.id  AND  transactions.paper_trail_version_id = versions.id").first



    PaperTrail::Version.find_by_sql("select * from versions
      join changes on  changes.user_changed_taxon_id = versions.item_id and changes.id = '"+change_id.to_s+" order by version.id desc'").first

  end

  def get_most_recent_valid_taxon_version taxon_id
    #Change.where(user_changed_taxon_id: taxon_id).order(id: :desc)
    PaperTrail::Version.find_by_sql("select * from versions where item_type = 'Taxon'
      and object is not null
      and item_id = '"+taxon_id.to_s+"'
      order by id desc").first
  end

  #
  # Return the most recent valid taxon.
  # Covers the "delete" case where we reify to null if we step back through the change set until we
  # find something valid.
  #
  def most_recent_valid_taxon


    taxon_id = self.user_changed_taxon_id
    begin
      # just pull the damn taxon, if it's present!

      valid_taxon = Taxon.find(taxon_id)
      return valid_taxon
    rescue ActiveRecord::RecordNotFound
    end
    get_most_recent_valid_taxon_version(taxon_id).reify

    # taxon_change_list = get_list_of_changes_most_recent_first_for taxon_id
    # taxon_change_list.each do |cur_change_id|
    #   valid_taxon = reify_change cur_change_id.id
    #   unless valid_taxon.nil?
    #     return valid_taxon
    #   end
    # end
    # nil

  end


  # Called from the view and from the popup.
  # returns a taxon (When you reify a paper trail version object, you get the object in question)
  def reify

    # Pulls only the change attached to the taxon that the user actually edited.
    # We used this for display. This is done to avoid refactoring all the display code.
    reify_change self.id
  end

  def reify_change change_id
    puts "About to load user version"
    user_version = get_user_version change_id
    puts "user version loaded"

    current = user_version.next.try :reify
    previous = user_version.reify rescue nil


    begin
      user_version.item_type.constantize.find user_version.item_id
    rescue ActiveRecord::RecordNotFound
      previous || current
    end
  end


  def user
    # is this looks for a "User" object in a test, check that you're writing the id and not the user object
    # in factorygirl.
    user_id = get_user_version(id).whodunnit
    user_id ? User.find(user_id) : nil
  end


end
