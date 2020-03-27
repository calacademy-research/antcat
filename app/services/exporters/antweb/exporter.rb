# frozen_string_literal: false

# Export via `rake antweb:export`.

module Exporters
  module Antweb
    class Exporter
      include Service

      def self.antcat_taxon_link_with_name taxon, label: nil
        url = "https://www.antcat.org/catalog/#{taxon.id}"
        %(<a href="#{url}">#{label || taxon.name_with_fossil}</a>).html_safe
      end

      # TODO: Improve this and related methods. Probably use `AntwebFormatter`.
      def self.antcat_taxon_link_with_name_and_author_citation taxon
        antcat_taxon_link_with_name(taxon) << ' ' << taxon.author_citation.html_safe
      end

      def initialize filename
        @filename = filename
        @progress = progress_bar taxa_ids.size unless Rails.env.test?
      end

      def call
        export
      end

      private

        attr_reader :filename, :progress

        def export
          File.open(filename, 'w') do |file|
            file.puts Exporters::Antweb::ExportTaxon::HEADER

            taxa_ids.each_slice(1000) do |chunk|
              Taxon.where(id: chunk).
                order(Arel.sql("field(taxa.id, #{chunk.join(',')})")).
                joins(protonym: [{ authorship: :reference }]).
                includes(protonym: [{ authorship: :reference }]).
                each do |taxon|
                progress.increment unless Rails.env.test?

                begin
                  row = Exporters::Antweb::ExportTaxon[taxon]
                  row.each do |col|
                    if col.is_a? String
                      col.delete!("\n")
                      col.delete!("\r")
                    end
                  end
                  file.puts row.join("\t")
                # :nocov:
                rescue StandardError => e
                  warn "========================#{taxon.id}===================="
                  warn "An error of type #{e} happened, message is #{e.message}"
                  warn e.backtrace
                  warn "======================================================="
                end
                # :nocov:
              end
            end
          end
        end

        def taxa_ids
          @taxa_ids ||= Taxon.where.not(type: ['Subtribe', 'Infrasubspecies']).
                          joins(protonym: [{ authorship: :reference }]).
                          order(:status).pluck(:id).reverse
        end

        def progress_bar total
          ProgressBar.create total: total, format: "%a %e %P% Processed: %c from %C", throttle_rate: 0.5
        end
    end
  end
end
