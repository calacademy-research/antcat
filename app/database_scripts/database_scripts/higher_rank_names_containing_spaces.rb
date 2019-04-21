module DatabaseScripts
  class HigherRankNamesContainingSpaces < DatabaseScript
    include Rails.application.routes.url_helpers
    include ActionView::Helpers::UrlHelper

    def results
      Name.single_word_names.where("name LIKE ?", "% %")
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
  Names excluding subgenus-, species- and subspecies names that contain spaces.


  It is not possible to fix these names without using scripts. As of writing, all names here
  are subspecies names miscategorized as genus names; these will be fixed by script.

tags: [regression-test]
topic_areas: [names]
