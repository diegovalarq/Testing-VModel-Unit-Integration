require 'rails_helper'

RSpec.describe ShoppingCartController, type: :controller do
  let(:user) { create(:user) }
  let(:product) { create(:product, stock: 10) }
  let(:shopping_cart) { create(:shopping_cart, user: user, products: {}) }

  before do
    sign_in user
  end

  describe 'GET #show' do
    context 'when user is signed in' do
      it 'assigns the shopping cart to @shopping_cart' do
        get :show
        expect(assigns(:shopping_cart)).to eq(shopping_cart)
      end

      it 'creates a new shopping cart if none exists' do
        ShoppingCart.destroy_all
        get :show
        expect(assigns(:shopping_cart)).to be_a(ShoppingCart)
      end
    end

    context 'when user is not signed in' do
      before { sign_out user }

      it 'does not assign a shopping cart' do
        get :show
        expect(assigns(:shopping_cart)).to be_nil
      end
    end
  end

  describe 'GET #details' do
    context 'when user is signed in' do
      it 'assigns the shopping cart to @shopping_cart' do
        get :details
        expect(assigns(:shopping_cart)).to eq(shopping_cart)
      end

      it 'redirects to /carro with a flash message if the cart is empty' do
        get :details
        expect(flash[:alert]).to eq('No tienes productos que comprar.')
        expect(response).to redirect_to('/carro')
      end

      it 'calculates the total payment if the cart has products' do
        shopping_cart.update(products: { product.id => 2 })
        get :details
        expect(assigns(:total_pago)).to eq(shopping_cart.precio_total + shopping_cart.costo_envio)
      end
    end

    context 'when user is not signed in' do
      before { sign_out user }

      it 'redirects back with a flash message' do
        get :details
        expect(flash[:alert]).to eq('Debes iniciar sesión para comprar.')
        expect(response).to redirect_back(fallback_location: root_path)
      end
    end
  end

  describe 'POST #insertar_producto' do
    context 'when user is signed in' do
      let(:params) { { product_id: product.id, add: { amount: 1 } } }

      it 'creates a new cart if none exists' do
        ShoppingCart.destroy_all
        post :insertar_producto, params: params
        expect(assigns(:shopping_cart)).to be_a(ShoppingCart)
      end

      it 'adds a product to the shopping cart' do
        post :insertar_producto, params: params
        expect(assigns(:shopping_cart).products[product.id.to_s]).to eq(1)
        expect(flash[:notice]).to eq('Producto agregado al carro de compras')
      end

      it 'updates the quantity if the product is already in the cart' do
        shopping_cart.update(products: { product.id => 1 })
        post :insertar_producto, params: params
        expect(assigns(:shopping_cart).products[product.id.to_s]).to eq(2)
      end

      it 'redirects to /carro/detalle if buy_now is true' do
        post :insertar_producto, params: params.merge(buy_now: true)
        expect(response).to redirect_to('/carro/detalle')
      end

      it 'shows an error if stock is insufficient' do
        product.update(stock: 0)
        post :insertar_producto, params: params
        expect(flash[:alert]).to eq("El producto '#{product.nombre}' no tiene suficiente stock para agregarlo al carro de compras.")
        expect(response).to redirect_back(fallback_location: root_path)
      end
    end

    context 'when user is not signed in' do
      before { sign_out user }

      it 'redirects to /carro with a flash message' do
        post :insertar_producto, params: { product_id: product.id, add: { amount: 1 } }
        expect(flash[:alert]).to eq('Debes iniciar sesión para agregar productos al carro de compras.')
        expect(response).to redirect_to('/carro')
      end
    end
  end

  describe 'DELETE #eliminar_producto' do
    context 'when user is signed in' do
      let(:params) { { product_id: product.id } }

      it 'removes the product from the shopping cart' do
        shopping_cart.update(products: { product.id => 1 })
        delete :eliminar_producto, params: params
        expect(assigns(:shopping_cart).products).to be_empty
        expect(flash[:notice]).to eq('Producto eliminado del carro de compras')
      end

      it 'shows an error if the product is not in the cart' do
        delete :eliminar_producto, params: params
        expect(flash[:alert]).to eq('El producto no existe en el carro de compras')
      end
    end

    context 'when user is not signed in' do
      before { sign_out user }

      it 'redirects to /carro with a flash message' do
        delete :eliminar_producto, params: { product_id: product.id }
        expect(flash[:alert]).to eq('Debes iniciar sesión para agregar productos al carro de compras.')
        expect(response).to redirect_to('/carro')
      end
    end
  end

  describe 'POST #realizar_compra' do
    context 'when user is signed in' do
      it 'redirects to /carro if the cart is empty' do
        post :realizar_compra
        expect(flash[:alert]).to eq('No tienes productos en el carro de compras')
        expect(response).to redirect_to('/carro')
      end

      it 'creates requests and clears the cart' do
        shopping_cart.update(products: { product.id => 1 })
        expect {
          post :realizar_compra
        }.to change(Solicitud, :count).by(1).and change { shopping_cart.reload.products }.to({})
        expect(flash[:notice]).to eq('Compra realizada exitosamente')
        expect(response).to redirect_to('/solicitud/index')
      end

      it 'shows an error if a request fails' do
        shopping_cart.update(products: { product.id => 1 })
        allow_any_instance_of(Solicitud).to receive(:save).and_return(false)
        post :realizar_compra
        expect(flash[:alert]).to eq('Hubo un error al realizar la compra. Contacte un administrador.')
        expect(response).to redirect_to('/carro')
      end
    end

    context 'when user is not signed in' do
      before { sign_out user }

      it 'redirects to /carro with a flash message' do
        post :realizar_compra
        expect(flash[:alert]).to eq('Debes iniciar sesión para agregar productos al carro de compras.')
        expect(response).to redirect_to('/carro')
      end
    end
  end

  describe 'POST #limpiar' do
    context 'when user is signed in' do
      it 'clears the shopping cart' do
        shopping_cart.update(products: { product.id => 1 })
        post :limpiar
        expect(assigns(:shopping_cart).products).to be_empty
        expect(flash[:notice]).to eq('Carro de compras limpiado exitosamente')
        expect(response).to redirect_to('/carro')
      end
    end

    context 'when user is not signed in' do
      before { sign_out user }

      it 'redirects to /carro with a flash message' do
        post :limpiar
        expect(flash[:alert]).to eq('Debes iniciar sesión para agregar productos al carro de compras.')
        expect(response).to redirect_to('/carro')
      end
    end
  end
end
