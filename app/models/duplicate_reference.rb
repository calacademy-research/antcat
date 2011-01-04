class DuplicateReference < ActiveRecord::Base
  belongs_to :reference
  belongs_to :duplicate, :class_name => 'Reference'
end
