module DatabaseScripts
  class FamilyOrSubfamilyNames < DatabaseScript
    include Rails.application.routes.url_helpers
    include ActionView::Helpers::UrlHelper

    def results
      Name.where(type: 'FamilyOrSubfamilyName')
    end

    def render
      as_table do |t|
        t.header :id, :name, :name_type, :orphaned?
        t.rows do |name|
          [
            name.id,
            link_to(name.name_html, name_path(name)),
            name.type,
            ('Yes' if name.orphaned?)
          ]
        end
      end
    end
  end
end

__END__
description: >
  That is, name records with the type `FamilyOrSubfamilyName`. See %github635.

tags: [new!]
topic_areas: [names]
