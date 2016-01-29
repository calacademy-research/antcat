# TODO remove [and list in change log]?
# AntwikiValidTaxon.count == 0
# The url in antwiki.rb is dead, and the code tries to update fields not listed
# in schema.rb (eg :result). Doesn't seem to work with an id (see
# `create_table "antwiki_valid_taxa", id: false`), at least not in Rails 4.

class AntwikiValidTaxon < ActiveRecord::Base
  self.table_name = :antwiki_valid_taxa
end
