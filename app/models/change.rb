class Change < ActiveRecord::Base
  include Feed::Trackable

  belongs_to :approver, class_name: 'User'
  # TODO rename to `taxon_id`.
  belongs_to :taxon, class_name: 'Taxon', foreign_key: 'user_changed_taxon_id'

  has_many :versions, class_name: 'PaperTrail::Version'

  scope :waiting, -> { joins_taxon_states.where("taxon_states.review_state = 'waiting'") }
  scope :joins_taxon_states, -> { joins('JOIN taxon_states ON taxon_states.taxon_id = changes.user_changed_taxon_id') }

  tracked

  def get_most_recent_valid_taxon
    return taxon if taxon

    version = get_most_recent_valid_taxon_version
    version.reify
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

  # TODO probably move `changed_by` to a field in this model.
  # Returns the user of the person who made the change. Expensive method.
  def changed_by
    whodunnit_via_change_id || whodunnit_via_user_changed_taxon_id
  end

  private
    def whodunnit_via_change_id
      version = PaperTrail::Version.where(change_id: id)
        .where.not(whodunnit: nil).first
      version.try :user
    end

    # Backwards compatibility, possibly covers other cases too.
    def whodunnit_via_user_changed_taxon_id
      version = PaperTrail::Version.where(item_id: user_changed_taxon_id)
        .where.not(whodunnit: nil).last
      version.try :user
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

    def get_user_versions change_id
      PaperTrail::Version.find_by_sql(<<-SQL.squish)
        SELECT * FROM versions WHERE change_id  = '#{change_id}'
      SQL
    end
end
