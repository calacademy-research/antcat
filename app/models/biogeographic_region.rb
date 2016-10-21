module BiogeographicRegion
  # Note that there are two spellings of "Palearctic" (American English) in the
  # database. All occurrences of "Palaearctic" (BrE) should probably be replaced.
  # TODO migrate and remove HACK in app/models/taxa/search.rb
  REGIONS = %w( Nearctic Neotropic Palearctic Afrotropic
                Malagasy Indomalaya Australasia Oceania
                Palaearctic Antarctic)
end
