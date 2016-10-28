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
    def get_statistics ranks
      statistics = {}
      ranks.each do |rank|
        count = send(rank).group('fossil', 'status').count
        delete_original_combinations count
        self.class.massage_count count, rank, statistics
      end
      statistics
    end

  private
    def delete_original_combinations count
      count.delete [true, 'original combination']
      count.delete [false, 'original combination']
    end
end
