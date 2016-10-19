require 'rails_helper'
require 'roles_on_routes/roles_on_routes_controller'

class ArbitraryController < ActionController::Base
  include RolesOnRoutes::AuthorizesFromRolesController

  private

  def current_user_roles
    [:user_roles]
  end
end

describe ArbitraryController do
  describe '#authorize_from_role_intersection' do
    let (:controller) { ArbitraryController.new }
    let (:fake_environment) { { 'KEY' => 'SOME ENVIRONMENT'} }
    subject { controller.send(:authorize_from_role_intersection) }

    before do
      expect(controller).to receive(:request).and_return(OpenStruct.new(path: '/arbitrary', env: fake_environment ))
      expect(RolesOnRoutes::Base).to receive(:roles_for).with('/arbitrary', fake_environment).and_return(roles_from_routes)
    end

    context 'roles match' do
      let(:roles_from_routes) { [:user_roles] }
      before { expect(controller).not_to receive(:role_authorization_failure_response) }
      it { should be true }
    end

    context 'roles dont match' do
      let(:roles_from_routes) { [:danger_zone] }
      before { expect(controller).to receive(:role_authorization_failure_response).and_return(true) }
      it { should be true }
    end
  end

  describe '#current_user_roles' do
    subject { ArbitraryController.new.send(:current_user_roles) }

    context 'current_user_roles isnt defined' do
      before { ArbitraryController.send(:remove_method, :current_user_roles) }
      it { expect{ subject }.to raise_error NoMethodError }
    end

    it { is_expected.to eq [:user_roles] }
  end
end
