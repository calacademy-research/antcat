# frozen_string_literal: true

require 'rails_helper'

describe DatabaseScripts::Render do
  include TestLinksHelpers

  let(:database_script) { DatabaseScripts::DatabaseTestScript.new }
  let(:render) { described_class.new(database_script) }

  describe "#call" do
    context "when the script has defined `#render_as`" do
      before do
        def database_script.render_as
          :as_taxon_table
        end
      end

      it 'render a table for that type' do
        taxon = create :family
        allow(database_script).to receive(:results).and_return Taxon.all
        expect(render.call).to match %(<tbody><tr><td>#{taxon_link(taxon)}</td><td>family</td><td>valid</td></tr>)
      end
    end
  end
end
