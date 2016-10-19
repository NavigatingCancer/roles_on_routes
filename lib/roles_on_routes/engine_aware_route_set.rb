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
            return engine.routes.recognize_path(engine_path, environment)
          rescue ActionController::RoutingError
            Rails.logger.info("RoutingError occurred applying RolesOnRoutes to an engine")
          end
        end
      end

      uri = "#{environment['rack.url_scheme']}://#{environment['HTTP_HOST']}#{path}"
      extras = {
        method: environment['REQUEST_METHOD'],
        extras: environment['QUERY_STRING'],
      }
      @main_routeset.recognize_path(uri, extras)
    end
  end
end
