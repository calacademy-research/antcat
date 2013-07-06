# coding: UTF-8
class ReferenceSnapshot < ActiveRecord::Base
  belongs_to :reference, foreign_key: :reference_id, class_name: 'Reference'; validates :reference, presence: true
  belongs_to :reference_version,          class_name: 'Version'
  belongs_to :journal_version,            class_name: 'Version'
  belongs_to :publisher_version,          class_name: 'Version'
  belongs_to :place_version,              class_name: 'Version'
  belongs_to :nested_reference_version,   class_name: 'Version'

  def self.take_snapshot reference
    create!({
      reference:                          reference,
      reference_version:                  reference.version,
      journal_version:                    reference.journal.try(:version),
      publisher_version:                  reference.publisher.try(:version),
      place_version:                      reference.place.try(:version),
      nested_reference_version_version:   reference.nested_reference.try(:version),
    })
  end

end
