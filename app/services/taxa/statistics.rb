module Taxa
  class Statistics
    include Service

    def initialize(taxon, ranks, valid_only:)
      @taxon = taxon
      @ranks = ranks
      @valid_only = valid_only
    end

    def call
      get_statistics
    end

    private

      attr_reader :taxon, :ranks, :valid_only

      # TODO this is really slow; figure out how to add database indexes for this.
      def get_statistics
        statistics = {}

        ranks_with_taxa.each do |rank, taxa|
          taxa = taxa.valid if valid_only
          count = taxa.group(:fossil, :status).count
          delete_original_combinations count unless valid_only

          massage_count count, rank, statistics
        end
        statistics
      end

      def ranks_with_taxa
        case ranks
        when Array then ranks.map { |rank| [rank, taxon.send(rank)] }
        when Hash  then ranks.map { |rank, klass| [rank, klass] }
        end
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
