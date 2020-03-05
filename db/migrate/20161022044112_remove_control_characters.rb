# TODO: Remove blanked data migrations like this one.

# See https://github.com/calacademy-research/antcat/issues/168
# via `grep "[[:cntrl:]]" antcat.2016-05-27T10-15-02.sql > control_characters_to_remove`

class RemoveControlCharacters < ActiveRecord::Migration[4.2]
  def up
    # %w( name name_html epithet epithet_html protonym_html).each do |field|
    #   Name.where("#{field} REGEXP ?", "[[:cntrl:]]+").each do |name|
    #     clean_string = name.public_send(field.to_sym).gsub(/[[:cntrl:]]+/, "")
    #     name.update_columns field => clean_string
    #   end
    # end
    #
    # %w( name_cache name_html_cache verbatim_type_locality ).each do |field|
    #   Taxon.where("#{field} REGEXP ?", "[[:cntrl:]]+").each do |taxon|
    #     clean_string = taxon.public_send(field.to_sym).gsub(/[[:cntrl:]]+/, "")
    #     taxon.update_columns field => clean_string
    #   end
    # end
  end

  def down
  end
end
