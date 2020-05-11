require 'rails_helper'

xdescribe 'Role Proc in routes', type: :request do
  it 'proves that we can get data from a constraint into the engine aware route set' do
    get '/test-role-proc'
    expect(response.status).to eq 200
    expect(response.body).to eq 'staff'
  end
end
