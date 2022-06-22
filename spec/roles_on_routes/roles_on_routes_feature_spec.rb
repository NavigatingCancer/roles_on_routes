require 'rails_helper'
require 'roles_on_routes/roles_on_routes_controller'

describe 'roles_on_routes integration', :type => :feature do
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