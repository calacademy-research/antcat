class Journal < ActiveRecord::Base
  def self.import title
    return unless title.present?
    find_or_create_by_title title
  end

  def self.search term = ''
    search_expression = term.split('').join('%') + '%'

    all(:select => 'journals.title, COUNT(*)',
        :joins => 'LEFT OUTER JOIN `references` ON references.journal_id = journals.id',
        :conditions => ['journals.title LIKE ?', search_expression],
        :group => 'journals.id',
        :order => 'COUNT(*) DESC').map(&:title)
  end

end
