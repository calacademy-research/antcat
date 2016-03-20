class TaskReference < ActiveRecord::Base
  belongs_to :taxon
  belongs_to :task
end
