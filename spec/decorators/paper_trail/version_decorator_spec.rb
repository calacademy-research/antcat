require 'rails_helper'

describe PaperTrail::VersionDecorator do
  describe "#revision_history_link" do
    let(:item) { build_stubbed :issue }
    let(:version) { build_stubbed :version, item: item }

    specify do
      expect(version.decorate.revision_history_link).
        to eq %(<a class="btn-normal btn-tiny" href="/issues/#{item.id}/history">History</a>)
    end
  end
end
