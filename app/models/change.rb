# coding: UTF-8
class Change < ActiveRecord::Base
  belongs_to :paper_trail_version, class_name: 'PaperTrail::Version'
end
