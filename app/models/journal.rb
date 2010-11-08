class Journal < ActiveRecord::Base

  validates_presence_of :name

  def self.import name
    return unless name.present?
    find_or_create_by_name name
  end

  def self.search term = ''
    search_expression = term.split('').join('%') + '%'

    all(:select => 'journals.name, COUNT(*)',
        :joins => 'LEFT OUTER JOIN `references` ON references.journal_id = journals.id',
        :conditions => ['journals.name LIKE ?', search_expression],
        :group => 'journals.id',
        :order => 'COUNT(*) DESC').map(&:name)
  end

end
