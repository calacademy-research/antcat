class Journal < ActiveRecord::Base
  include ActiveModel::ForbiddenAttributesProtection
  include Trackable

  has_many :references

  validates :name, presence: true, allow_blank: false

  before_destroy :check_not_used

  has_paper_trail meta: { change_id: proc { UndoTracker.get_current_change_id } }
  tracked on: :all, parameters: proc {
    { name: name, name_was: (name_was if name_changed?) }
  }

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
