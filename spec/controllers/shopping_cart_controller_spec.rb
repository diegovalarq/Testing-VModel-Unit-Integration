require 'rails_helper'

RSpec.describe ShoppingCartController, type: :controller do
  before(:each) do
    @user = User.create!(name: 'Test User', email: 'test@example.com', password: 'password')
    sign_in @user
    @product = Product.create!(nombre: 'Test Product', precio: 100, stock: 100, user_id: @user.id, categories: 'Cancha')
    @product1 = Product.create!(nombre: 'Test Product', precio: 100, stock: 500, user_id: @user.id,
                                categories: 'Cancha')
    @shopping_cart = ShoppingCart.create!(user_id: @user.id, products: { @product.id.to_s => 1 })
  end

  describe 'GET #show' do
    it 'assigns the shopping cart for the current user' do
      get :show
      expect(assigns(:shopping_cart)).to eq(@shopping_cart)
    end

    it 'creates a new shopping cart if none exists' do
      @shopping_cart.destroy
      expect { get :show }.to change(ShoppingCart, :count).by(1)
    end
  end

  describe 'GET #details' do
    it 'assigns the shopping cart for the current user' do
      get :details
      expect(assigns(:shopping_cart)).to eq(@shopping_cart)
    end

    it 'calculates the total payment' do
      get :details
      expect(assigns(:total_pago)).to eq(1105)
    end

    it 'redirects to cart if no products in cart' do
      @shopping_cart.products = {}
      @shopping_cart.save
      get :details
      expect(response).to redirect_to('/carro')
      expect(flash[:alert]).to eq('No tienes productos que comprar.')
    end

    it 'redirects not logged-in user' do
      sign_out @user
      get :details
      expect(flash[:alert]).to eq('Debes iniciar sesión para comprar.')
      expect(response).to redirect_to(root_path)
    end
  end

  describe 'POST #insertar_producto' do
    let(:valid_params) { { product_id: @product.id, add: { amount: 2 } } }
    let(:invalid_params) { { product_id: @product1.id, add: { amount: 101 } } }
    let(:new_product) do
      create(:product, nombre: 'New Product', precio: 50, stock: 20, user_id: @user.id, categories: 'Cancha')
    end

    context 'when the cart has less than 8 products' do
      it 'adds a product to the cart with valid parameters' do
        expect do
          post :insertar_producto, params: valid_params
        end.to change { @shopping_cart.reload.products[@product.id.to_s] }.from(1).to(3)
        expect(response).to redirect_to(root_path)
        expect(flash[:notice]).to eq('Producto agregado al carro de compras')
      end

      it 'does not add a product to the cart with more 100 amount' do
        post :insertar_producto, params: invalid_params
        expect(response).to redirect_to(root_path)
        expected_error_message = "El producto '#{@product.nombre}' tiene un máximo de 100 unidades por compra."
        expect(flash[:alert]).to eq(expected_error_message)
      end
    end

    context 'when the cart has 8 products' do
      before do
        9.times do
          # product = create!(:product, user_id: @user.id, categories: 'Cancha')
          @shopping_cart.products[@product.id.to_s] = 1
        end
        @shopping_cart.save
      end

      it 'does not add a new product to the cart' do
        products = []
        9.times do |i|
          product = Product.create!(nombre: "Product #{i}", precio: 100, stock: 10, user_id: @user.id,
                                    categories: 'Cancha')
          products << product.id
        end

        # Iterate over the products and post insertar_producto 9 times
        products.each do |product_id|
          9.times do
            post :insertar_producto, params: { product_id:, add: { amount: 1 } }
          end
        end
        # rubocop:disable Layout/LineLength

        expect(flash[:alert]).to eq('Has alcanzado el máximo de productos en el carro de compras (8). Elimina productos para agregar más o realiza el pago de los productos actuales.')
        # rubocop:enable Layout/LineLength

        expect(response).to redirect_to(root_path)
      end
    end

    context 'when the product does not have enough stock' do
      it 'does not add the product to the cart' do
        @product.update(stock: 0)
        expect do
          post :insertar_producto, params: valid_params
        end.not_to(change { @shopping_cart.reload.products })
        expect(response).to redirect_to(root_path)
        # rubocop:disable Layout/LineLength

        expected_error_message = "El producto '#{@product.nombre}' no tiene suficiente stock para agregarlo al carro de compras."
        # rubocop:enable Layout/LineLength

        expect(flash[:alert]).to eq(expected_error_message)
      end
    end

    it 'sets flash alert when not signed in' do
      sign_out @user
      post :insertar_producto, params: valid_params
      expect(flash[:alert]).to eq('Debes iniciar sesión para agregar productos al carro de compras.')
      expect(response).to redirect_to('/carro')
    end
  end
  describe 'DELETE #eliminar_producto' do
    before { sign_in @user }

    context 'when the product is in the cart' do
      it 'removes the product from the cart' do
        expect do
          delete :eliminar_producto, params: { product_id: @product.id }
        end.to change { @shopping_cart.reload.products[@product.id.to_s] }.from(1).to(nil)
        expect(response).to redirect_to('/carro')
        expect(flash[:notice]).to eq('Producto eliminado del carro de compras')
      end

      it 'displays an error message when the update fails' do
        allow_any_instance_of(ShoppingCart).to receive(:update).and_return(false)
        delete :eliminar_producto, params: { product_id: @product.id }
        expect(response).to redirect_to('/carro')
        expect(flash[:alert]).to eq('Hubo un error al eliminar el producto del carro de compras')
      end
    end

    context 'when the product is not in the cart' do
      it 'displays an error message' do
        delete :eliminar_producto, params: { product_id: @product1.id }
        expect(response).to redirect_to('/carro')
        expect(flash[:alert]).to eq('El producto no existe en el carro de compras')
      end
    end
  end

  describe 'POST #comprar_ahora' do
    it 'calls insertar_producto with buy_now: true' do
      expect(controller).to receive(:insertar_producto).with(buy_now: true)
      post :comprar_ahora, params: { product_id: @product.id, add: { amount: 1 } }
    end

    context 'when the product is successfully added to the cart' do
      before do
        allow_any_instance_of(ShoppingCartController).to receive(:insertar_producto).and_call_original
        allow_any_instance_of(ShoppingCart).to receive(:update).and_return(true)
      end

      it 'redirects to the cart details page' do
        post :comprar_ahora, params: { product_id: @product.id, add: { amount: 1 } }
        expect(response).to redirect_to('/carro/detalle')
      end
    end

    context 'when there is an error adding the product to the cart' do
      before do
        allow_any_instance_of(ShoppingCartController).to receive(:insertar_producto).and_call_original
        allow_any_instance_of(ShoppingCart).to receive(:update).and_return(false)
      end

      it 'sets flash alert and redirects back with unprocessable entity status' do
        post :comprar_ahora, params: { product_id: @product.id, add: { amount: 1 } }
        expect(flash[:alert]).to eq('Hubo un error al agregar el producto al carro de compras')
        expect(response).to have_http_status(:unprocessable_entity)
      end
    end
  end

  describe 'POST #realizar_compra' do
    before { sign_in @user }

    context 'when the shopping cart is not found' do
      it 'displays an error message and redirects to the cart page' do
        @shopping_cart.destroy
        post :realizar_compra
        expect(response).to redirect_to('/carro')
        expect(flash[:alert]).to eq('No se encontró tu carro de compras. Contacte un administrador.')
      end
    end

    context 'when the shopping cart is empty' do
      it 'displays an error message and redirects to the cart page' do
        @shopping_cart.products = {}
        @shopping_cart.save
        post :realizar_compra
        expect(response).to redirect_to('/carro')
        expect(flash[:alert]).to eq('No tienes productos en el carro de compras')
      end
    end

    context 'when the shopping cart has products' do
      before do
        allow(controller).to receive(:comprobar_productos).and_return(true)
        allow(controller).to receive(:crear_solicitudes).and_return(true)
      end

      it 'creates purchase requests and clears the cart' do
        post :realizar_compra
        expect(@shopping_cart.reload.products).to be_empty
        expect(response).to redirect_to('/solicitud/index')
        expect(flash[:notice]).to eq('Compra realizada exitosamente')
      end

      it 'displays an error message when updating the cart fails' do
        allow_any_instance_of(ShoppingCart).to receive(:update).and_return(false)
        post :realizar_compra
        expect(response).to redirect_to('/carro')
        expect(flash[:alert]).to eq('Hubo un error al actualizar el carro. Contacte un administrador.')
      end

      it 'redirects to the cart page when comprobar_productos returns false' do
        allow(controller).to receive(:comprobar_productos).and_return(false)
        post :realizar_compra
        expect(response).to redirect_to('/carro')
      end

      it 'does not proceed when crear_solicitudes returns false' do
        allow(controller).to receive(:crear_solicitudes).and_return(false)
        post :realizar_compra
        expect(@shopping_cart.reload.products).not_to be_empty
      end
    end
  end

  describe 'DELETE #limpiar' do
    before { sign_in @user }

    context 'when the shopping cart is found' do
      it 'clears the products from the cart' do
        expect do
          delete :limpiar
        end.to change { @shopping_cart.reload.products }.to({})
        expect(response).to redirect_to('/carro')
        expect(flash[:notice]).to eq('Carro de compras limpiado exitosamente')
      end

      it 'displays an error message when the update fails' do
        allow_any_instance_of(ShoppingCart).to receive(:update).and_return(false)
        delete :limpiar
        expect(response).to redirect_to('/carro')
        expect(flash[:alert]).to eq('Hubo un error al limpiar el carro de compras. Contacte un administrador.')
      end
    end
  end

  describe '#crear_carro' do
    it 'returns a new shopping cart instance' do
      sign_in @user
      cart = controller.send(:crear_carro)
      expect(cart).to be_a(ShoppingCart)
      expect(cart.user_id).to eq(@user.id)
      expect(cart.products).to eq({})
    end

    it 'sets a flash alert and redirects to the root path' do
      allow_any_instance_of(ShoppingCart).to receive(:save).and_return(false)
      expect(controller).to receive(:redirect_to).with(:root)
      controller.send(:crear_carro)
      expect(flash[:alert]).to eq('Hubo un error al crear el carro. Contacte un administrador.')
    end
  end
  describe 'POST #realizar_compra' do
    let(:valid_params) { { product_id: @product1.id, add: { amount: 9 } } }
    it 'completes the purchase successfully' do
      @product1.update(stock: 5)
      post :realizar_compra
      expect(response).to redirect_to('/solicitud/index')
      expect(flash[:notice]).to eq('Compra realizada exitosamente')
    end

    it 'cancels the purchase and sets flash message' do
      post :insertar_producto, params: valid_params
      @product1.update(stock: 0)

      post :realizar_compra
      # rubocop:disable Layout/LineLength

      expected_message = "Compra cancelada: El producto '#{@product.nombre}' no tiene suficiente stock para realizar la compra. Por favor, elimina el producto del carro de compras o reduce la cantidad."
      # rubocop:enable Layout/LineLength

      expect(flash[:alert]).to eq(expected_message)
    end
  end

  describe '#realizar_compra' do
    it 'sets flash alert and redirects to cart' do
      allow_any_instance_of(Solicitud).to receive(:save).and_return(false)
      post :realizar_compra
      expect(response).to redirect_to('/carro')
      expect(flash[:alert]).to eq('Hubo un error al realizar la compra. Contacte un administrador.')
    end
  end
end
