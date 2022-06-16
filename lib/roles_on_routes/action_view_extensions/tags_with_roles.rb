require 'roles_on_routes/base'
require 'action_dispatch/routing/mapper_override'
require 'action_view'
require 'action_controller'

# WARNING:
# These methods hide the html using JavaScript after it has been sent to the
# client-side. They are not secure!

module RolesOnRoutes
  module ActionViewExtensions
    module TagsWithRoles
      # @deprecated
      def link_to_with_roles(link_text, poly_array, options={})
        link_to link_text, poly_array, options.merge({ RolesOnRoutes::TAG_ROLES_ATTRIBUTE => roles_from_polymorphic_array(poly_array).join(' ') })
      end

      # @deprecated
      def content_tag_with_roles(tag_type, roleset, options={}, &block)
        raise 'Must provide a block to content_with_roles methods' unless block_given?
        roles = ::RolesOnRoutes::Configuration.role_collection[roleset].flat_map do |definition|
          definition.is_a?(Proc) ? instance_exec(params, &definition) : definition
        end
        content_tag(tag_type, options.merge({ RolesOnRoutes::TAG_ROLES_ATTRIBUTE => roles.join(' ') }), &block)
      end

      [:div, :li, :tr, :td, :ul, :ol].each do |tag_type|
        # @deprecated
        define_method("#{tag_type}_with_roles") do |roles, options={}, &block|
          content_tag_with_roles(tag_type, roles, options, &block)
        end
      end

    private

      def roles_from_polymorphic_array(array)
        RolesOnRoutes::Base.roles_for(url_for(array), request.env)
      end
    end
  end
end

ActionView::Base.send :include, RolesOnRoutes::ActionViewExtensions::TagsWithRoles

module ActionDispatch
  module Routing
    class RouteSet
      def install_helpers(destinations = [ActionController::Base, ActionView::Base], regenerate_code = false)
        Array(destinations).each { |d| d.module_eval {
          include ActionView::Helpers;
          include ActionDispatch::Routing::UrlFor
          } }
        named_routes.install(destinations, regenerate_code)
      end
      class NamedRouteCollection
        def install(destinations = [ActionController::Base,ActionView::Base], regenerate = false)
          reset! if regenerate
          Array(destinations).each do |dest|
            dest.__send__(:include, @module)
          end
        end
      end
    end
  end
end