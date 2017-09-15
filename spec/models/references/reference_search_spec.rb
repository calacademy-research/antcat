# TODO cleanup spec.

require 'spec_helper'

describe Reference do
  describe ".perform_search" do
    describe "Search parameters" do
      describe "Authors", search: true do
        it "finds the references for all aliases of a given author_name", pending: true do
          pending "broke when search method was refactored"
          # TODO find out where this is used
          bolton = create :author
          bolton_barry = create :author_name, author: bolton, name: 'Bolton, Barry'
          bolton_b = create :author_name, author: bolton, name: 'Bolton, B.'
          bolton_barry_reference = create :book_reference, author_names: [bolton_barry], title: '1', pagination: '1'
          bolton_b_reference = create :book_reference, author_names: [bolton_b], title: '2', pagination: '2'

          expect(described_class.perform_search(authors: [bolton]).map(&:id)).to match(
            [bolton_b_reference, bolton_barry_reference].map(&:id)
          )
        end
      end
    end
  end
end
