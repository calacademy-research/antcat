class Views::References::New < Views::Base
  def container_content
    h2 "Add Reference"

    form_for([:reference, @reference], :url => references_path) do |f|
      widget Views::References::Form, :f => f, :submit_text => "Add"
      p do
        link_to 'Back', references_path
      end
    end
  end
end
