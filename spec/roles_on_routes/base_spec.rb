require 'roles_on_routes'
require 'ostruct'
require 'debugger'

class AnimalsController
end
class RatsController
end
class CatsController
end

describe RolesOnRoutes::Base do
  let(:routeset)    { ActionDispatch::Routing::RouteSet.new }

  before do
    r = roleset # Scoping problem when defining routes if only set in lets

    RolesOnRoutes::Configuration.define_roles do
      add :not_staff, [:not_staff]
      add :admin,     [:admin]
      add :penguins,  [:penguin_handler, :penguin_trainer]
      add :staff_block do
        [:staff]
      end
    end

    routeset.draw do
      scope roles: :staff_block do
        resources :animals, action_roles: { not_staff: :show } do
          resources :cats
          resources :rats, action_roles: { admin: [:index] }
          member do
            get :penguin, roles: :penguins
          end
        end
      end
    end
    RolesOnRoutes::Configuration.routeset_containing_roles = routeset
  end


  describe '#roles_for' do

    subject { RolesOnRoutes::Base.roles_for(path, action) }

    let(:path)    { '/animals' }
    let(:action)  { 'GET' }
    let(:roleset) { [:staff] }

    context 'non-nested route' do
      context 'with base role definition' do
        let (:path) { '/animals' }
        it { should == [:staff] }
      end

      context 'with action role override' do
        let (:path) { '/animals/1' }
        it { should == [:not_staff] }
      end
    end

    context 'nested route' do
      let (:path) { '/animals/1/cats' }
      context 'with no role definition' do
        it 'inherits parent roles' do
          subject.should == [:staff]
        end
      end

      context 'with parent action role' do
        let (:path) { '/animals/1/cats/1' }
        it 'does not inherit action_roles' do
          subject.should == [:staff]
        end
      end

      context 'with action role' do
        let (:path) { '/animals/1/rats' }
        it 'overrides role' do
          subject.should == [:admin]
        end
      end

      context 'without action role' do
        let (:path) { '/animals/1/rats/2' }
        it 'does not override' do
          subject.should == [:staff]
        end
      end

      context 'member routing' do
        context 'defines non-RESTful roles without action_roles hash' do
          let (:path) { '/animals/1/penguin' }
          it 'overrides role' do
            subject.should == [:penguin_handler, :penguin_trainer]
          end
        end
      end
    end

    context 'bad path' do
      let (:path) { '/donkey' }
      it 'raises an exception' do
        expect{ subject }.to raise_error(ActionController::RoutingError)
      end
    end
  end
end
