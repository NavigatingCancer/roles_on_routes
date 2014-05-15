require 'roles_on_routes/base'
require 'action_dispatch/routing/mapper_override'
require 'action_view'
require 'action_controller'

module RolesOnRoutes
  module ActionViewExtensions
    module TagsWithRoles
      def link_to_with_roles(*args, &block)
        if block_given?
          html_options_index = 1
          options = args.first
        else
          html_options_index = 2
          options = args.second
        end
        html_options = args[html_options_index] ||= {}
        html_options.merge!({ RolesOnRoutes::TAG_ROLES_ATTRIBUTE => roles_from_options(options).join(' ') })
        link_to *args, &block
      end

      def content_tag_with_roles(tag_type, roleset, options={}, &block)
        raise 'Must provide a block to content_with_roles methods' unless block_given?
        content_tag(tag_type, options.merge({ RolesOnRoutes::TAG_ROLES_ATTRIBUTE => ::RolesOnRoutes::Configuration.role_collection[roleset].join(' ') }), &block)
      end

      [:div, :li, :tr, :td, :ul, :ol].each do |tag_type|
        define_method("#{tag_type}_with_roles") do |roles, options={}, &block|
          content_tag_with_roles(tag_type, roles, options, &block)
        end
      end

    private

      def roles_from_options(options)
        RolesOnRoutes::Base.roles_for(url_for(options))
      end
    end
  end
end

ActionView::Base.send :include, RolesOnRoutes::ActionViewExtensions::TagsWithRoles
