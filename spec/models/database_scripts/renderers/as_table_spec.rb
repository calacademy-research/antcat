# frozen_string_literal: true

require 'rails_helper'

class AsTableDummy < DatabaseScripts::DatabaseTestScript
  def as_table
    renderer = DatabaseScripts::Renderers::AsTable.new(cached_results)
    yield renderer
    renderer.render
  end
end

describe DatabaseScripts::Renderers::AsTable do
  let(:dummy) { AsTableDummy.new }

  describe "#render" do
    context 'with results' do
      let!(:taxon_1) { create :any_taxon }

      it 'renders the supplied `results` as an HTML table' do
        rendered =
          dummy.as_table do |t|
            t.header 'Taxon', 'Status'

            t.rows(Taxon.all) do |taxon|
              [taxon.id, taxon.status]
            end
          end

        expect(rendered.squish).to eq <<~HTML.squish
          <table class="table-striped tablesorter mt-8">
            <thead>
              <tr>
                <th>Taxon</th>
                <th>Status</th>
              </tr>
            </thead>
            <tbody><tr><td>#{taxon_1.id}</td><td>#{taxon_1.status}</td></tr>
            </tbody>
          </table>
        HTML
      end
    end

    context 'with `caption` and `info`' do
      specify do
        rendered =
          dummy.as_table do |t|
            t.caption "caption field"
            t.info "info field"
            t.header 'header1', 'header2'

            t.rows(['pizza']) do |string|
              [string]
            end
          end

        expect(rendered.squish).to eq <<~HTML.squish
          <table class="table-striped tablesorter mt-8">
            <caption>caption field</caption>
            <caption>info field</caption>
            <thead>
              <tr>
                <th>header1</th>
                <th>header2</th>
              </tr>
            </thead>
            <tbody><tr><td>pizza</td></tr>
            </tbody>
          </table>
        HTML
      end
    end

    context 'when the block yields a falsey value' do
      let!(:taxon_1) { create :any_taxon }
      let!(:taxon_2) { create :any_taxon }

      it 'skips that row' do
        rendered =
          dummy.as_table do |t|
            t.header 'Taxon', 'Status'

            t.rows(Taxon.all) do |taxon|
              next if taxon.id == taxon_1.id
              [taxon.id, taxon.status]
            end
          end

        expect(rendered.squish).to eq <<~HTML.squish
          <table class="table-striped tablesorter mt-8">
            <thead>
              <tr>
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
