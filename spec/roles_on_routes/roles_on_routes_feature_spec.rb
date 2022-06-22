require 'rails_helper'
require 'roles_on_routes/roles_on_routes_controller'

describe 'roles_on_routes integration', :type => :feature do
  before do
    # code ref - roles_on_routes/lib/roles_on_routes/configuration.rb
    # In this file if @routeset_containing_roles is nil then it takes routes from rails application.
    # Other test cases are modifying this variable when we execute whole test suite,
    # hence we are making sure its not defined before running the test case.
    RolesOnRoutes::Configuration.routeset_containing_roles = nil
  end
  scenario 'visit inside' do
    visit inside_path
    expect(page).to have_text("This is animals/main/index")
  end

  scenario 'visit inside out' do
    expect{ visit '/inside-out' }.to raise_error(ActionController::RoutingError)
  end

  scenario 'visit outside' do
    visit outside_path
    expect(page).to have_text("This is animals/main/index")
  end

  scenario 'visit outside out' do
    expect{ visit '/outside-out' }.to raise_error(ActionController::RoutingError)
  end
end