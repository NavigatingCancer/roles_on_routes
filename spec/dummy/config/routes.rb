module Animals
  class Engine < ::Rails::Engine
  end

  class MainController < ::ApplicationController
    include RolesOnRoutes::AuthorizesFromRolesController
    def index
    end

    def role_proc
      roles = RolesOnRoutes::Base.roles_for('/test-role-proc', request.env)
      render text: roles.join(',')
    end

    def engine
    end

    def current_user_roles
      [:staff]
    end
  end
end

class SetExtraParameterConstraint
  def self.matches?(request)
    RolesOnRoutes::Base.role_params(request.env)[:test_role] = :staff
    true
  end
end

Animals::Engine.routes.draw do
  root to: 'animals/main#engine'

  scope roles: :staff_block, constraints: lambda {|req| true } do
    get '/inside', to: 'animals/main#engine'
  end
  scope roles: :staff_block, constraints: lambda {|req| false } do
    get '/inside-out', to: 'animals/main#engine'
  end
  get '/outside', constraints: lambda {|req| true }, to: 'animals/main#engine', roles: :staff_block
  get '/outside-out', constraints: lambda {|req| false }, to: 'animals/main#engine', roles: :staff_block
end

Rails.application.routes.draw do
  RolesOnRoutes::Configuration.define_roles do
    add :not_staff, [:not_staff]
    add :admin,     [:admin]
    add :penguins,  [:penguin_handler, :penguin_trainer]
    add :staff_block do
      [:staff]
    end
    add :role_proc do |params|
      [params[:test_role]]
    end
  end

  root to: 'animals/main#index'
  mount Animals::Engine => '/animals'

  scope roles: :staff_block, constraints: lambda {|req| true } do
    get '/inside', to: 'animals/main#index'
  end
  scope roles: :staff_block, constraints: lambda {|req| false } do
    get '/inside-out', to: 'animals/main#index'
  end
  get '/outside', constraints: lambda {|req| true }, to: 'animals/main#index', roles: :staff_block
  get '/outside-out', constraints: lambda {|req| false }, to: 'animals/main#index', roles: :staff_block

  # This route is for the request integration test to verify that parameters set in a constraint
  # can are available in the engine aware route set
  get '/test-role-proc', constraints: SetExtraParameterConstraint, to: 'animals/main#role_proc', roles: :role_proc
end
