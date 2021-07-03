# frozen_string_literal: true

module Exporters
  module Endnote
    class Formatter
      include Service

      attr_private_initialize :references

      def call
        references.map do |reference|
          formatter_class(reference).new(reference).call
        end.select(&:present?).join("\n") + "\n"
      end

      private

        def formatter_class reference
          case reference
          when ArticleReference then ArticleFormatter
          when BookReference    then BookFormatter
          when NestedReference  then NestedFormatter
          else raise "reference type not supported"
          end
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
        add 'U', routed_url
        add '~', 'AntCat'
        string.join("\n") + "\n"
      end

      private

        attr_reader :reference
        attr_accessor :string

        delegate :author_names, :year, :title, :public_notes, :taxonomic_notes, to: :reference

        def add tag, value
          string << "%#{tag} #{value.to_s.gsub(/[|*]/, '')}" if value.present?
        end

        def add_author_names
          author_names.each do |author|
            add "A", author.name
          end
        end

        def routed_url
          return unless reference.downloadable?
          reference.routed_url
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

    class NestedFormatter < BaseFormatter
      # Don't know how to get EndNote to handle `NestedReference`s.
      def call
        ''
      end
    end
  end
end
