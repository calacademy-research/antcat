# frozen_string_literal: true

require 'rails_helper'

describe SoftValidationDecorator do
  let(:decorated) { soft_validation.decorate }

  describe "#format_runtime" do
    let(:taxon) { create :family }
    let(:soft_validation) { SoftValidation.run(taxon, database_script) }
    let(:database_script) { DatabaseScripts::ExtantTaxaInFossilGenera }

    specify { expect(decorated.format_runtime).to match /^\d+ ms$/ }
  end

  describe "#format_runtime_percent" do
    let(:taxon) { create :family }
    let(:soft_validation) { SoftValidation.run(taxon, database_script) }
    let(:database_script) { DatabaseScripts::ExtantTaxaInFossilGenera }

    specify { expect(decorated.format_runtime_percent(20)).to match /^\d+\.\d+%$/ }
  end
end
