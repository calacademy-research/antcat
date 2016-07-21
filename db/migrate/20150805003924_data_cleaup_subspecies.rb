class DataCleaupSubspecies < ActiveRecord::Migration
      #  include Importers::Bolton::Catalog::Updater



      # 1) Subgenus in parens > remove subgenus
  #
  # Breaking this down into two steps:
  # 1.1: Fix the data corruption in name where protonm_html doesn’t match name by removing parenthetical from
  #      protonym_html
  # 1.2: Create a new entry for the protonym (without subgenus), where it doesn’t already exist.
  #      It will point to the current valid taxa that is referenced by any entires that referenced the entry in 1.1
  #  1.3: Do this for all protonyms, not just the parenteticals
  #                                      (always - original combination)
  #
  #                                      2) Subspecific ranks explicit (subsp., var., st., r.) > remove rank abbreviation


  linker = Importers::Hol::LinkHolTaxa.new
  mother = TaxonMother.new

  puts "Starting"


  query_string ='SELECT
  taxa.*
FROM taxa, protonyms, names AS protonym_name
WHERE protonyms.id = taxa.protonym_id
      AND protonyms.name_id = protonym_name.id
      AND instr(protonym_name.protonym_html, "(") != 0 '



  reg_exp = /[<\>i]*([a-zA-Z]+)[<\>\/i ]*\(([a-zA-Z]*)\)[<\/i>]* [<i>]*([a-z A-Z.]*)[<\/i>]*/

  # <i>Aphaenogaster</i> <i>(Attomyrma)</i> <i>famelica</i> subsp. <i>angulata</i>
  # 1.	[1-22]	`<i>Aphaenogaster</i> `
  # 2.	[22-41]	`<i>(Attomyrma)</i> `
  # 3.	[26-35]	`Attomyrma`
  # 4.	[41-79]	`<i>famelica</i> subsp. <i>angulata</i>`

  # Do a query for every taxa that has the condition in its protonym and create a new
  # taxon entry of class "original combination" which has a "see" pointing to the current valid taxon.
  results = Taxon.find_by_sql(query_string)
  puts "results.count : #{results.count}"
  results.each do |taxon|
    puts "Taxa: #{taxon.id}"


    protonym_name = taxon.protonym.name
    # Double check that this condition still exists in the protonym
    if protonym_name.protonym_html.include?("(")
      #puts ("We found one: #{protonym_name.protonym_html}")
      # Extract the parenthetical genus
      genus_match = protonym_name.protonym_html.match(reg_exp)

      if genus_match.nil?
        puts " Unable to process name: #{protonym_name.protonym_html} from taxa: #{taxon.id}"
        next
      else
        puts " Name to be parsed and added to notes: #{protonym_name.protonym_html}"
      end

      genus_string = genus_match[1]
      previous_genus_string = genus_match[2]
      species_string = genus_match[3]
      candidate_for_creation_string = "#{previous_genus_string} #{species_string}"
      puts " Got previous genus : '#{previous_genus_string}' and species '#{species_string}' processing protonym name: '#{protonym_name}'"
      previous_parent = Taxon.find_by_name previous_genus_string
      # Look up
      if previous_parent.nil?
        puts "  Warning: We can't find genus '#{previous_genus_string}'. will not create #{previous_genus_string} #{species_string}"
      else
        # Make new original combination that referrs to  #{taxon_string} #{genus_match[4]}.
        current_valid_taxon = linker.get_most_recent_antcat_taxon taxon.id, nil
        puts "  Current valid taxon: #{current_valid_taxon.name_cache}"
        rank_string = previous_parent.rank
        puts "  Got rank identifier for #{previous_genus_string}: #{rank_string}"
        if (rank_string != "genus")
          puts "  Skipping; rank identifier is not genus."
          next
        end

        puts "  Looked up previous combination: #{previous_parent.id}  - name: #{previous_parent.name_cache}"
        candidate_taxon = Taxon.find_by_name  candidate_for_creation_string
        if(candidate_taxon)
          puts "  We found an existing #{candidate_taxon.name_cache}. no need to create one."
        else
          puts "  this is where we  create a new taxon  #{candidate_for_creation_string}"
          puts "  It would refer to #{current_valid_taxon.name_cache}"

          # create
          name = linker.literal_find_or_create_name candidate_for_creation_string
          if name.auto_generated
            name.origin='migration - data cleanup subspecies'
            name.save
          end
          protonym = Protonym.new
          protonym.name = name
          protonym.authorship = taxon.protonym.authorship
          protonym.save
          new_taxon = mother.create_taxon Rank[:species], previous_parent
          new_taxon.auto_generated = true
          new_taxon.origin = 'migration'
          new_taxon.status = "original combination"
          new_taxon.current_valid_taxon_id = current_valid_taxon.id
          new_taxon.name_cache = name.name
          new_taxon.name_id = name.id
          new_taxon.protonym_id = protonym.id


          #new_taxon.type = valid_antcat_taxon.type
          new_taxon.type_name_id=1


          taxon_state = TaxonState.new
          taxon_state.deleted = false
          taxon_state.review_state = :old
          new_taxon.taxon_state = taxon_state
          taxon_state.save

          change = Change.new
          change.change_type = :create
          change.save!

          new_taxon.save!
          puts "  New taxon id: #{new_taxon.id}"
        end
      end
    end
  end
end
