# coding: UTF-8
class ReverseSynonymyEdit < EditingHistory
  belongs_to :new_junior, class_name: 'Taxon'; validates :new_junior, presence: true
  belongs_to :new_senior, class_name: 'Taxon'; validates :new_senior, presence: true
end
