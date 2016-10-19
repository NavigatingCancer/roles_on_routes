require 'roles_on_routes/configuration'
require 'roles_on_routes/role_collection'

module RolesOnRoutes
  class Base
    class << self

      def authorizes?(request, user_roles)
        route_roles = roles_for(request.path, request.env)
        (Array.wrap(user_roles) & route_roles).any?
      end

      def roles_for(path, environment={})
        path_params = Configuration.routeset_containing_roles.recognize_path(path, environment)
        action = path_params[:action]
        roleset_name = action_roles_from_path(path_params, action) || roles_from_path(path_params)
        Configuration.role_collection.execute(roleset_name, path_params)
      end

      private

      def action_roles_from_path(pathset, action)
        return unless pathset[:action_roles].present?
        raise 'Action roles must be a hash' unless pathset[:action_roles].is_a?(Hash)

        pathset[:action_roles].each do |roleset, actions|
          if actions.is_a?(Array)
            return roleset if actions.include?(action.to_sym)
          else
            return roleset if actions == action.to_sym
          end
        end
        nil
      end

      def roles_from_path(pathset)
        pathset[:roles]
      end
    end
  end
end
