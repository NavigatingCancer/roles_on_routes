require 'roles_on_routes/base'
require 'active_support/concern'
require 'abstract_controller'

module RolesOnRoutes
  module AuthorizesFromRolesController
    extend ActiveSupport::Concern

    included do
      before_filter :authorize_from_role_intersection
    end

    private

    def authorize_from_role_intersection
      #binding.pry
      return true if ::RolesOnRoutes::Base.authorizes?(request, current_user_roles)
      role_authorization_failure_response
    end

    def current_user_roles
      raise NoMethodError, 'A controller which includes this module must define a current_user_roles method' unless defined?(super)
      super
    end

    def role_authorization_failure_response
      render nothing: true, status: :unauthorized
    end

  end
end
