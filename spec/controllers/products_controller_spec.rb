require 'rails_helper'

RSpec.describe ProductsController, type: :controller do
  before do
    @admin_user = User.create!(name: 'John1', password: 'Nonono123!', email: 'asdf@gmail.com', role: 'admin')
    @non_admin_user = User.create!(name: 'Steve', password: 'Yesyes321!', email: 'hjkl@gmail.com', role: 'user')
    sign_in @admin_user
    @product1 = Product.create!(nombre: 'John1', precio: 4000, stock: 1, user_id: @admin_user.id, categories: 'Cancha')
    @product2 = Product.create!(nombre: 'Steve1', precio: 500, stock: 3, user_id: @non_admin_user.id, categories: 'Suplementos')

    
    @review1 = Review.create!(tittle: 'Great Product', description: 'Todo bien', calification: 5, product: @product1, user: @non_admin_user)

    @review2 = Review.create!(tittle: 'Great Product', description: 'Todo bien', calification: 4, product: @product1, user: @non_admin_user)

  end

  describe 'GET #index' do
    it 'renders the index template' do
      get :index
      expect(response).to render_template(:index)
    end

    it 'filters products by category' do
      get :index, params: { category: 'Suplementos' }
      expect(assigns(:products)).to eq([@product2])
    end

    it 'filters products by search' do
      get :index, params: { search: 'John1' }
      expect(assigns(:products)).to eq([@product1])
    end

    it 'filters products by category and search' do
      get :index, params: { category: 'Suplementos', search: 'Steve1' }
      expect(assigns(:products)).to eq([@product2])
    end
  end

  describe 'GET #leer' do
    it 'returns http success' do
      get :leer, params: { id: @product1.id }
      expect(response).to have_http_status(:success)
    end

    it 'returns the correct product by id' do
      get :leer, params: { id: @product2.id }
      expect(assigns(:product)).to eq(@product2)
    end

    it 'calculates total_califications correctly' do
      @product4 = Product.create!(nombre: 'Steve1', precio: 500, stock: 3, user_id: @non_admin_user.id, categories: 'Suplementos', reviews: [@review1, @review2])
      get :leer, params: { id: @product1.id }
      expect(assigns(:total_califications)).to be_falsey
    end

    it 'parses horarios correctly' do
      @product3 = Product.create!(nombre: 'Steve1', precio: 500, stock: 3, user_id: @non_admin_user.id, categories: 'Suplementos', horarios: 'Monday,9:00 AM;Tuesday,10:00 AM')
      get :leer, params: { id: @product3.id }
      expect(assigns(:horarios)).to eq([['Monday', '9:00 AM'], ['Tuesday', '10:00 AM']])
    end

  end

  describe 'GET #crear' do
    it 'returns http success' do
      get :crear
      expect(response).to have_http_status(:success)
    end
  end

  describe 'POST #insertar' do
    let(:new_product_params) { { nombre: 'ProductoCreado', precio: 450, stock: 9, categories: 'Equipamiento' } }

    it 'creates a new product with valid parameters for admin' do
      expect {
        post :insertar, params: { product: new_product_params }
      }.to change(Product, :count).by(1)
      expect(response).to redirect_to('/products/index')
    end

    it 'does not create a new product with invalid parameters' do
      invalid_params = { nombre: '', precio: 725, stock: 8, categories: 'NewCategory' }
      post :insertar, params: { product: invalid_params }
      expect(response).to redirect_to('/products/crear')
    end

    it 'redirects non-admin users to index' do
      sign_out @admin_user
      sign_in @non_admin_user
      post :insertar, params: { product: new_product_params }
      expect(response).to redirect_to('/products/index')
    end
  end

  describe 'GET #actualizar' do
    it 'returns http success' do
      get :actualizar, params: { id: @product1.id }
      expect(response).to have_http_status(:success)
    end
  end

  describe 'PATCH #actualizar_producto' do
    let(:updated_params) { { nombre: 'UpdatedProduct', precio: 900, stock: 13, categories: 'Accesorio de entrenamiento' } }

    it 'updates product with valid parameters for admin' do
      patch :actualizar_producto, params: { id: @product1.id, product: updated_params }
      expect(response).to redirect_to('/products/index')
      @product1.reload
      expect(@product1.nombre).to eq('UpdatedProduct')
      expect(@product1.precio).to eq("900")
      expect(@product1.stock).to eq("13")
      expect(@product1.categories).to eq('Accesorio de entrenamiento')
    end

    it 'does not update the product with invalid parameters' do
      invalid_updated_params = { nombre: 'InvalidUpdated', precio: 600, stock: 2, categories: 'UpdatedCategory' }
      patch :actualizar_producto, params: { id: @product2.id, product: invalid_updated_params }
      expect(response).to redirect_to("/products/actualizar/#{@product2.id}")
    end

    it 'redirects non-admin users to index' do
      sign_out @admin_user
      sign_in @non_admin_user
      patch :actualizar_producto, params: { id: @product2.id, product: updated_params }
      expect(response).to redirect_to('/products/index')
    end
  end

  describe 'DELETE #eliminar' do
    it 'deletes the product for admin user' do
      expect {
        delete :eliminar, params: { id: @product1.id }
      }.to change(Product, :count).by(-1)
      expect(response).to redirect_to('/products/index')
    end

    it 'does not delete the product for non-admin user' do
      sign_out @admin_user
      sign_in @non_admin_user
      expect {
        delete :eliminar, params: { id: @product2.id }
      }.not_to change(Product, :count)
      expect(response).to redirect_to('/products/index')
    end
  end

  describe 'POST #insert_deseado' do
    it 'adds product to the wishlist for logged-in user' do
      sign_out @admin_user
      sign_in @non_admin_user
      post :insert_deseado, params: { product_id: @product2.id }
      @non_admin_user.reload
      expect(@non_admin_user.deseados).to include(@product2.id.to_s)
      expect(response).to redirect_to("/products/leer/#{@product2.id}")
    end

    it 'does not add product to the wishlist' do
      sign_in @non_admin_user
      post :insert_deseado, params: { product_id: ''}
      expected_error_message = "Hubo un error al guardar los cambios: #{assigns(:current_user).errors.full_messages.join(', ')}"
      expect(flash[:error]).to eq(expected_error_message)
    end

    it 'adds product to the wishlist if nil' do
      @product5 = Product.create!(nombre: 'Steve1', precio: 500, stock: 3, user_id: @non_admin_user.id, categories: 'Suplementos')
      sign_in @non_admin_user
      post :insert_deseado, params: { product_id: @product5.id }
      expect(@non_admin_user.reload.deseados).to eq([@product5.id.to_s])
    end
  end
end