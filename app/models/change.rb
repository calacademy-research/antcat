class Change < ActiveRecord::Base
  belongs_to :approver, class_name: 'User'
  belongs_to :taxon, class_name: 'Taxon', foreign_key: 'user_changed_taxon_id'
  has_many :versions, class_name: 'PaperTrail::Version'

  scope :waiting, -> { joins_taxon_states.where("taxon_states.review_state = 'waiting'") }
  scope :joins_taxon_states, -> { joins('JOIN taxon_states ON taxon_states.taxon_id = changes.user_changed_taxon_id') }

  def get_most_recent_valid_taxon
    return taxon if taxon

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

    # This change didn't happen to touch taxon. Go ahead and search for the most recent
    # version of this taxon that has object information
    version = PaperTrail::Version.find_by_sql(<<-SQL.squish).first
      SELECT * FROM versions WHERE item_type = 'Taxon'
      AND object IS NOT NULL
      AND item_id = '#{user_changed_taxon_id}'
      ORDER BY id DESC
    SQL
    version
  end

  # Return the taxon associated with this change, or null if there isn't one.
  def most_recent_valid_taxon_version
    raise NotImplementedError
  end

  def user
    # If this looks for a "User" object in a test, check that you're writing
    # the id and not the user object in factorygirl.
    raise NotImplementedError

    user_id = get_user_versions(id).whodunnit
    user_id ? User.find(user_id) : nil
  end

  # TODO Expensive call; move to a field?
  # This is hit from the haml; it returns the user ID of
  # the person who made the change.
  def changed_by
    # Adding user qualifier partly because of tests (setup doesn't have a "user" logged in),
    # in any case, it remains correct, because all versions for a given change have the same
    # user. Also may cover historical cases?
    usered_versions = PaperTrail::Version.where(<<-SQL.squish)
      change_id = #{self.id} AND whodunnit IS NOT NULL
    SQL
    version = usered_versions.first
    return User.find(version.whodunnit.to_i) if version

    # backwards compatibility
    version = PaperTrail::Version.find_by_sql(<<-SQL.squish).first
      SELECT * FROM versions
      WHERE item_id = '#{user_changed_taxon_id}'
      AND whodunnit IS NOT NULL
      ORDER BY id DESC
    SQL
    user_id = version.whodunnit

    return User.find(user_id.to_i)
  end

  private
    def get_user_versions change_id
      PaperTrail::Version.find_by_sql(<<-SQL.squish)
        SELECT * FROM versions WHERE change_id  = '#{change_id}'
      SQL
    end
end
