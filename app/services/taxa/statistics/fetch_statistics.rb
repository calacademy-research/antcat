# frozen_string_literal: true

module Taxa
  module Statistics
    class FetchStatistics
      include Service

      attr_private_initialize :taxon, [valid_only: false]

      def call
        return unless ranks
        fetch_statistics
      end

      private

        def ranks
          @_ranks ||= case taxon
                      when ::Family
                        [:subfamilies, :tribes, :genera]
                      when ::Subfamily
                        [:tribes, :genera, :species]
                      when ::Tribe
                        [:genera, :species]
                      when ::Genus
                        [:species, :subspecies]
                      when ::Species
                        [:subspecies]
                      end
        end

        def fetch_statistics
          statistics = {}

          ranks.each do |rank|
            taxa = taxon.public_send(rank)

            # NOTE: regarding `order('NULL')` http://dev.housetrip.com/2013/04/19/mysql-order-by-null/
            by_fossil_and_status =
              if valid_only
                taxa.valid.group(:fossil).order('NULL').count.transform_keys { |k| [k, "valid"] }
              else
                taxa.group(:fossil, :status).order('NULL').count
              end

            massage_count by_fossil_and_status, rank, statistics
          end
          statistics
        end

        def massage_count by_fossil_and_status, rank, statistics
          by_fossil_and_status.each_key do |fossil, status|
            extant_or_fossil = fossil ? :fossil : :extant
            count = by_fossil_and_status[[fossil, status]]

            statistics[extant_or_fossil] ||= {}
            statistics[extant_or_fossil][rank] ||= {}
            statistics[extant_or_fossil][rank][status] = count
          end
        end
    end
  end
end
