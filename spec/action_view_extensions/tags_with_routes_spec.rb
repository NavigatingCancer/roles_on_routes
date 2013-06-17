require 'rolesonroutes/action_view_extensions/tags_with_roles'
require 'ostruct'

class AnimalsController
end

class Animal
  def self.model_name
    OpenStruct.new({ singular_route_key: 'animal' })
  end

  def to_param
    1
  end
end

describe 'ActionDispatch::Routing::Routeset#roles_for' do
  describe '#link_to_with_roles' do
    let(:routeset) { ActionDispatch::Routing::RouteSet.new }
    let(:link_text)   { 'Link Text' }
    let(:action_view) { ActionView::Base.new }

    before do
      routeset.draw do
        resources :animals, roles: :staff, action_roles: { show: [:staff, :not_staff] }
      end

      RolesOnRoutes::Configuration.routeset_containing_roles = routeset
      routeset.install_helpers
      action_view._routes = routeset
    end

    subject { action_view.link_to_with_roles(link_text, polymorphic_array) }

    context 'animals index' do
      let (:polymorphic_array) { [:animals] }
      it { should include('<a href="/animals"') }
      it { should include(link_text) }
      it { should include("#{RolesOnRoutes::TAG_ROLES_ATTRIBUTE}=\"staff\"") }
    end

    context 'animals show' do
      let (:polymorphic_array) { [Animal.new] }
      it { should include('<a href="/animals/1"') }
      it { should include("#{RolesOnRoutes::TAG_ROLES_ATTRIBUTE}=\"staff not_staff\"") }
    end
  end

  describe '#div_with_roles' do
    let(:action_view)    { ActionView::Base.new }
      let(:roles)        { [:staff, :admin] }
    let(:arbitrary_text) { 'Some arbitrary text' }

    subject do
      action_view.div_with_roles(roles) do
        arbitrary_text
      end
    end

    context 'single role' do
      let(:roles) { :staff }
      it { should == "<div #{RolesOnRoutes::TAG_ROLES_ATTRIBUTE}=\"staff\">#{arbitrary_text}</div>" }
    end

    context 'multiple roles' do
      it { should == "<div #{RolesOnRoutes::TAG_ROLES_ATTRIBUTE}=\"staff admin\">#{arbitrary_text}</div>" }
    end

    context 'no block' do
      subject { action_view.div_with_roles(roles) }
      it { expect{ subject }.to raise_error }
    end
  end
end