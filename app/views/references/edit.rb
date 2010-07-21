class Views::References::Edit < Views::Base
  def container_content
    h2 "Edit Reference"

    form_for([:reference, @reference], :method => "put", :url => { :controller => "references", :action => "update" }) do |f|
      widget Views::References::Form, :f => f
      p do
        link_to 'Back', references_path
      end
    end
  end
end
