# coding: UTF-8
class Protonym < ActiveRecord::Base
  include Nameable
  belongs_to :authorship, class_name: 'Citation', dependent: :destroy

  def self.import data
    transaction do
      authorship = Citation.import data[:authorship].first if data[:authorship]
      create! name:  Name.import(data),
              sic:          data[:sic],
              fossil:       data[:fossil],
              authorship:   authorship,
              locality:     data[:locality]
    end
  end

end
