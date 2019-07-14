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
        get_statistics
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
                     when ::Subgenus
                       nil
                     when ::Species
                       [:subspecies]
                     when ::Subspecies
                       nil
                     end
        end

        def get_statistics
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

            delete_original_combinations count unless valid_only

            massage_count count, rank, statistics
          end
          statistics
        end

        def delete_original_combinations count
          count.delete [true, Status::ORIGINAL_COMBINATION]
          count.delete [false, Status::ORIGINAL_COMBINATION]
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
