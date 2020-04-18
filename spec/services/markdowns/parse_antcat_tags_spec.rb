# frozen_string_literal: true

require 'rails_helper'

describe Markdowns::ParseAntcatTags do
  describe "#call" do
    it "does not remove <i> tags" do
      content = "<i>italics<i><i><script>xss</script></i>"
      expect(described_class[content]).to eq "<i>italics<i><i>xss</i></i></i>"
    end
  end
end
