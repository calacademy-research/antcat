# Export via `rake antweb:export`.

module Exporters
  module Antweb
    class Exporter
      include Service

      def self.antcat_taxon_link taxon, label = "AntCat"
        url = "http://www.antcat.org/catalog/#{taxon.id}"
        %(<a href="#{url}">#{label}</a>).html_safe
      end

      def self.antcat_taxon_link_with_name taxon
        antcat_taxon_link taxon, taxon.name_with_fossil
      end

      def initialize filename
        @filename = filename
        @progress = Progress.create total: taxa_ids.count unless Rails.env.test?
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
                order("field(taxa.id, #{chunk.join(',')})").
                joins(protonym: [{ authorship: :reference }]).
                includes(protonym: [{ authorship: :reference }]).
                each do |taxon|
                STDOUT.puts "Processing: #{taxon.id}" if ENV['DEBUG']
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
                rescue StandardError => e
                  warn "========================#{taxon.id}===================="
                  warn "An error of type #{e} happened, message is #{e.message}"
                  warn e.backtrace
                  warn "======================================================="
                end
              end
            end
          end
        end

        def taxa_ids
          Taxon.joins(protonym: [{ authorship: :reference }]).order(:status).pluck(:id).reverse
        end
    end
  end
end
