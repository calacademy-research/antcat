class Protonym < ActiveRecord::Base
  include UndoTracker

  attr_accessible :fossil, :sic, :locality, :id, :name_id, :name, :authorship, :taxon

  belongs_to :authorship, class_name: 'Citation', dependent: :destroy
  belongs_to :name

  has_one :taxon

  validates :authorship, presence: true
  validates :name, presence: true

  accepts_nested_attributes_for :name, :authorship
  has_paper_trail meta: { change_id: :get_current_change_id }

  # TODO? `allow_nil` should not be needed per `validates :authorship, presence: true`,
  # but protonym_spec.rb uses `build_stubbed`, so we need it for the moment.
  # TODO try to remove `allow_nil`. It may however be required in `Taxon`.
  delegate :authorship_string, :year, to: :authorship, allow_nil: true
end
