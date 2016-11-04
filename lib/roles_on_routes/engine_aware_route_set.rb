module RolesOnRoutes
  class EngineAwareRouteSet

    def self.for(app)
      new(app.routes)
    end

    def initialize(main_routeset)
      @main_routeset = main_routeset
    end

    def recognize_path(path, environment={})
      environment.merge!('PATH_INFO' => path)
      route_match = @main_routeset.router.send(:find_routes, environment).first

      if route_match
        journey_route = route_match.last
        app = journey_route.app
        # Peel off the constraints
        while app.respond_to?(:constraints)
          app = app.app
        end

        engine = app
        if engine.respond_to?(:routes)
          begin
            engine_path = path.gsub(journey_route.path.to_regexp, '')
            return params_from_app_and_path_and_rack_enviroment(engine.routes, engine_path, environment)
          rescue ActionController::RoutingError
            Rails.logger.info("RoutingError occurred applying RolesOnRoutes to an engine")
          end
        end
      end

      params_from_app_and_path_and_rack_enviroment(@main_routeset, path, environment)
    end

    def params_from_app_and_path_and_rack_enviroment(routes, path, environment)
      uri = "#{environment['rack.url_scheme']}://#{environment['HTTP_HOST']}#{path}"
      env = {
        method: environment['REQUEST_METHOD'].dup,
        extras: environment['QUERY_STRING'].dup,
      }
      routes.recognize_path(uri, env).tap do |path_parameters|
        #append any extra params that roles_on_routes may want
        RolesOnRoutes::Base.role_params(environment).each do |key,value|
          path_parameters[key] = value
        end
      end
    end
  end
end
