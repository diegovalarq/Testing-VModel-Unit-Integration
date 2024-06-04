require 'rails_helper'

RSpec.describe 'Products', type: :request do
  before do
    @admin_user = User.create!(name: 'John1', password: 'Nonono123!', email: 'asdf@gmail.com',
                         role: 'admin')
    @user = User.create!(name: 'Steve', password: 'YesYes 321!', email: 'hjkl@gmail.com', role: 'user')
    sign_in @admin_user
    @product = Product.create!(nombre: 'John1', precio: 4000, stock: 1, user_id: @user.id, categories: 'Cancha')
  end

  describe 'GET /new' do
    it 'returns http success' do
      get '/products/index'
      expect(response).to have_http_status(:success)
    end
    it 'return http success without login' do
      sign_out @admin_user
      get '/products/index'
      expect(response).to have_http_status(:success)
    end
  end

  describe 'GET /leer' do
    it 'returns http success' do
      get "/products/leer/#{@product.id}"
      expect(response).to have_http_status(:success)
    end
  end

  describe 'GET /crear' do
    it 'returns http success' do
      get '/products/crear'
      expect(response).to have_http_status(:success)
    end

    # it 'returns redirect for non-admin' do
    #   sign_out @admin_user
    #   sign_in @user
    #   get '/products/crear'
    #   expect(response).to redirect_to('/products/index')
    # end
  end

  describe 'POST /insertar' do
    it 'returns http success for admin' do
      post '/products/insertar', params: { product: { nombre: 'John1', precio: 4000, stock: 1, user_id: @user.id, categories: 'Cancha' } }
      expect(response).to redirect_to('/products/index')
    end

    # it 'redirects to /products/index for non-admin' do
    #   sign_out @admin_user
    #   sign_in @user
    #   post '/products/insertar', params: { product: { nombre: 'John1', precio: 4000, stock: 1, user_id: @user.id, categories: 'Cancha' } }
    #   expect(response).to redirect_to('/products/index')
    # end
  end

end