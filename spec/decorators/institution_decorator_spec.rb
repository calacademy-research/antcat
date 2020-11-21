# frozen_string_literal: true

require 'rails_helper'

describe InstitutionDecorator do
  subject(:decorated) { institution.decorate }

  describe "#grscicoll_url" do
    context "when institution does not have a `grscicoll_identifier`" do
      let(:institution) { build_stubbed :institution }

      specify { expect(decorated.grscicoll_url).to eq nil }
    end

    context "when institution has a `grscicoll_identifier`" do
      let(:institution) do
        build_stubbed :institution, grscicoll_identifier: 'institution/e6e9d21b-faf8-4698-95e6-bacc55860a95'
      end

      specify do
        expect(decorated.grscicoll_url).
          to eq "https://www.gbif.org/grscicoll/institution/e6e9d21b-faf8-4698-95e6-bacc55860a95"
      end
    end
  end
end
