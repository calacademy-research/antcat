# coding: UTF-8
class Bolton::Match < ActiveRecord::Base
  self.table_name = :bolton_matches
  belongs_to :reference, class_name: '::Reference'
  belongs_to :bolton_reference, class_name: 'Bolton::Reference'
  attr_accessible :bolton_reference, :reference, :similarity
end
