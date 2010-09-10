class Issue < ActiveRecord::Base
  belongs_to :journal
  has_many :articles

  def self.import data, existing_issue = nil
    existing_journal = existing_issue ? existing_issue.journal : nil
    new_journal = Journal.import(data[:journal], existing_journal)
    new_issue = Issue.find_or_create_by_journal_id_and_series_and_volume_and_issue(
      :journal => new_journal, :series => data[:series], :volume => data[:volume], :issue => data[:issue])
    existing_issue.delete if existing_issue && new_issue != existing_issue && existing_issue.articles.count < 2
    new_issue
  end

  def import data
    self.class.import data, self
  end
end
