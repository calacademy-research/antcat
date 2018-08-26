# Export via `rake antweb:export`.

# rubocop:disable Rails/Output
class Exporters::Antweb::Exporter
  include Service

  def self.antcat_taxon_link taxon, label = "AntCat"
    url = "http://www.antcat.org/catalog/#{taxon.id}"
    %(<a class="link_to_external_site" href="#{url}">#{label}</a>).html_safe
  end

  def self.antcat_taxon_link_with_name taxon
    antcat_taxon_link taxon, taxon.name_with_fossil
  end

  def initialize file
    @file = file
    @progress = Progress.create total: taxa_ids.count unless Rails.env.test?
  end

  def call
    File.open(@file, 'w') do |file|
      file.puts Exporters::Antweb::ExportTaxon::HEADER

      taxa_ids.each_slice(1000) do |chunk|
        Taxon.where(id: chunk).
          order("field(taxa.id, #{chunk.join(',')})").
          joins(protonym: [{ authorship: :reference }]).
          includes(protonym: [{ authorship: :reference }]).
          each do |taxon|
          begin
            if !taxon.name.nonconforming_name && !taxon.name_cache.index('?')
              puts "Processing: #{taxon.id}" if ENV['DEBUG']
              @progress.increment unless Rails.env.test?

              begin
                row = Exporters::Antweb::ExportTaxon.new.call(taxon)
              rescue Exception => exception # rubocop:disable Lint/RescueException
                STDERR.puts "========================#{taxon.id}================================"
                STDERR.puts "An error of type #{exception} happened, message is #{exception.message}"
                STDERR.puts exception.backtrace
                STDERR.puts "========================================================"
              end

              if row
                row[20].delete!('\"') if row[20]
                row.each do |col|
                  if col.is_a? String
                    col.delete!("\n")
                    col.delete!("\r")
                  end
                end
              end
              file.puts row.join("\t") if row
            end
          rescue Exception => e # rubocop:disable Lint/RescueException
            puts "Fatal error exporting taxon id: #{taxon.id}"
            puts e.message
            puts e.backtrace.inspect
          end
        end
      end
    end
  end

  private

    def taxa_ids
      Taxon.joins(protonym: [{ authorship: :reference }]).
        order(:status).pluck(:id).reverse
    end
end
# rubocop:enable Rails/Output
