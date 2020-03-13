module Exporters
  module Endnote
    class Formatter
      def self.format references
        references.map do |reference|
          klass =
            case reference
            when ArticleReference then ArticleFormatter
            when BookReference    then BookFormatter
            when NestedReference  then NestedFormatter
            when UnknownReference then UnknownFormatter
            else raise "reference type not supported"
            end
          klass.new(reference).call
        end.select(&:present?).join("\n") + "\n"
      end
    end

    class BaseFormatter
      def initialize reference
        @reference = reference
        @string = []
      end

      def call
        add '0', kind
        add_author_names
        add 'D', year
        add 'T', title
        add_contents
        add 'Z', public_notes
        add 'K', taxonomic_notes
        add 'U', url
        add '~', 'AntCat'
        string.join("\n") + "\n"
      end

      private

        attr_reader :reference
        attr_accessor :string

        delegate :author_names, :year, :title, :public_notes, :taxonomic_notes, :url, to: :reference

        def add tag, value
          string << "%#{tag} #{value.to_s.gsub(/[|*]/, '')}" if value.present?
        end

        def add_author_names
          author_names.each do |author|
            add "A", author.name
          end
        end
    end

    class ArticleFormatter < BaseFormatter
      private

        delegate :journal, :series_volume_issue, :pagination, to: :reference

        def kind
          'Journal Article'
        end

        def add_contents
          add 'J', journal.name
          add 'N', series_volume_issue
          add 'P', pagination
        end
    end

    class BookFormatter < BaseFormatter
      private

        delegate :publisher, :pagination, to: :reference

        def kind
          'Book'
        end

        def add_contents
          add 'C', publisher.place
          add 'I', publisher.name
          add 'P', pagination
        end
    end

    class UnknownFormatter < BaseFormatter
      private

        delegate :citation, to: :reference

        def kind
          'Generic'
        end

        def add_contents
          add '1', citation
        end
    end

    class NestedFormatter < BaseFormatter
      # don't know how to get EndNote to handle nested references
      def call
        ''
      end
    end
  end
end
