require 'roles_on_routes/action_view_extensions/tags_with_roles'
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
  before do
    RolesOnRoutes::Configuration.define_roles do
      add :all,   [:staff, :not_staff]
      add :staff, :staff
      add :dynamic_group do |params|
        [ "foobar_#{params[:id]}" ]
      end
    end
  end

  describe '#link_to_with_roles' do
    let(:routeset) { ActionDispatch::Routing::RouteSet.new }
    let(:link_text)   { 'Link Text' }
    let(:action_view) { ActionView::Base.new }

    before do
      routeset.draw do
        resources :animals, roles: :staff, action_roles: { all: :show }
      end

      RolesOnRoutes::Configuration.routeset_containing_roles = routeset
      routeset.install_helpers
      action_view._routes = routeset
      allow(action_view).to receive(:request).and_return(OpenStruct.new(env: {}))
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
    let(:roles)          { :staff }
    let(:arbitrary_text) { 'Some arbitrary text' }

    subject do
      action_view.div_with_roles(roles) do
        arbitrary_text
      end
    end

    it { should == "<div #{RolesOnRoutes::TAG_ROLES_ATTRIBUTE}=\"staff\">#{arbitrary_text}</div>" }

    context 'no block' do
      subject { action_view.div_with_roles(roles) }
      it { expect{ subject }.to raise_error StandardError }
    end
  end

  describe '#content_tag_with_roles' do
    let(:action_view)    { ActionView::Base.new }
    let(:roles)          { :staff }
    let(:arbitrary_text) { 'Some arbitrary text' }

    subject do
      action_view.content_tag_with_roles(:td, roles) do
        arbitrary_text
      end
    end

    it { should == "<td #{RolesOnRoutes::TAG_ROLES_ATTRIBUTE}=\"staff\">#{arbitrary_text}</td>" }

    context 'no block' do
      subject { action_view.content_tag_with_roles(:td, roles) }
      it { expect{ subject }.to raise_error StandardError }
    end

    context 'with dynamic role groups' do
      let(:roles) { :dynamic_group }

      before do
        controller = double('controller')
        expect(controller).to receive(:params).and_return({ id: 123 })
        expect(action_view).to receive(:controller).and_return(controller)
      end

      it { should == "<td #{RolesOnRoutes::TAG_ROLES_ATTRIBUTE}=\"foobar_123\">#{arbitrary_text}</td>" }
    end
  end
end
