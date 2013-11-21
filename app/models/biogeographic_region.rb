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
      options
    end
  end

  def option_for_select
    [@string, @string]
  end

  def self.instances
    @_values ||= [
      BiogeographicRegion.new('Nearctic'),
      BiogeographicRegion.new('Neotropic'),
      BiogeographicRegion.new('Palearctic'),
      BiogeographicRegion.new('Afrotropic'),
      BiogeographicRegion.new('Malagasy'),
      BiogeographicRegion.new('Indomalaya'),
      BiogeographicRegion.new('Australasia'),
      BiogeographicRegion.new('Oceania'),
    ]
  end

end
