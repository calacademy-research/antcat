# coding: UTF-8
class Change < ActiveRecord::Base
  include ActionView::Helpers::DateHelper
  belongs_to :approver, class_name: 'User'
  has_many :versions, class_name: 'PaperTrail::Version'
  attr_accessible :approver_id,
                  :approved_at,
                  :versions,
                  :version,
                  :approver

  def self.creations
    self.joins('JOIN taxon_states on taxon_states.taxon_id = changes.user_changed_taxon_id').
        order('CASE review_state ' +
                  'WHEN "waiting" THEN changes.created_at * 1000 ' +
                  'WHEN "approved" THEN changes.approved_at ' +
                  'END DESC').uniq
  end

  def get_user_versions change_id
    PaperTrail::Version.find_by_sql("select * from versions where change_id  = '"+change_id.to_s+"'")
  end

  def taxon
    begin
      Taxon.find(user_changed_taxon_id)
    rescue ActiveRecord::RecordNotFound
      nil
    end

  end

  def get_most_recent_valid_taxon
    unless taxon.nil?
      return taxon
    end

    version = get_most_recent_valid_taxon_version
    version.reify
  end


  # Deletes don't store any object info, so you can't show what it used to look like.
  # used to pull an example of the way it once was.
  def get_most_recent_valid_taxon_version
    # "Destroy" events don't have populated data fields.
    versions.each do |version|
      if version.item_type == 'Taxon' && !version.object.nil? && 'destroy' != version.event
        return version
      end
    end

    # version = PaperTrail::Version.find_by_sql("select * from versions where item_type = 'Taxon'
    #   and object is not null
    #   and versions.event <> 'destroy'
    #   and item_id = '"+user_changed_taxon_id.to_s+"'
    #   order by id desc").first


    # This change didn't happen to touch taxon. Go ahead and search for the most recent
    # version of this taxon that has object information
    version = PaperTrail::Version.find_by_sql("select * from versions where item_type = 'Taxon'
      and object is not null
      and item_id = '"+user_changed_taxon_id.to_s+"'
      order by id desc").first
    version
  end

  #
  # return the taxon associated with this change, or null if there isn't one.
  #
  def most_recent_valid_taxon_version
    raise NotImplementedError
  end


  def user
    # is this looks for a "User" object in a test, check that you're writing the id and not the user object
    # in factorygirl.
    raise NotImplementedError

    user_id = get_user_versions(id).whodunnit
    user_id ? User.find(user_id) : nil
  end

  #
  # This is hit from the haml; it returns the user ID of
  # the person who made the change.
  #
  def changed_by
    # adding user qualifier partly because of tests (setup doesn't have a "user" logged in),
    # in any case, it remains correct, because all versions for a given change have the same
    # user. Also may cover historical cases?
    #usered_versions = PaperTrail::Version.where(change_id: self.id, whodunnit: !nil)
    usered_versions = PaperTrail::Version.where("change_id = #{self.id} and whodunnit is not null")



    version = usered_versions.first
    unless version.nil?
      return User.find(version.whodunnit.to_i)
    end


    # backwards compatibility
    version = PaperTrail::Version.find_by_sql("select * from versions
      where item_id = '"+user_changed_taxon_id.to_s+"'and whodunnit is not null
      order by id desc").first
    user_id = version.whodunnit

    return User.find(user_id.to_i)


  end


end
