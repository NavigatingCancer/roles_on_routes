require 'roles_on_routes/base'
require 'action_dispatch/routing/mapper_override'
require 'action_view'
require 'action_controller'

module RolesOnRoutes
  module ActionViewExtensions
    module TagsWithRoles
      def link_to_with_roles(link_text, poly_array, options={})
        link_to link_text, poly_array, options.merge({ RolesOnRoutes::TAG_ROLES_ATTRIBUTE => roles_from_polymorphic_array(poly_array).join(' ') })
      end

      def content_tag_with_roles(tag_type, roleset, options={}, &block)
        raise 'Must provide a block to content_with_roles methods' unless block_given?
        roles = ::RolesOnRoutes::Configuration.role_collection[roleset].flat_map do |definition|
          definition.is_a?(Proc) ? instance_exec(params, &definition) : definition
        end
        content_tag(tag_type, options.merge({ RolesOnRoutes::TAG_ROLES_ATTRIBUTE => roles.join(' ') }), &block)
      end

      [:div, :li, :tr, :td, :ul, :ol].each do |tag_type|
        define_method("#{tag_type}_with_roles") do |roles, options={}, &block|
          content_tag_with_roles(tag_type, roles, options, &block)
        end
      end

    private

      def roles_from_polymorphic_array(array)
        RolesOnRoutes::Base.roles_for(url_for(array))
      end
    end
  end
end

ActionView::Base.send :include, RolesOnRoutes::ActionViewExtensions::TagsWithRoles
