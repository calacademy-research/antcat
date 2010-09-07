class Issue < ActiveRecord::Base
  belongs_to :journal

  def self.import data
    journal = Journal.import(data[:journal])
    Issue.find_or_create_by_journal_id_and_series_and_volume_and_issue(
      journal.id, data[:series], data[:volume], data[:issue])
  end
end
