# frozen_string_literal: true

require 'rails_helper'

describe DatabaseScripts::Render do
  let(:database_script) { DatabaseScripts::DatabaseTestScript.new }
  let(:render) { described_class.new(database_script) }

  describe "#call" do
    context "when the script has not defined `#render`" do
      it "can render an ActiveRecord::Relation" do
        create :any_reference
        allow(database_script).to receive(:results).and_return Reference.all

        expect(render.call).to match "<ul>\n<li>"
      end

      it "cannot render 'asdasda'" do
        allow(database_script).to receive(:results).and_return 'asdasda'
        expect(render.call).to match "Error: cannot implicitly render results."
      end
    end
  end
end
