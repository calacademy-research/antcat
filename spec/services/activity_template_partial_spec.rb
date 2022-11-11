# frozen_string_literal: true

require 'rails_helper'

describe ActivityTemplatePartial do
  context "with `event`" do
    context "when there is a partial for `event`" do
      it "returns the template for the `event`" do
        expect(described_class[event: Activity::ELEVATE_SUBSPECIES_TO_SPECIES, trackable_type: 'Taxon']).
          to eq "activities/templates/events/elevate_subspecies_to_species"
      end
    end

    context "when there is no partial for `event`" do
      it "returns the template for the `trackable_type`" do
        expect(described_class[event: 'Pizza', trackable_type: 'Taxon']).
          to eq "activities/templates/trackable_types/taxon"
      end
    end
  end

  context "without `event`" do
    it "returns the template for the `trackable_type`" do
      expect(described_class[event: nil, trackable_type: 'Journal']).
        to eq "activities/templates/trackable_types/journal"
    end
  end

  context "when there is no partial matching `event` or `trackable_type`" do
    specify do
      expect { described_class[event: nil, trackable_type: 'Pizza'] }.
        to raise_error('activity template missing')
    end
  end
end
