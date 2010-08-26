module ActionController::Routing
  class RouteSet
    class Mapper
        def registerable(routes, mapping)
          routes.resource :registration, :only => [:edit, :update], :as => mapping.raw_path[1..-1], :path_prefix => nil, :path_names => { :new => mapping.path_names[:sign_up] }
        end
    end
  end
end
