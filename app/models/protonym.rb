# coding: UTF-8
class Protonym < ActiveRecord::Base
  include Updater
  belongs_to :authorship, class_name: 'Citation', dependent: :destroy
  belongs_to  :name
  validates   :name, presence: true

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
    update_name_field 'name', Name.import(data), attributes
    update_field 'sic', data[:sic], attributes
    update_field 'fossil', data[:fossil], attributes
    update_field 'locality', data[:locality], attributes
    update_attributes attributes
  end

end
