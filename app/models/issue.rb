class Issue < ActiveRecord::Base
  belongs_to :journal

  def self.import data
    Issue.create!(
      :journal => Journal.import(data[:journal]),
      :series => data[:series],
      :volume => data[:volume],
      :issue => data[:issue])
  end
end
