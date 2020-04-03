# frozen_string_literal: true

# Class for exporting references to Wikipedia citation templates.
#
# Supported reference types:
#   `ArticleReference` --> https://en.wikipedia.org/wiki/Template:Cite_journal
#   `BookReference`    --> https://en.wikipedia.org/wiki/Template:Cite_book

module Wikipedia
  class ReferenceExporter
    include Service

    attr_private_initialize :reference

    def call
      return "<<<cannot export references of type #{reference.type}>>>" unless formatter_class
      formatter_class.new(reference).format
    end

    private

      def formatter_class
        @_formatter_class ||= case reference
                              when ::ArticleReference then Wikipedia::ArticleReference
                              when ::BookReference    then Wikipedia::BookReference
                              end
      end

      def url
        reference.routed_url if reference.downloadable?
      end

      def pages
        # Replace hyphens with en dashes, enwp.org/WP:ENDASH
        reference.pagination&.tr("-", "\u2013")
      end

      def author_params
        authors = []
        reference.author_names.each.with_index(1) do |name, index|
          authors <<
            "|first#{index}=#{name.first_name_and_initials} " \
            "|last#{index}=#{name.last_name} "
        end
        authors.join
      end

      def reference_name
        names = reference.author_names.map(&:last_name)
        ref_names =
          case names.size
          when 1 then names.first.to_s
          when 2 then "#{names.first}_&_#{names.second}"
          else        "#{names.first}_et_al"
          end

        ref_names.tr(' ', '_') + "_#{reference.year}"
      end
  end

  # Template: enwp.org/wiki/Template:Cite_journal
  # Looks like this: {{cite journal |last= |first= |last2= |first2= |year= |title=
  # |url= |journal= |publisher= |volume= |issue= |pages= |doi= }}
  class ArticleReference < ReferenceExporter
    def format
      <<-TEMPLATE.squish
        <ref name="#{reference_name}">{{cite journal
        #{author_params}
        |year=#{reference.year}
        |title=#{title}
        |url=#{url}
        |journal=#{reference.journal.name}
        |publisher=
        |volume=#{reference.volume}
        |issue=#{reference.issue.presence}
        |pages=#{pages}
        |doi=#{reference.doi if reference.doi?}
        }}</ref>
      TEMPLATE
    end

    private

      def title
        convert_to_wikipedia_italics reference.title
      end

      # Asterix to double quotes (two single quotes mean "start italics" on WP);
      # also convert "pipes" to italics per ReferenceDecorator#format_italics.
      def convert_to_wikipedia_italics string
        string.
          gsub(/\*(.*?)\*/, %q(''\1'')).
          gsub(/\|(.*?)\|/, %q(''\1''))
      end
  end

  # Template: enwp.org/wiki/Template:Cite_book
  # Looks like this: {{cite book |last= |first= |year= |title= |url=
  # |location= |publisher= |page= |isbn=}}
  class BookReference < ReferenceExporter
    def format
      location = reference.publisher.place
      publisher = reference.publisher.name

      <<-TEMPLATE.squish
        <ref name="#{reference_name}">{{cite book
        #{author_params}
        |year=#{reference.year}
        |title=#{title}
        |url=#{url}
        |location=#{location}
        |publisher=#{publisher}
        |pages=#{pages}
        |isbn=}}</ref>
      TEMPLATE
    end

    private

      # The whole book title is italicized on WP.
      def title
        remove_italics reference.title
      end

      def remove_italics string
        string.
          gsub(/\*(.*?)\*/, '\1').
          gsub(/\|(.*?)\|/, '\1') # See Wikipedia::ArticleReference#title.
      end
  end
end
