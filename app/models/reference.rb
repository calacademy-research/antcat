class Reference < ActiveRecord::Base
  set_table_name 'refs'
  attr_accessible :authors, :year, :title, :citation, :notes, :possess, :date, :excel_file_name, :created_at, :updated_at, :cite_code
end
