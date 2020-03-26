# frozen_string_literal: true

module DatabaseScripts
  class AuthorsWithMultipleNames < DatabaseScript
    def results
      Author.where(id: AuthorName.group(:author_id).having("COUNT(id) > 1").select(:author_id)).
        includes(:names)
    end

    def render
      as_table do |t|
        t.header 'Author', 'Count', 'Author names'
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

category: References
tags: [list]
