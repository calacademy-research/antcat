class Journal < ActiveRecord::Base
  include ActiveModel::ForbiddenAttributesProtection
  include UndoTracker

  include Feed::Trackable
  tracked on: :all, parameters: ->(journal) do
    hash = { name: journal.name }
    hash[:name_was] = journal.name_was if journal.name_changed?
    hash
  end

  has_many :references
  validates :name, presence: true, allow_blank: false
  has_paper_trail meta: { change_id: :get_current_change_id }

  before_destroy :check_not_used

  def self.search term = ''
    search_expression = term.split('').join('%') + '%'
    select('journals.name, COUNT(*)')
        .joins('LEFT OUTER JOIN `references` ON references.journal_id = journals.id')
        .where('journals.name LIKE ?', search_expression)
        .group('journals.id')
        .order('COUNT(*) DESC')
        .map(&:name)
  end

  private
    def check_not_used
      if references.present?
        errors.add :base, "cannot delete journal (not unused)"
        return false
      end
    end
end
