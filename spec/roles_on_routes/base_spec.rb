require 'rails_helper'
require 'roles_on_routes/base'

class AnimalsController
end
class RatsController
end
class CatsController
end

describe RolesOnRoutes::Base do
  describe '#roles_for' do
    let(:routeset)    { ActionDispatch::Routing::RouteSet.new }
    let(:link_text)   { 'Link Text' }
    let(:action_view) { ActionView::Base.new }
    let(:path)        { '/animals' }
    let(:action)      { 'GET' }
    let(:roleset)     { [:staff] }
    let(:request_environment) do
      {
        'PATH_INFO' => path,
        'REQUEST_METHOD' => action,
      }
    end

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

    subject { RolesOnRoutes::Base.roles_for(path, request_environment) }

    context 'bad path' do
      let (:path) { '/donkey' }
      it { expect{ subject }.to raise_error StandardError }
    end

    context 'animals controller' do
      context 'cats index' do
        let (:path) { '/animals/1/cats' }
        it { should == [:staff] }
      end

      context 'cats show' do
        let (:path) { '/animals/1/cats/2' }
        it { should == [:staff] }
      end

      context 'rats index' do
        let (:path) { '/animals/1/rats' }
        it { should == [:admin] }
      end

      context 'rats show' do
        let (:path) { '/animals/1/rats/2' }
        it { should == [:staff] }
      end

      context 'penguin get' do
        let (:path) { '/animals/1/penguin' }
        it { should == [:penguin_handler, :penguin_trainer] }
      end

      context 'animals index' do
        let (:path) { '/animals' }
        it { should == [:staff] }
      end

      context 'animals show' do
        let (:path) { '/animals/1' }
        it { should == [:not_staff] }
      end
    end
  end
end
