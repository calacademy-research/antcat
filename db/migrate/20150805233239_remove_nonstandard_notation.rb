class RemoveNonstandardNotation < ActiveRecord::Migration
  linker = Importers::Hol::LinkHolTaxa.new
  mother = TaxonMother.new

  puts "Starting"

  query_string = 'select taxa.* from taxa where instr(taxa.name_cache, ".") != 0'
  reg_exp = /([<a-zA-Z >\/]*)(\(([a-zA-Z]*)\)[<\/i>]* )(<i>)*([a-z A-Z.]*)(<\/i>)*/

  results = Taxon.find_by_sql(query_string)
  puts "results.count : #{results.count}"
  results.each do |taxon|
    puts "Taxa: #{taxon.id}"
    words = taxon.name_cache.split(" ")
    austin = ""
    puts "Processing: '#{taxon.name_cache}'"
    words.each do |word|
      if word.index('.')
        puts "  Ditching: #{word}"
      else
        if austin.size > 1
          austin += " "
        end
        austin += word
      end
    end
    puts "  rebuilt: '#{austin}'"
    candidate_taxon = Taxon.find_by_name austin
    if candidate_taxon
      puts "  We found an existing #{candidate_taxon.name_cache}. no need to create one."
    else
      puts "  this is where we create a new taxon '#{austin}'"
      puts "  It is via  '#{taxon.name_cache}'"
      current_valid_taxon = linker.get_most_recent_antcat_taxon taxon.id, nil

      puts "  It would refer to '#{current_valid_taxon.name_cache}'"

      # create
      name = linker.literal_find_or_create_name austin, true
      if name.auto_generated
        name.origin = 'migration remove_nonstandard_notation'
        name.save
      end

      new_taxon = mother.create_taxon Rank[taxon.rank], taxon.parent
      new_taxon.auto_generated = true
      new_taxon.origin = 'migration'
      new_taxon.status = "unavailable uncategorized"
      new_taxon.current_valid_taxon_id = current_valid_taxon.id
      new_taxon.name_html_cache = name.name_to_html
      new_taxon.name_cache = name.name
      new_taxon.name_id = name.id
      new_taxon.protonym_id = taxon.protonym_id

      #new_taxon.type = valid_antcat_taxon.type
      new_taxon.type_name_id = 1

      taxon_state = TaxonState.new
      taxon_state.deleted = false
      taxon_state.review_state = :old
      new_taxon.taxon_state = taxon_state
      taxon_state.save

      change = Change.new
      change.change_type = :create
      change.save!

      new_taxon.save!
      puts "  New taxon id: '#{new_taxon.id}'"

    end

  end
end
