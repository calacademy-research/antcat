class Transaction  < ActiveRecord::Base
  belongs_to :paper_trail_version, class_name: PaperTrail::Version
  belongs_to :change

  scope :find_all_by_change_id, lambda {|change_id| where change_id: change_id}
end