# frozen_string_literal: true

# Export via `rake antweb:export`.

module Exporters
  module Antweb
    class Exporter
      include Service

      EXPORTABLE_TYPES = Rank::TYPES - [Rank::SUBTRIBE, Rank::INFRASUBSPECIES]

      def initialize filename
        @filename = filename
        @progress = create_progress_bar(taxon_ids.size)
      end

      def call
        export
      end

      private

        attr_reader :filename, :progress

        def skipped_taxon_ids
          @_skipped_taxon_ids ||= []
        end

        # Written to a temporary file that replaces the export only when complete, so a failed run
        # leaves the previous export in place instead of a partial file.
        def export
          temp_filename = "#{filename}.tmp"

          File.open(temp_filename, 'w') do |file|
            file.puts Exporters::Antweb::ExportTaxon::HEADER

            taxon_ids.each_slice(1000) do |chunk|
              taxon_chunk(chunk).each do |taxon|
                progress.increment
                row = taxon_row(taxon)
                file.puts row if row # `nil` when an exception was ignored.
              end
            end
          end

          File.rename(temp_filename, filename)
          report_skipped
        end

        # With `AW_EXPORT_IGNORE_EXCEPTIONS`, taxa that could not be exported are left out of the file: say how many.
        def report_skipped
          return if skipped_taxon_ids.empty?
          warn "Left out #{skipped_taxon_ids.size} taxa that could not be exported: #{skipped_taxon_ids.first(50).join(', ')}"
        end

        def taxon_ids
          @_taxon_ids ||= begin
            ids = Taxon.where(type: EXPORTABLE_TYPES).order(:status).pluck(:id).reverse

            # A blank `AW_EXPORT_LIMIT` is no limit (it gave 0, a file with only the header).
            if (limit = ENV['AW_EXPORT_LIMIT'].presence&.to_i)
              ids[0...limit]
            else
              ids
            end
          end
        end

        def taxon_chunk chunk
          Taxon.where(id: chunk).order(Arel.sql("field(taxa.id, #{chunk.join(',')})")).
            includes(protonym: [{ authorship: :reference }])
        end

        # :nocov:
        def taxon_row taxon
          Exporters::Antweb::ExportTaxon[taxon]
        rescue StandardError => e
          unless ENV['AW_EXPORT_IGNORE_EXCEPTIONS']
            $stdout.puts "Could not export taxon #{taxon.id} (run with `AW_EXPORT_IGNORE_EXCEPTIONS=y` to ignore exceptions)"
            raise
          end

          skipped_taxon_ids << taxon.id
          warn "========================#{taxon.id}===================="
          warn "An error of type #{e} happened, message is #{e.message}"
          warn e.backtrace
          warn "======================================================="
        end
        # :nocov:

        def create_progress_bar total
          ProgressBar.create(total: total, format: "%a %e %P% Processed: %c from %C", throttle_rate: 0.5)
        end
    end
  end
end
