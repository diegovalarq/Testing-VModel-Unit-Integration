require 'rails_helper'

RSpec.describe 'Pages', type: :request do
  describe 'GET /' do
    it 'renders the index template' do
      get '/'
      expect(response).to render_template(:index)
    end
  end

  describe 'GET /pages/index' do
    it 'renders the index template' do
      get '/pages/index'
      expect(response).to render_template(:index)
    end
  end
end