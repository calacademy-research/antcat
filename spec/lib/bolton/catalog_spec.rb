require 'spec_helper'

describe Bolton::Catalog do

    describe "Cleaning up taxonomic history" do

      it "should remove all attributes and spans" do
        Bolton::Catalog.new.clean_taxonomic_history(
%{<p><b><span lang="EN-GB">Aneuretinae</span></b><span lang="EN-GB"> Emery, 1913a: 6. Type-genus: <i>Aneuretus</i>.  </span></p>} +
%{<p class=MsoNormal style='margin-left:36.0pt;text-align:justify;text-indent:} +
%{-36.0pt'><b style='mso-bidi-font-weight:normal'><i style='mso-bidi-font-style:} +
%{normal'><span style='color:red'>lundii</span></i></b><i style='mso-bidi-font-style:} +
%{normal'>. Myrmica lundii</i> Guérin-Méneville, 1838: 206 (q.m.) BRAZIL. Roger,} +
%{1863a: 201 (w.); Forel, 1885a: 356 (w.); Wheeler, G.C. 1949: 675 (l.).} +
%{Combination in <i style='mso-bidi-font-style:normal'>Atta</i>: Roger, 1863a:} +
%{200; in <i style='mso-bidi-font-style:normal'>Atta (Acromyrmex</i>): Forel,} +
%{1885a: 356; in <i style='mso-bidi-font-style:normal'>Acromyrmex</i>: Forel,} +
%{1913l: 237. Senior synonym of <i style='mso-bidi-font-style:normal'>bonariensis</i>:} +
%{Gallardo, 1916d: 331; of <i style='mso-bidi-font-style:normal'>risii</i>:} +
%{Santschi, 1925a: 384; of <i style='mso-bidi-font-style:normal'>dubia</i>:} +
%{Gonçalves, 1961: 150. See also: Bruch, 1921: 192. Current subspecies: nominal} +
%{plus <i style='mso-bidi-font-style:normal'><span style='color:blue'>boliviensis,} +
%{carli, decolor, parallelus</span></i>.</p>}
        ).should == 
%{<p><b>Aneuretinae</b> Emery, 1913a: 6. Type-genus: <i>Aneuretus</i>.  </p>} +
%{<p><b><i>lundii</i></b><i>. Myrmica lundii</i> Guérin-Méneville, 1838: 206 (q.m.) BRAZIL. Roger,} +
%{1863a: 201 (w.); Forel, 1885a: 356 (w.); Wheeler, G.C. 1949: 675 (l.).} +
%{Combination in <i>Atta</i>: Roger, 1863a:} +
%{200; in <i>Atta (Acromyrmex</i>): Forel,} +
%{1885a: 356; in <i>Acromyrmex</i>: Forel,} +
%{1913l: 237. Senior synonym of <i>bonariensis</i>:} +
%{Gallardo, 1916d: 331; of <i>risii</i>:} +
%{Santschi, 1925a: 384; of <i>dubia</i>:} +
%{Gonçalves, 1961: 150. See also: Bruch, 1921: 192. Current subspecies: nominal} +
%{plus <i>boliviensis,} +
%{carli, decolor, parallelus</i>.</p>}
    end

  end
end
