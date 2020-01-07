require 'rails_helper'

class AsTableDummy < DatabaseScripts::DatabaseTestScript
  include DatabaseScripts::Renderers::AsTable
end

describe DatabaseScripts::Renderers::AsTable do
  let(:dummy) { AsTableDummy.new }

  describe "#as_as_table" do
    context "with explicit `results`" do
      let!(:taxon_1) { create :family }

      it 'renders the supplied `results` as an HTML table' do
        rendered =
          dummy.as_table do |t|
            t.caption "My favorite ants"
            t.header :taxon, :status

            t.rows(Taxon.all) do |taxon|
              [taxon.id, taxon.status]
            end
          end

        expect(rendered.squish).to eq <<~HTML.squish
          <table class="tablesorter hover margin-top">
            <caption>My favorite ants</caption>
            <thead><tr>
              <th>Taxon</th>
              <th>Status</th>
              </tr>
            </thead>
            <tbody><tr><td>#{taxon_1.id}</td><td>#{taxon_1.status}</td></tr>
            </tbody>
          </table>
        HTML
      end

      context 'when the block yields a falsey value' do
        let!(:taxon_2) { create :family }

        it 'skips that row' do
          rendered =
            dummy.as_table do |t|
              t.caption "My favorite ants"
              t.header :taxon, :status

              t.rows(Taxon.all) do |taxon|
                next if taxon.id == taxon_1.id
                [taxon.id, taxon.status]
              end
            end

          expect(rendered.squish).to eq <<~HTML.squish
            <table class="tablesorter hover margin-top">
              <caption>My favorite ants</caption>
              <thead><tr>
                <th>Taxon</th>
                <th>Status</th>
                </tr>
              </thead>
              <tbody><tr><td>#{taxon_2.id}</td><td>#{taxon_2.status}</td></tr>
              </tbody>
            </table>
          HTML
        end
      end
    end
  end
end
