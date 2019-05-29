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
      Rails.logger.info "RolesOnRoutes authorize_from_role_intersection"
      return true if ::RolesOnRoutes::Base.authorizes?(request, current_user_roles)
      Rails.logger.info "authorizes FAILED ! redirecting now"

      # FIXME this redirection works but RolesOnRoutes should only do AuthZ not
      # AuthN ??
      # redirect_to '/auth/auth0'
      # return
      role_authorization_failure_response
    end

    def current_user_roles
      raise NoMethodError, 'A controller which includes this module must define a current_user_roles method' unless defined?(super)
      super
    end

    # If you override this, make sure it calls redirect_to or render in order
    # to protect against unauthorized access and CSRF.
    def role_authorization_failure_response
      raise NoMethodError, 'A controller which includes this module must define role_authorization_failure_response'
    end

  end
end
