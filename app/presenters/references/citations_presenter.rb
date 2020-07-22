# frozen_string_literal: true

# [grep:unify_citations].
module References
  class CitationsPresenter
    attr_private_initialize :reference

    def any_citations?
      citations.exists? || citations_from_type_names.exists?
    end

    def each_citation
      citations.order_by_pages + citations_from_type_names.order_by_pages
    end

    private

      delegate :citations, :citations_from_type_names, to: :reference, private: true
  end
end
