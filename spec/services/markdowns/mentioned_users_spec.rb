require "spec_helper"

describe Markdowns::MentionedUsers do
  describe "#call" do
    let!(:batiatus) { create :user, name: "Batiatus"}
    let!(:joffre) { create :user, name: "Joffre"}

    it "returns existing mentioned users without duplicates" do
      expect(described_class.new(<<-STRING).call).to eq [batiatus, joffre]
        Hello @user#{batiatus.id}, @user#{joffre.id} and @user#{joffre.id}.
        Please call @user9999
      STRING
    end
  end
end
