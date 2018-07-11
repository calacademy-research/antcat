module Taxa::Statistics
  extend ActiveSupport::Concern

  module ClassMethods
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

  protected
    # TODO this is really slow; figure out how to add database indexes for this.
    def get_statistics ranks, valid_only: false
      statistics = {}
      ranks.each do |rank|
        count = if valid_only
                  send(rank).valid
                else
                  send(rank)
                end.group('fossil', 'status').count
        delete_original_combinations count unless valid_only

        self.class.massage_count count, rank, statistics
      end
      statistics
    end

  private
    def delete_original_combinations count
      count.delete [true, Status::ORIGINAL_COMBINATION]
      count.delete [false, Status::ORIGINAL_COMBINATION]
    end
end
