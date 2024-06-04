require 'rails_helper'

RSpec.describe 'Products', type: :request do
  before do
    @admin_user = User.create!(name: 'John1', password: 'Nonono123!', email: 'asdf@gmail.com', role: 'admin')
    @non_admin_user = User.create!(name: 'Steve', password: 'Yesyes321!', email: 'hjkl@gmail.com', role: 'user')
    sign_in @admin_user
    @product1 = Product.create!(nombre: 'John1', precio: 4000, stock: 1, user_id: @admin_user.id, categories: 'Cancha')
    @product2 = Product.create!(nombre: 'Steve1', precio: 500, stock: 3, user_id: @non_admin_user.id, categories: 'Suplementos')
  end

  describe 'GET /index' do
    it 'returns http success' do
      get '/products/index'
      expect(response).to have_http_status(:success)
    end

    it 'returns http success without login' do
      sign_out @admin_user
      get '/products/index'
      expect(response).to have_http_status(:success)
    end

    it 'filters products by category' do
      get '/products/index', params: { category: 'Suplementos' }
      expect(assigns(:products)).to eq([@product2])
    end

    it 'filters products by search' do
      get '/products/index', params: { search: 'John1' }
      expect(assigns(:products)).to eq([@product1])
    end

    it 'filters products by category and search' do
      get '/products/index', params: { category: 'Suplementos', search: 'Steve1' }
      expect(assigns(:products)).to eq([@product2])
    end
  end

  describe 'GET /leer/:id' do
    it 'returns http success' do
      get "/products/leer/#{@product1.id}"
      expect(response).to have_http_status(:success)
    end

    it 'returns the correct product by id' do
      get "/products/leer/#{@product2.id}"
      expect(assigns(:product)).to eq(@product2)
    end
  end

  describe 'GET /crear' do
    it 'returns http success' do
      get '/products/crear'
      expect(response).to have_http_status(:success)
    end

    it 'return http success for non-admin' do
      sign_out @admin_user
      sign_in @non_admin_user
      get '/products/crear'
      expect(response).to have_http_status(:success)
    end
  end

  describe 'POST /insertar' do
    new_product_params =  { product: { nombre: 'ProductoCreado', precio: 450, stock: 9, categories: 'Equipamiento' } }

    it 'creates new product with valid parameters for admin' do
      expect {
        post '/products/insertar', params: new_product_params
      }.to change(Product, :count).by(1)
      expect(response).to redirect_to('/products/index')
    end

    it 'does not create a new product with invalid parameters' do
      invalid_params = { product: { nombre: 'InvalidProduct', precio: 725, stock: 8, categories: 'NewCategory' } }
      expect {
        post '/products/insertar', params: invalid_params
      }.not_to change(Product, :count)
      expect(response).to redirect_to('/products/crear')
    end

    it 'redirects non-admin to index' do
      sign_out @admin_user
      sign_in @non_admin_user
      post '/products/insertar', params: new_product_params
      expect(response).to redirect_to('/products/index')
    end
  end

  describe 'GET /actualizar/:id' do
    it 'returns http success' do
      get "/products/actualizar/#{@product1.id}"
      expect(response).to have_http_status(:success)
    end
  end

  describe 'POST /actualizar_producto/:id' do
    updated_params = { product: { nombre: 'UpdatedProduct', precio: 900, stock: 13, categories: 'Accesorio de entrenamiento' } }

    it 'updates product with valid parameters for admin' do
      patch "/products/actualizar/#{@product1.id}", params: updated_params
      expect(response).to redirect_to('/products/index')
      @product1.reload
      expect(@product1.nombre).to eq('UpdatedProduct')
      expect(@product1.precio).to eq('900')
      expect(@product1.stock).to eq('13')
      expect(@product1.categories).to eq('Accesorio de entrenamiento')
    end

    it 'does not update the product with invalid parameters' do
      invalid_updated_params = { product: { nombre: 'InvalidUpdated', precio: 600, stock: 2, categories: 'UpdatedCategory' } }
      patch "/products/actualizar/#{@product2.id}", params: invalid_updated_params
      expect(response).to redirect_to("/products/actualizar/#{@product2.id}")
    end

    it 'redirects non-admin user to index' do
      sign_in @non_admin_user
      patch "/products/actualizar/#{@product2.id}", params: updated_params
      expect(response).to redirect_to('/products/index')
    end
  end

  describe 'DELETE /eliminar/:id' do
    it 'deletes the product for admin user' do
      expect {
        delete "/products/eliminar/#{@product1.id}"
      }.to change(Product, :count).by(-1)
      expect(response).to redirect_to('/products/index')
    end

    it 'does not delete the product for non-admin user' do
      sign_in @non_admin_user
      expect {
        delete "/products/eliminar/#{@product2.id}"
      }.not_to change(Product, :count)
      expect(response).to redirect_to('/products/index')
    end
  end

  describe 'POST /insert_deseado' do
    it 'adds product to the wishlist for logged-in user' do
      sign_in @non_admin_user
      post "/products/insert_deseado/#{@product2.id}"
      @non_admin_user.reload
      expect(@non_admin_user.deseados).to include(@product2.id.to_s)
      expect(response).to redirect_to("/products/leer/#{@product2.id}")
    end
  end
end
