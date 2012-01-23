# coding: UTF-8
require 'spec_helper'

describe Bolton::Catalog::Subfamily::Importer do
  before do
    @importer = Bolton::Catalog::Subfamily::Importer.new
  end

  describe "Importing HTML" do
    def make_contents content
      %{<html><body><div class=Section1>#{content}</div></body></html>}
    end

    it "should parse the family, then the supersubfamilies" do
      @importer.should_receive(:parse_family).ordered
      @importer.should_receive(:parse_supersubfamilies).ordered
      @importer.import_html make_contents %{
  <p class=MsoNormal align=center style='text-align:center'><b style='mso-bidi-font-weight:
  normal'><span lang=EN-GB>FAMILY FORMICIDAE<o:p></o:p></span></b></p>
      }
    end

    it "should parse a supersubfamily" do
      @importer.should_receive(:parse_family).ordered
      @importer.should_receive(:parse_genera_lists).ordered
      @importer.should_receive(:parse_subfamily).ordered.and_return false
      #@importer.should_receive(:parse_genera_lists).ordered
      #@importer.should_receive(:parse_subfamily).ordered.and_return false

      @importer.import_html make_contents %{
<p><b>THE DOLICHODEROMORPHS: SUBFAMILIES ANEURETINAE AND DOLICHODERINAE</p>
<p>THE FORMICOMORPHS: SUBFAMILY FORMICINAE</p>
      }
    end

  end
end
