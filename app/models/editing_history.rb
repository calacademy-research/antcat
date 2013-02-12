# coding: UTF-8
class EditingHistory < ActiveRecord::Base
  self.table_name = 'editing_history'
  belongs_to :user; validates :user, presence: true
  belongs_to :taxon
end
