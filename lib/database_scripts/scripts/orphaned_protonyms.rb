class DatabaseScripts::Scripts::OrphanedProtonyms
  include DatabaseScripts::DatabaseScript

  def results
    Protonym.where("id NOT IN (SELECT protonym_id FROM taxa)")
  end

  def render
    as_table do
      header :protonym, :id, :created_at, :updated_at

      rows do |protonym|
        [ protonym_name_with_search_link(protonym),
          protonym.id,
          protonym.created_at,
          protonym.updated_at ]
      end
    end
  end

  private
    def protonym_name_with_search_link protonym
      search_path = "/catalog/search/quick_search?&search_type=containing&qq="
      label = protonym.name.protonym_with_fossil_html protonym.fossil
      "<a href='#{search_path}#{URI.encode(protonym.name.name, /\W/)}'>#{label}</a>"
    end
end

__END__
description: >
  Click on the protonym name to search for taxa with this name.

  It is probably safe to remove these (use `rake antcat:db:destroy_protonym_orphans`).

topic_areas: [catalog]
