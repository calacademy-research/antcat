require 'spec_helper'

describe Antweb::Diff do
  before do
    @diff = Antweb::Diff.new
  end

  it "should report no matches when there are none" do
    antcat = ["Myrmicinae\tStenammini\tPropodilobus\t\t\t\tTRUE\tTRUE\t\t\tFoo"]
    antweb = ["Dolichoderinae\tStenammini\tPropodilobus\t\t\t\tTRUE\tTRUE\t\t\tBar"]
    @diff.diff antcat, antweb
    @diff.match_count.should == 0
    @diff.difference_count.should == 0
    @diff.antcat_unmatched_count.should == 1
    @diff.antweb_unmatched_count.should == 1
    @diff.differences.should == []
  end

  it "should report one match when there is one match" do
    antcat = ["Myrmicinae\tStenammini\tPropodilobus\t\t\t\tTRUE\tTRUE\t\t\tFoo"]
    antweb = ["Myrmicinae\tStenammini\tPropodilobus\t\t\t\tTRUE\tTRUE\t\t\tFoo"]
    @diff.diff antcat, antweb
    @diff.match_count.should == 1
    @diff.difference_count.should == 0
    @diff.antcat_unmatched_count.should == 0
    @diff.antweb_unmatched_count.should == 0
    @diff.differences.should == []
  end

  it "should report one difference when there is one difference" do
    antcat = ["Myrmicinae\tStenammini\tPropodilobus\t\t\t\tTRUE\tTRUE\t\t\tFoo"]
    antweb = ["Myrmicinae\tStenammini\tPropodilobus\t\t\t\tTRUE\tTRUE\t\t\tBar"]
    @diff.diff antcat, antweb
    @diff.match_count.should == 0
    @diff.difference_count.should == 1
    @diff.antcat_unmatched_count.should == 0
    @diff.antweb_unmatched_count.should == 0
    @diff.differences.should == [[antcat[0], antweb[0]]]
  end

  it "should handle a mix" do
    antcat = [
      "Myrmicinae\tStenammini\tPropodilobus\t\t\t\tTRUE\tTRUE\t\t\tFoo",
      "Myrmicinae\tStenammini\tPropodilobus\t\t\t\tTRUE\tTRUE\t\t\tWilson",
      "Dolichoderinae\tStenammini\tPropodilobus\t\t\t\tTRUE\tTRUE\t\t\tWilson",
    ]
    antweb = [
      "Myrmicinae\tStenammini\tPropodilobus\t\t\t\tTRUE\tTRUE\t\t\tWilson",
      "Dolichoderinae\tStenammini\tPropodilobus\t\t\t\tTRUE\tTRUE\t\t\tFisher",
      "Ponerinae\tStenammini\tPropodilobus\t\t\t\tTRUE\tTRUE\t\t\tWilson",
    ]
    @diff.diff antcat, antweb
    @diff.match_count.should == 1
    @diff.difference_count.should == 1
    @diff.antcat_unmatched_count.should == 1
    @diff.antweb_unmatched_count.should == 1
    @diff.differences.should == [
      [
        "Dolichoderinae\tStenammini\tPropodilobus\t\t\t\tTRUE\tTRUE\t\t\tWilson",
        "Dolichoderinae\tStenammini\tPropodilobus\t\t\t\tTRUE\tTRUE\t\t\tFisher",
      ]
    ]
  end

  it "should ignore the difference if it's just that AntCat has a genus's tribe but AntWeb doesn't" do
    Factory :genus, :name => 'Adetomyrma', :tribe => Factory(:tribe, :name => 'Aenictini')
    antcat = ["Amblyoponinae\t" + "Aenictini\t" + "Adetomyrma\tfusus\t\t\tTRUE\tTRUE\t\t"]
    antweb = ["Amblyoponinae\t" + "\t"          + "Adetomyrma\tfusus\t\t\tTRUE\tTRUE\t\t"]
    @diff.diff antcat, antweb
    @diff.match_count.should == 1
  end

  it "should ignore the difference if it's just that AntWeb didn't pick up the tribe properly" do
    antcat = ["Myrmicinae\tStenammini\tPropodilobus\t\t\t\tTRUE\tTRUE\t\t"]
    antweb = ["Myrmicinae\tincertae sedis in Stenammini\tPropodilobus\t\t\t\tTRUE\tTRUE\t\t"]
    @diff.diff antcat, antweb
    @diff.match_count.should == 1
  end

  describe "judging the similarity of taxonomic histories" do

    it "should not ignore the difference if the first words aren't the same" do
      antcat = ["Myrmicinae\tStenammini\tPropodilobus\t\t\t\tTRUE\tTRUE\t\t\tFoo"]
      antweb = ["Myrmicinae\tStenammini\tPropodilobus\t\t\t\tTRUE\tTRUE\t\t\tBar"]
      @diff.diff antcat, antweb
      @diff.match_count.should == 0
    end

    it "should ignore the difference if the first words are the same except for case" do
      antcat = ["Myrmicinae\tStenammini\tPropodilobus\t\t\t\tTRUE\tTRUE\t\t\tPropodilobus"]
      antweb = ["Myrmicinae\tStenammini\tPropodilobus\t\t\t\tTRUE\tTRUE\t\t\tPROPODILOBUS"]
      @diff.diff antcat, antweb
      @diff.match_count.should == 1
    end

    it "should not ignore the difference if the first words are the same except for case but the rest isn't a match" do
      antcat = ["Myrmicinae\tStenammini\tPropodilobus\t\t\t\tTRUE\tTRUE\t\t\tPropodilobus Much longer taxonomic history"]
      antweb = ["Myrmicinae\tStenammini\tPropodilobus\t\t\t\tTRUE\tTRUE\t\t\tPROPODILOBUS Different taxonomic history"]
      @diff.diff antcat, antweb
      @diff.match_count.should == 0
    end

    it "should ignore the difference if AntCat is just the name + [junior synonym of]" do
      antcat = ["Myrmicinae\tStenammini\tPropodilobus\t\t\t\tTRUE\tTRUE\t\t\tPropodilobus Much longer taxonomic history"]
      antweb = ["Myrmicinae\tStenammini\tPropodilobus\t\t\t\tTRUE\tTRUE\t\t\tPROPODILOBUS [junior synonym of Athropus ]"]
      @diff.diff antcat, antweb
      @diff.match_count.should == 1
    end

    it "should ignore the difference if AntCat is just the name + [junior syonym of] (misspelling)" do
      antcat = ["Myrmicinae\tStenammini\tPropodilobus\t\t\t\tTRUE\tTRUE\t\t\tPropodilobus Much longer taxonomic history"]
      antweb = ["Myrmicinae\tStenammini\tPropodilobus\t\t\t\tTRUE\tTRUE\t\t\tPROPODILOBUS [junior syonym of Athropus ]"]
      @diff.diff antcat, antweb
      @diff.match_count.should == 1
    end

    it "should ignore the difference if AntCat is just the name + [junior homonym of]" do
      antcat = ["Myrmicinae\tStenammini\tPropodilobus\t\t\t\tTRUE\tTRUE\t\t\tPropodilobus Much longer taxonomic history"]
      antweb = ["Myrmicinae\tStenammini\tPropodilobus\t\t\t\tTRUE\tTRUE\t\t\tPROPODILOBUS [junior homonym of Athropus ]"]
      @diff.diff antcat, antweb
      @diff.match_count.should == 1
    end

    it "should ignore the difference if it's just in the species name author" do
      antcat = ["Myrmicinae\tStenammini\tPropodilobus\tpingorum\t\t\tTRUE\tTRUE\t\t\tPropodilobus Much longer taxonomic history"]
      antweb = ["Myrmicinae\tStenammini\tPropodilobus\tpingorum\tDuBois, 1998\t\tTRUE\tTRUE\t\t\tPROPODILOBUS [junior homonym of Athropus ]"]
      @diff.diff antcat, antweb
      @diff.match_count.should == 1
    end

    it "should ignore the difference if it's just in the country" do
      antcat = ["Myrmicinae\tStenammini\tPropodilobus\tpingorum\t\t\tTRUE\tTRUE\t\t\tPropodilobus Much longer taxonomic history"]
      antweb = ["Myrmicinae\tStenammini\tPropodilobus\tpingorum\t\tBorneo\tTRUE\tTRUE\t\t\tPROPODILOBUS [junior homonym of Athropus ]"]
      @diff.diff antcat, antweb
      @diff.match_count.should == 1
    end

    it "should ignore the difference if it's just in the currently recognized name" do
      antcat = ["Myrmicinae\tStenammini\tPropodilobus\tpingorum\t\t\tTRUE\tTRUE\t\t\tPropodilobus Much longer taxonomic history"]
      antweb = ["Myrmicinae\tStenammini\tPropodilobus\tpingorum\t\t\tTRUE\tTRUE\tPropodilobus\t\tPROPODILOBUS [junior homonym of Athropus ]"]
      @diff.diff antcat, antweb
      @diff.match_count.should == 1
    end

    it "should ignore the difference if it's just in the original combination" do
      antcat = ["Myrmicinae\tStenammini\tPropodilobus\tpingorum\t\t\tTRUE\tTRUE\t\t\tPropodilobus Much longer taxonomic history"]
      antweb = ["Myrmicinae\tStenammini\tPropodilobus\tpingorum\t\t\tTRUE\tTRUE\t\tCombination\tPROPODILOBUS [junior homonym of Athropus ]"]
      @diff.diff antcat, antweb
      @diff.match_count.should == 1
    end

    it "should ignore antweb entries that aren't valid" do
      antcat = ["Myrmicinae\tStenammini\tPropodilobus\tpingorum\t\t\tTRUE\tTRUE\t\t\tPropodilobus Much longer taxonomic history"]
      antweb = ["Myrmicinae\tStenammini\tPropodilobus\tpingorum\t\t\tFALSE\tTRUE\t\tCombination\tPROPODILOBUS [junior homonym of Athropus ]"]
      @diff.diff antcat, antweb
      @diff.match_count.should == 0
      @diff.antcat_unmatched_count.should == 1
    end

    it "should be able to show the unmatched antweb items" do
      antcat = ["Myrmicinae\tStenammini\tPropodilobus\tpingorum\t\t\tTRUE\tTRUE\t\t\tPropodilobus Much longer taxonomic history"]
      antweb = ["Dolichoderinae\tStenammini\tPropodilobus\tpingorum\t\t\tTRUE\tTRUE\t\t\tPROPODILOBUS [junior homonym of Athropus ]"]
      @diff.diff antcat, antweb
      @diff.antweb_unmatched.should == ["Dolichoderinae\tStenammini\tPropodilobus\tpingorum\t\t\tTRUE\tTRUE\t\t\tPROPODILOBUS [junior homonym of Athropus ]"]
    end

  end

  describe "showing where two strings differ" do

    it "should return nil if they're equal" do
      Antweb::Diff.new.match_fails_at('abc', 'abc').should == nil
    end

    it "should return 0 if they differ at the first character" do
      Antweb::Diff.new.match_fails_at('a', 'b').should == 0
    end

    it "should return the size of the shorter string if it's a substring of the other" do
      Antweb::Diff.new.match_fails_at('ab', 'a').should == 1
    end
  
  end

end
