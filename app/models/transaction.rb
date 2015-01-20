class Transaction  < ActiveRecord::Base
  belongs_to :paper_trail_version, class_name: 'Version'
  belongs_to :change
end