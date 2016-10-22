# See https://github.com/calacademy-research/antcat/issues/168
# via `grep "[[:cntrl:]]" antcat.2016-05-27T10-15-02.sql > control_characters_to_remove`

class RemoveControlCharacters < ActiveRecord::Migration
  def up
    %w( name name_html epithet epithet_html protonym_html).each do |field|
      Name.where("#{field} REGEXP ?", "[[:cntrl:]]+").each do |name|
        puts "name #{name.id}"
        puts "  to clean:     #{name.send(field.to_sym)}"

        clean_string = name.send(field.to_sym).gsub(/[[:cntrl:]]+/, "")
        puts "  clean_string: #{clean_string}"

        name.update_columns field => clean_string
      end
    end

    %w( name_cache name_html_cache verbatim_type_locality ).each do |field|
      Taxon.where("#{field} REGEXP ?", "[[:cntrl:]]+").each do |taxon|
        puts "taxon #{taxon.id}"
        puts "  to clean:     #{taxon.send(field.to_sym)}"

        clean_string = taxon.send(field.to_sym).gsub(/[[:cntrl:]]+/, "")
        puts "  clean_string: #{clean_string}"

        taxon.update_columns field => clean_string
      end
    end
  end

  def down
  end
end
