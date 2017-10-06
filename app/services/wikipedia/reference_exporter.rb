# Class for exporting references to Wikipedia citation templates.
#
# Supported reference types:
#   `ArticleReference` --> https://en.wikipedia.org/wiki/Template:Cite_journal
#   `BookReference`    --> https://en.wikipedia.org/wiki/Template:Cite_book

module Wikipedia
  class ReferenceExporter
    include Service

    def initialize reference
      @reference = reference
    end

    def call
      formatter = "Wikipedia::#{reference.type}".safe_constantize
      return "<<<cannot export references of type #{reference.type}>>>" unless formatter
      formatter.new(reference).format
    end

    private
      attr_reader :reference

      def url
        reference.url if reference.downloadable?
      end

      def pages
        # Replace hyphens with en dashes, enwp.org/WP:ENDASH
        reference.pagination.gsub "-", "\u2013" if reference.pagination
      end

      def author_params
        authors = ''
        reference.author_names.each.with_index(1) do |name, index|
          authors <<
            "|first#{index}=#{name.first_name_and_initials} " <<
            "|last#{index}=#{name.last_name} "
        end
        authors
      end

      def reference_name
        names = reference.author_names.map &:last_name
        ref_names =
          case names.size
          when 1 then "#{names.first}"
          when 2 then "#{names.first}_&_#{names.second}"
          else        "#{names.first}_et_al"
          end

        ref_names.tr(' ', '_') << "_#{reference.year}"
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
        |url=#{url if url}
        |journal=#{reference.journal.name}
        |publisher=
        |volume=#{reference.volume}
        |issue=#{reference.issue unless reference.issue.blank?}
        |pages=#{pages}
        |doi=#{reference.doi if reference.doi?}
        }}</ref>
      TEMPLATE
    end

    private
      def title
        title = reference.title
        return unless title

        convert_to_wikipedia_italics title
      end

      # Asterix to double quotes (two single quotes mean "start italics" on WP);
      # also convert "pipes" to italics per ReferenceDecorator#format_italics.
      def convert_to_wikipedia_italics string
        string
          .gsub(/\*(.*?)\*/, %q[''\1''])
          .gsub(/\|(.*?)\|/, %q[''\1''])
      end
  end

  # Template: enwp.org/wiki/Template:Cite_book
  # Looks like this: {{cite book |last= |first= |year= |title= |url=
  # |location= |publisher= |page= |isbn=}}
  class BookReference < ReferenceExporter
    def format
      location = reference.publisher.place.name
      publisher = reference.publisher.name

      <<-TEMPLATE.squish
        <ref name="#{reference_name}">{{cite book
        #{author_params}
        |year=#{reference.year}
        |title=#{title}
        |url=#{url if url}
        |location=#{location}
        |publisher=#{publisher}
        |pages=#{pages}
        |isbn=}}</ref>
      TEMPLATE
    end

    private
      def title
        title = reference.title
        return unless title

        # The whole book title is italicized on WP.
        remove_italics title
      end

      def remove_italics string
        string
          .gsub(/\*(.*?)\*/, '\1')
          .gsub(/\|(.*?)\|/, '\1') # See Wikipedia::ArticleReference#title.
      end
  end
end
