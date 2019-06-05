module DatabaseScripts
  class AuthorsWithMultipleNames < DatabaseScript
    include Rails.application.routes.url_helpers
    include ActionView::Helpers::UrlHelper

    def results
      Author.where(id: AuthorName.group(:author_id).having("COUNT(id) > 1").select(:author_id))
    end

    def render
      as_table do |t|
        t.header :author, :count, :author_names
        t.rows do |author|
          [
            link_to(author.first_author_name_name, author_path(author)),
            author.names.count,
            author.names.map(&:name).join('<br>')
          ]
        end
      end
    end
  end
end

__END__
tags: [new!, list]
topic_areas: [references]
