# frozen_string_literal: true

require 'rails_helper'

describe HistoryItemQuery do
  subject(:query) { described_class.new }

  describe '#search' do
    let!(:lasius_item) { create :history_item, :taxt, taxt: "Lasius content" }
    let!(:formica_123_item) { create :history_item, :taxt, taxt: "Formica content 123" }

    context "with search type 'LIKE'" do
      specify do
        expect(query.search('cont', 'LIKE')).to match_array [lasius_item, formica_123_item]
        expect(query.search('lasius', 'LIKE')).to match_array [lasius_item]
        expect(query.search('content \d\d\d', 'LIKE')).to match_array []
      end
    end

    context "with search type 'REGEXP'" do
      specify do
        expect(query.search('cont', 'REGEXP')).to match_array [lasius_item, formica_123_item]
        expect(query.search('lasius', 'REGEXP')).to match_array [lasius_item]
        expect(query.search('content [0-9]', 'REGEXP')).to match_array [formica_123_item]
      end
    end

    context "with unknown search type" do
      specify do
        expect { query.search('cont', 'PIZZA') }.to raise_error("unknown search_type PIZZA")
      end
    end
  end

  describe '#exclude_search' do
    let!(:lasius_item) { create :history_item, :taxt, taxt: "Lasius content" }
    let!(:formica_123_item) { create :history_item, :taxt, taxt: "Formica content 123" }

    context "with search type 'LIKE'" do
      specify do
        expect(query.exclude_search('cont', 'LIKE')).to match_array []
        expect(query.exclude_search('lasius', 'LIKE')).to match_array [formica_123_item]
        expect(query.exclude_search('content [0-9]', 'LIKE')).to match_array [lasius_item, formica_123_item]
      end
    end

    context "with search type 'REGEXP'" do
      specify do
        expect(query.exclude_search('cont', 'REGEXP')).to match_array []
        expect(query.exclude_search('lasius', 'REGEXP')).to match_array [formica_123_item]
        expect(query.exclude_search('content [0-9]', 'REGEXP')).to match_array [lasius_item]
      end
    end

    context "with unknown search type" do
      specify do
        expect { query.exclude_search('cont', 'PIZZA') }.to raise_error("unknown search_type PIZZA")
      end
    end
  end
end
