class Views::Base < Erector::Widgets::Page

  def head_content
    super
    css '/stylesheets/application.css'
    javascript_include_tag '/javascripts/ext/jquery-1.4.2.js'
    jquery '$(":input:visible:enabled:first").focus();'
  end

  def page_title
    "ANTBIB"
  end

  def body_content
    div :id => 'container' do
      a (:href => references_path) {h3 'ANTBIB'}
      hr
      container_content
    end
  end
end
