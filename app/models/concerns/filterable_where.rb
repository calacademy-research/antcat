module FilterableWhere
  extend ActiveSupport::Concern

  module ClassMethods
    def filter(filter_params)
      results = self.all
      filter_params.each do |key, value|
        results = results.where(key => value) if value.present?
      end
      results
    end
  end
end
