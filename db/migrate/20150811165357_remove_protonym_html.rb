class RemoveProtonymHtml < ActiveRecord::Migration
  #
  #
  # It turns out that a “name” record has the following fields:
  #                                                                                                                                                                                                                      Name
  # Name_html
  # protonym_html
  #
  # A taxon has protonym. A protonym has a name.
  # A taxon also has a name.
  #
  # In the cases we are currently examining, the name record for taxa and protonym are the same record.
  #
  #  The notion of a distinct “protonym_html” in name that can be distinct from the other fields makes little sense
  #                                                          in the current organization,
  #   so I’m going to have to unwind this by making new “name” records that are distinct if they don’t already exist,
  # and pointing the protonym_name_id field to them.
  #
  #
  linker = Importers::Hol::LinkHolTaxa.new

  # each name record associated with a protonym where the name doesn't match the protonym.
  query_string = 'select * from names where name_html != protonym_html'

  reg_exp = /[<\>i]*([a-zA-Z]+)([<\>\/i ]*\(([a-zA-Z]*)\)[<\/i>]* )*[<i>]*([a-z A-Z.]*)[<\/i>]*/

  results = Name.find_by_sql(query_string)
  puts "results.count : #{results.count}"
  results.each do |name|
    puts "Processing name: #{name.name} with protonym #{name.protonym_html}"

    # extract the string from the protonym's name "protonym_html" field
    # Strip html tags
    # look it up in "names". If it doesn't exist, make it. if it does exist
    # return it.
    unless name.protonym_html?
      puts "  protonym html is nil; skipping."
      next
    end
    stripped = ActionView::Base.full_sanitizer.sanitize(name.protonym_html)
    puts "  Revised name we're checking: #{stripped} original: #{name.protonym_html}"
    new_name_record = Name.find_by_name(stripped)
    #new_name_record = linker.find_or_create_name stripped
    if(new_name_record.nil?)
      new_name_record = Names::CreateNameFromString[stripped, true]
      if new_name_record.nil?
        puts "  Unrecoverable error attempting to create name #{name.name}"
        next
      end
      new_name_record.type = name.type
      #new_name_record.name = stripped
      new_name_record.gender = name.gender
      new_name_record.auto_generated = true
      new_name_record.origin = 'migration'
      new_name_record.nonconforming_name = name.nonconforming_name
      new_name_record.save
    end

    # Find all references to the old name id, and replace it with the new name id.
    # find in taxa
    # Taxon.where(name_id: name.id).each do  |taxon|
    #   taxon.update_columns(name_id: new_name_record.id)
    #   puts ("  Got a hit in taxon #{taxon.name_cache}")
    #
    # end
    # find in protonym.
    Protonym.where(name_id: name.id).each do  |protonym|
      protonym.update_columns(name_id: new_name_record.id)
      puts "  Got a hit in protonym"

    end
    name.update_columns(protonym_html: nil)
  end

  def change
    #remove_column :names, :protonym_html
    execute "delete from names where names.id not in (select name_id from taxa union select name_id from protonyms)"
  end
end
