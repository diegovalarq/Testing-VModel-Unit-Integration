require 'rails_helper'

RSpec.describe ShoppingCartController, type: :controller do
  before do
    @user = User.create!(name: 'Test User', email: 'test@example.com', password: 'password')
    sign_in @user
    @product = Product.create!(nombre: 'Test Product', precio: 100, stock: 10, user_id: @user.id, categories: 'Cancha')
    @shopping_cart = ShoppingCart.create!(user_id: @user.id, products: {@product.id.to_s => 1})
  end

  describe 'GET #show' do
      # it 'assigns the existing shopping cart to @shopping_cart' do
      #   get :show
      #   expect(assigns(:@shopping_cart)).to eq(@shopping_cart)
      #   expect(response).to have_http_status(:success)
      # end
      it 'creates a new shopping cart and assigns it to @shopping_cart' do
        get :show
        expect(assigns(:shopping_cart)).to be_a(ShoppingCart)
        expect(assigns(:shopping_cart).user_id).to eq(@user.id)
        expect(response).to have_http_status(:success)
      end

      it 'does not assign a shopping cart' do
        sign_out @user
        get :show
        expect(assigns(:shopping_cart)).to be_nil
        expect(response).to have_http_status(:success)
      end
    end

  describe 'GET #details' do
    context 'when user is signed in and has items in their shopping cart' do
      it 'assigns the shopping cart and calculates total payment' do
        shopping_cart = ShoppingCart.create!(user_id: @user.id, products: { '1' => 2 }) # Assume there are products in the cart
        get :details
        expect(assigns(:shopping_cart)).to eq(shopping_cart)
        expect(assigns(:total_pago)).to be_present
        expect(response).to have_http_status(:success)
      end
    end

    context 'when user is signed in but does not have any items in their shopping cart' do
      it 'redirects to the shopping cart page with a flash alert' do
        shopping_cart = ShoppingCart.create!(user_id: @user.id, products: {}) # Empty cart
        get :details
        expect(flash[:alert]).to eq('No tienes productos que comprar.')
        expect(response).to redirect_to('/carro')
      end
    end

    context 'when user is not signed in' do
      it 'redirects back with a flash alert' do
        sign_out @user
        get :details
        expect(flash[:alert]).to eq('Debes iniciar sesión para comprar.')
        expect(response).to redirect_to(root_path)
      end
    end
  end

  describe 'DELETE #eliminar_producto' do
    it 'deletes an existing product from the shopping cart' do
      delete :eliminar_producto, params: { product_id: @product.id }
      
      expect(flash[:notice]).to eq('Producto eliminado del carro de compras')
      expect(response).to redirect_to('/carro')
      
      @shopping_cart.reload
      expect(@shopping_cart.products).not_to have_key(@product.id.to_s)
    end

    it 'handles the case when the product does not exist in the shopping cart' do
      non_existing_product_id = Product.maximum(:id).to_i + 1
      delete :eliminar_producto, params: { product_id: non_existing_product_id }
      
      expect(flash[:alert]).to eq('El producto no existe en el carro de compras')
      expect(response).to redirect_to('/carro')
    end

    it 'handles errors when updating the shopping cart' do
      allow_any_instance_of(ShoppingCart).to receive(:update).and_return(false)
      
      delete :eliminar_producto, params: { product_id: @product.id }
      
      expect(flash[:alert]).to eq('Hubo un error al eliminar el producto del carro de compras')
      expect(response).to redirect_to('/carro')
    end
  end
end
