class Change < ApplicationRecord
  include Trackable

  belongs_to :approver, class_name: 'User'
  belongs_to :taxon, class_name: 'Taxon'
  belongs_to :user

  has_many :versions, class_name: 'PaperTrail::Version'

  validates :user, presence: true, on: :create

  scope :includes_associated, -> { includes(:user, :approver, taxon: [:name, :taxon_state]) }
  scope :waiting, -> { joins_taxon_states.merge(TaxonState.waiting) }
  scope :joins_taxon_states, -> { joins('JOIN taxon_states ON taxon_states.taxon_id = changes.taxon_id') }

  trackable

  def self.approve_all user
    count = TaxonState.waiting.count

    TaxonState.waiting.each do |taxon_state|
      # TODO maybe something like `TaxonState#approve_related_changes`?
      Change.where(taxon: taxon_state.taxon).find_each do |change|
        change.approve user
      end
    end

    Activity.create_without_trackable :approve_all_changes, parameters: { count: count }
  end

  def approve user = nil
    taxon_state = TaxonState.find_by(taxon: taxon)
    return if taxon_state.review_state == TaxonState::APPROVED

    if taxon
      taxon.approve!
      update! approver: user, approved_at: Time.current
    else
      # This case is for approving a delete
      # TODO? approving deletions doesn't set `approver` or `approved_at`.
      taxon_state.review_state = TaxonState::APPROVED
      taxon_state.save!
    end

    create_activity :approve_change
  end

  def undo
    UndoTracker.clear_change
    change_id_set = find_future_changes
    versions = SortedSet[]

    Taxon.transaction do
      change_id_set.each do |undo_this_change_id|
        # Could be already undone.
        current_change = Change.find_by(id: undo_this_change_id)
        next unless current_change

        versions.merge current_change.versions
        current_change.delete
      end
      undo_versions versions
    end
  end

  # TODO return as ActiveRecord instead of hash.
  def undo_items
    changes = []
    change_id_set = find_future_changes
    change_id_set.each do |current_change_id|
      # Could be already undone.
      current_change = Change.find_by(id: current_change_id)
      next unless current_change

      current_taxon = current_change.most_recent_valid_taxon
      changes << { taxon: current_taxon,
                   change_type: current_change.change_type,
                   date: current_change.created_at.strftime("%B %d, %Y"),
                   user: current_change.changed_by }

      # This would be a good place to warn from if we find that we can't undo
      # something about a taxa.
    end

    changes
  end

  def most_recent_valid_taxon
    return taxon if taxon

    version = most_recent_valid_taxon_version
    version.reify
  end

  def changed_by
    user || whodunnit_via_change_id
  end

  private

    # Backwards compatibility for changes created before `changes.user_id` was added.
    def whodunnit_via_change_id
      version = versions.where.not(whodunnit: nil).first
      version&.user
    # TODO: There are two deleted users with associated versions:
    # `PaperTrail::Version.where.not(whodunnit: User.select(:id)).distinct.pluck(:whodunnit)` # ["55", "59"]
    rescue ActiveRecord::RecordNotFound
      nil
    end

    def most_recent_valid_taxon_version
      version = versions.where(item_type: "Taxon").where.not(object: nil, event: "destroy").first
      return version if version

      version = PaperTrail::Version.find_by_sql(<<-SQL.squish).first
        SELECT * FROM versions WHERE item_type = 'Taxon'
        AND object IS NOT NULL
        AND item_id = '#{taxon_id}'
        ORDER BY id DESC
      SQL
      version
    end

    def undo_versions versions
      versions.reverse_each do |version|
        if version.event == 'create'
          undo_create_event_version version
        else
          undo_delete_event_version version
        end
      end
    end

    def undo_create_event_version version
      klass = version.item_type.constantize
      item = klass.find version.item_id
      item.delete
    end

    def undo_delete_event_version version
      item = version.reify
      unless item
        raise "failed to reify version: #{version.id} referencing change: #{version.change_id}"
      end

      # NOTE may raise `ActiveRecord::RecordInvalid`.
      item.save! validate: false if item
    end

    def get_future_change_ids version
      new_version = version.next
      change_id = version.change_id
      return SortedSet[] unless change_id

      if new_version
        SortedSet[change_id].merge get_future_change_ids(new_version)
      else
        SortedSet[change_id]
      end
    end

    def find_future_changes
      change_ids = SortedSet[id]
      versions.each { |version| change_ids.merge get_future_change_ids(version) }
      change_ids
    end
end
