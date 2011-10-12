# coding: UTF-8
class Text < ActiveRecord::Base
  has_and_belongs_to_many :references
end
