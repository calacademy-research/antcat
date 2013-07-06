# coding: UTF-8
class Protonym < ActiveRecord::Base
  include Importers::Bolton::Catalog::Updater
  has_one    :taxon
  belongs_to :authorship, class_name: 'Citation', dependent: :destroy
   validates :authorship, presence: true
  belongs_to :name; validates :name, presence: true
  accepts_nested_attributes_for :name, :authorship
  has_paper_trail

  def authorship_string
    authorship and authorship.authorship_string
  end

  def self.destroy_orphans
    orphans = Protonym.includes(:taxon).where('taxa.id IS NULL')
    orphans.each do |orphan|
      orphan.destroy
    end
  end

  ################################################################
  def self.import data
    transaction do
      authorship = Citation.import data[:authorship].first if data[:authorship]
      create! name:         Name.import(data),
              sic:          data[:sic],
              fossil:       data[:fossil],
              authorship:   authorship,
              locality:     data[:locality]
    end
  end

  def update_data data
    attributes = {}
    update_name_field     'name', Name.import(data), attributes
    update_boolean_field  'sic', data[:sic], attributes
    update_boolean_field  'fossil', data[:fossil], attributes
    update_field          'locality', data[:locality], attributes
    authorship.update_data data[:authorship].first if authorship
    update_attributes attributes
  end

end
