class Ward::Reference < ActiveRecord::Base
  belongs_to :reference
  set_table_name :ward_references
end
