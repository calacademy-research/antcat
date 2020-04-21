# frozen_string_literal: false

# Export via `rake antweb:export`.

module Exporters
  module Antweb
    class Exporter
      include Service

      EXPORTABLE_TYPES = Rank::TYPES - ['Subtribe', 'Infrasubspecies']

      def initialize filename
        @filename = filename
        @progress = create_progress_bar(taxon_ids.size)
      end

      def call
        export
      end

      private

        attr_reader :filename, :progress

        def export
          File.open(filename, 'w') do |file|
            file.puts Exporters::Antweb::ExportTaxon::HEADER

            taxon_ids.each_slice(1000) do |chunk|
              taxon_chunk(chunk).each do |taxon|
                progress.increment
                file.puts taxon_row(taxon)
              end
            end
          end
        end

        def taxon_ids
          @_taxon_ids ||= Taxon.where(type: EXPORTABLE_TYPES).order(:status).pluck(:id).reverse
        end

        def taxon_chunk chunk
          Taxon.where(id: chunk).order(Arel.sql("field(taxa.id, #{chunk.join(',')})")).
            includes(protonym: [{ authorship: :reference }])
        end

        def taxon_row taxon
          row = Exporters::Antweb::ExportTaxon[taxon]
          row.each do |col|
            if col.is_a? String
              col.delete!("\n")
              col.delete!("\r")
            end
          end
          row.join("\t")
        rescue StandardError => e
          warn "========================#{taxon.id}===================="
          warn "An error of type #{e} happened, message is #{e.message}"
          warn e.backtrace
          warn "======================================================="
        end

        def create_progress_bar total
          ProgressBar.create(total: total, format: "%a %e %P% Processed: %c from %C", throttle_rate: 0.5)
        end
    end
  end
end
