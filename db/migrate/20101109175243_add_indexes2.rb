class AddIndexes2 < ActiveRecord::Migration
  def self.up
    add_index :places, :name, :name => 'places_name_idx'
    add_index :publishers, :name, :name => 'publishers_name_idx'
    add_index :journals, :name, :name => 'journals_name_idx'
    add_index :references, [:authors_string, :citation_year], :length => {:authors_string => 100},
      :name => 'references_authors_string_citation_year_idx'
    remove_index :author_participations, :name => 'foo'
    add_index :author_participations, :reference_id, :name => 'author_participations_reference_id_idx'
  end

  def self.down
    remove_index :author_participations, :name => 'author_participations_reference_id_idx'
    add_index :author_participations, :reference_id, :name => 'foo'
    remove_index :references, :name => 'references_authors_string_citation_year_idx'
    remove_index :journals, :name => 'journals_name_idx'
    remove_index :publishers, :name => 'publishers_name_idx'
    remove_index :places, :name => 'places_name_idx'
  end
end
