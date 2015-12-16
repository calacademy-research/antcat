# coding: UTF-8
class BiogeographicRegion

  def initialize string
    @string = string
  end

  def value
    @string
  end

  def label
    @string
  end

  def self.options_for_select
    instances.inject([[nil, nil]]) do |options, biogeographic_region|
      options << biogeographic_region.option_for_select
    end
  end

  def option_for_select
    [@string, @string]
  end

  def self.instances
    @_values ||= [
      'Nearctic', 'Neotropic', 'Palearctic', 'Afrotropic',
      'Malagasy','Indomalaya', 'Australasia', 'Oceania'
    ].map { |region| BiogeographicRegion.new(region) }
  end

end
