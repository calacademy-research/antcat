require 'spec_helper'

describe Bolton::Catalog::Subfamily::Importer do
  before do
    @importer = Bolton::Catalog::Subfamily::Importer.new
  end

  describe "Importing HTML" do
    def make_contents content
      %{<html><body><div class=Section1>#{content}</div></body></html>}
    end

    describe "Importing the catalog" do

      it "should parse the family, then the subfamilies" do
        @importer.should_receive(:parse_family).ordered
        @importer.should_receive(:parse_supersubfamilies).ordered
        @importer.import_html make_contents %{
    <p class=MsoNormal align=center style='text-align:center'><b style='mso-bidi-font-weight:
    normal'><span lang=EN-GB>FAMILY FORMICIDAE<o:p></o:p></span></b></p>
        }
      end

    end

    it "should parse each supersubfamily" do
      @importer.should_receive(:parse_family).and_return {
        Factory :subfamily, :name => 'Aneuretinae'
      }
      @importer.should_receive(:parse_supersubfamily).ordered.and_return true
      @importer.should_receive(:parse_supersubfamily).ordered.and_return false

      @importer.import_html make_contents %{
<p class=MsoNormal align=center style='text-align:center'><b style='mso-bidi-font-weight:
normal'><span lang=EN-GB>THE DOLICHODEROMORPHS: SUBFAMILIES ANEURETINAE AND
DOLICHODERINAE<o:p></o:p></span></b></p>

<p class=MsoNormal style='margin-right:-1.25pt;text-align:justify'><span
lang=EN-GB><o:p>&nbsp;</o:p></span></p>

<p class=MsoNormal align=center style='text-align:center'><b style='mso-bidi-font-weight:
normal'><span lang=EN-GB>THE FORMICOMORPHS: SUBFAMILY FORMICINAE<o:p></o:p></span></b></p>
      }

    end
  end
end
