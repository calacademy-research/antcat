# coding: UTF-8
class Bolton::Match < ActiveRecord::Base
  set_table_name :bolton_matches
  belongs_to :reference, :class_name => '::Reference'
  belongs_to :bolton_reference, :class_name => 'Bolton:Reference'
end
