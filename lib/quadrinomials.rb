# coding: UTF-8
require_relative '../config/environment.rb'

four_epithet_names = Name.all.select do |name|
  name.name.split(' ').size >= 4
end

status_counts = {}
four_epithet_names.each do |name|
  taxon = Taxon.find_by_name_id name.id
  if taxon
    if taxon.status == 'valid'
      puts taxon.name
    end
    status_counts[taxon.status] ||= 0
    status_counts[taxon.status] += 1
  else
    status_counts['no taxon'] ||= 0
    status_counts['no taxon'] += 1
  end
end
