# coding: UTF-8
class Protonym < ActiveRecord::Base
  include UndoTracker

  has_one :taxon # Taxon has a protnym_id
  belongs_to :authorship, class_name: 'Citation', dependent: :destroy # this model has a single authorship_id that references the "Citation" table
  validates :authorship, presence: true
  belongs_to :name; validates :name, presence: true # Protonym has a name_id
  accepts_nested_attributes_for :name, :authorship
  has_paper_trail meta: { change_id: :get_current_change_id}

  attr_accessible :fossil, :sic, :locality, :id, :name_id, :name, :authorship, :taxon

  def authorship_string
    authorship and authorship.authorship_string
  end

  def authorship_html_string
    authorship and authorship.authorship_html_string
  end

  def author_last_names_string
    authorship and authorship.author_last_names_string
  end

  def year
    authorship and authorship.year
  end

  def self.destroy_orphans
    orphans = Protonym.where("id NOT IN (SELECT protonym_id FROM taxa)")
    orphans.each do |orphan|
      orphan.destroy
    end
  end
end