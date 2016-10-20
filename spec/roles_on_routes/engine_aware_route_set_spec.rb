require 'rails_helper'

describe RolesOnRoutes::EngineAwareRouteSet, :type => :routing do
  let(:routing_param_extras) { {} }
  let(:routing_params) do
    {
      controller: 'animals/main',
      action: action,
    }.merge(routing_param_extras)
  end
  let(:action) { 'index' }

  context 'in an application' do
    context '/' do
      it 'routes to animals/main#index' do
        expect(get: '/').to route_to(routing_params)
      end
    end

    context '/inside' do
      let(:routing_param_extras) { { :roles => :staff_block } }
      it 'routes to animals/main#index' do
        expect(get: '/inside').to route_to(routing_params)
      end
    end

    context '/inside-out' do
      it 'routes to animals/main#index' do
        expect(get: '/inside-out').not_to be_routable
      end
    end

    context '/outside' do
      let(:routing_param_extras) { { :roles => :staff_block } }
      it 'routes to animals/main#index' do
        expect(get: '/outside').to route_to(routing_params)
      end
    end

    context '/outside-out' do
      it 'routes to animals/main#index' do
        expect(get: '/outside-out').not_to be_routable
      end
    end

  end

  context 'in an Engine' do
    routes { Animals::Engine.routes }
    let(:action) { 'engine' }

    context '/' do
      it 'routes to animals/main#engine' do
        expect(get: '/').to route_to(routing_params)
      end
    end

    context '/inside' do
      let(:routing_param_extras) { { :roles => :staff_block } }
      it 'routes to animals/main#engine' do
        expect(get: '/inside').to route_to(routing_params)
      end
    end

    context '/inside-out' do
      it 'routes to animals/main#engine' do
        expect(get: '/inside-out').not_to be_routable
      end
    end

    context '/outside' do
      let(:routing_param_extras) { { :roles => :staff_block } }
      it 'routes to animals/main#engine' do
        expect(get: '/outside').to route_to(routing_params)
      end
    end

    context '/outside-out' do
      it 'routes to animals/main#engine' do
        expect(get: '/outside-out').not_to be_routable
      end
    end
  end
end
