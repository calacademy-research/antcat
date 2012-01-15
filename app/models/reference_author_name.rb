# coding: UTF-8
class ReferenceAuthorName < ActiveRecord::Base
  belongs_to :reference
  belongs_to :author_name
  acts_as_list scope: :reference
end
