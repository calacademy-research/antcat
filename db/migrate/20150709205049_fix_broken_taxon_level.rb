#
#   We have 388 cases of incongruity in species and subspecies.

# Case  - Binomial identified as a subspecies. Genus id is specified.
#   - resolution - change the type to species.
#
# Case - Binomial identified as subspecies, no genus id is specified:
#   - No such case. yay!
#
# Case - Trinomial identified as species, species id specified
# - resolution, change the type to subspecies
#
# Case - Trinomial identified as species, species id is NOT specified
# - resolution, change the type to subspecies, look up genus/species specific epithets
class FixBrokenTaxonLevel < ActiveRecord::Migration
  def change
    # Trinomial wrongly identified as species

    execute "update
  taxa
  join names
      set taxa.type = TRIM(TRAILING 'Name' FROM names.type)
where
 taxa.name_id = names.id AND TRIM(TRAILING 'Name' FROM names.type) != Taxa.type
                AND taxa.auto_generated = FALSE AND (taxa.type = 'Subspecies' OR taxa.type = 'Species')
                AND names.type = 'SubspeciesName' AND species_id IS not NULL"

    # Binomial wrongly identified as subspecies.
    execute "update
    taxa
    join names
    set taxa.type = TRIM(TRAILING 'Name' FROM names.type)
    where
    taxa.name_id = names.id AND TRIM(TRAILING 'Name' FROM names.type) != Taxa.type
    AND taxa.auto_generated = FALSE AND (taxa.type = 'Subspecies' OR taxa.type = 'Species')
    AND names.type = 'SpeciesName' AND species_id IS  NULL"

    # Case - Trinomial identified as species, species id is NOT specified
    # - resolution, change the type to subspecies, look up genus/species specific epithets

    Taxon.joins("JOIN names
                ON taxa.name_id = names.id
                AND names.type='SubspeciesName'
                AND taxa.type = 'Species'
                AND taxa.auto_generated = FALSE
                AND species_id IS  NULL").each do |taxa|

      species_parents = Taxon.where(name_cache: taxa.name_cache.split(' ')[0...-1].join(' '))
      if species_parents.count == 1
        parent = species_parents.first
        taxa.species_id = parent.id
        taxa.type = "Subspecies"
        taxa.save!
      else
        puts ("Got a bad number of matches for #{taxa.name_cache.split(' ')[0...-1].join(' ')}: #{species_parents.count}. Taxa id: #{taxa.id} name: #{taxa.name_cache}")
        # Should we do this? probably.
        taxa.type = "Subspecies"
        taxa.save!

      end

    end


    Taxon.where(type: 'Subspecies', species_id: nil).each do |taxa|

      species_parents = Taxon.where(name_cache: taxa.name_cache.split(' ')[0...-1].join(' '))
      # check for quardanomial case here
      if species_parents.count == 1
        parent = species_parents.first
        taxa.species_id = parent.id
        taxa.type = "Subspecies"
        taxa.save!
      else
        puts ("big clean - bad match #{taxa.name_cache.split(' ')[0...-1].join(' ')}: #{species_parents.count}. Taxa id: #{taxa.id} name: #{taxa.name_cache}")
      end

    end

  end
end

