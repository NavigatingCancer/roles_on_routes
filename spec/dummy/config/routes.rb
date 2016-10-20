module Animals
  class Engine < ::Rails::Engine
  end

  class MainController < ::ApplicationController
    include RolesOnRoutes::AuthorizesFromRolesController
    def index
    end

    def engine
    end

    def current_user_roles
      [:staff]
    end
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
end
