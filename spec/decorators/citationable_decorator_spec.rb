# frozen_string_literal: true

require 'rails_helper'

describe CitationableDecorator do
  include TestLinksHelpers

  subject(:decorated) { described_class.new(citationable) }

  describe '#link_to_citationable' do
    context "with a `citationable` that is a `Protonym`" do
      let(:citationable) { create :protonym }

      specify { expect(decorated.link_to_citationable).to eq protonym_link(citationable) }
    end
  end
end
