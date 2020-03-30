# frozen_string_literal: true

# Collapse subdirs of STI classes because placed in subdirs for
# organizational purposes only, without using proper namespaces.
Rails.autoloaders.each do |autoloader|
  autoloader.collapse("app/models/taxon_sti_subclasses")
  autoloader.collapse("app/models/taxon_sti_subclasses/genus_group_taxon_sti_subclasses")
  autoloader.collapse("app/models/taxon_sti_subclasses/species_group_taxon_sti_subclasses")

  autoloader.collapse("app/models/name_sti_subclasses")
  autoloader.collapse("app/models/name_sti_subclasses/genus_group_name_sti_subclasses")
  autoloader.collapse("app/models/name_sti_subclasses/species_group_name_sti_subclasses")

  autoloader.collapse("app/models/reference_sti_subclasses")
  autoloader.collapse("app/decorators/reference_decorator_subclasses")
end
