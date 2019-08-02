module Taxa
  module Statistics
    class FetchStatistics
      include Service

      def initialize(taxon, valid_only: false)
        @taxon = taxon
        @valid_only = valid_only
      end

      def call
        return unless ranks
        fetch_statistics
      end

      private

        attr_reader :taxon, :valid_only

        def ranks
          @ranks ||= case taxon
                     when ::Family
                       [:subfamilies, :tribes, :genera, :species]
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
            count =
              if valid_only
                taxa.valid.group(:fossil).order('NULL').count.transform_keys do |k| [k, "valid"] end
              else
                taxa.group(:fossil, :status).order('NULL').count
              end

            massage_count count, rank, statistics
          end
          statistics
        end

        def massage_count count, rank, statistics
          count.keys.each do |fossil, status|
            value = count[[fossil, status]]
            extant_or_fossil = fossil ? :fossil : :extant
            statistics[extant_or_fossil] ||= {}
            statistics[extant_or_fossil][rank] ||= {}
            statistics[extant_or_fossil][rank][status] = value
          end
        end
    end
  end
end
