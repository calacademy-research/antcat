class Journal < ActiveRecord::Base
  has_many :issues

  def self.import data, existing_journal = nil
    journal = find_or_create_by_title(data[:title])
    existing_journal.delete if existing_journal && journal != existing_journal && existing_journal.issues.count < 2
    journal
  end

  def import data
    self.class.import data, self
  end

  def self.search term
    search_expression = '%' + term.split('').join('%') + '%'
    all(:select => 'title', :conditions => ["title LIKE ?", search_expression], :order => :title).map(&:title)
  end

end
