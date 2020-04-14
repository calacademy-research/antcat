# frozen_string_literal: true

require 'rails_helper'

describe DatabaseScripts::ImplicitRender do
  let(:script) { DatabaseScripts::DatabaseTestScript.new }

  describe "#render" do
    context "when the script has not defined `#render`" do
      it "can render an ActiveRecord::Relation" do
        create :any_reference
        allow(script).to receive(:results).and_return Reference.all

        expect(script.render).to match "<ul>\n<li>"
      end

      it "cannot render 'asdasda'" do
        allow(script).to receive(:results).and_return 'asdasda'
        expect(script.render).to match "Error: cannot implicitly render results."
      end
    end
  end
end
