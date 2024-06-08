require 'rails_helper'

RSpec.describe UsersController, type: :controller do
  before do
    @user = User.create!(name: 'John', password: 'Password123!', email: 'john@example.com', role: 'user')
    @user2 = User.create!(name: 'Steve', password: 'Password321!', email: 'example@example.com', role: 'user')
    @product1 = Product.create!(nombre: 'Product1', precio: 5000, stock: 10, user: @user, categories: 'Cancha')
    sign_in @user
  end

  describe 'GET #show' do
    it 'renders the show template' do
      get :show
      expect(response).to render_template(:show)
    end
  end

  describe 'GET #deseados' do
    it 'renders the deseados template' do
      get :deseados
      expect(response).to render_template(:deseados)
    end
  end

  describe 'GET #mensajes' do
    it 'renders the mensajes template' do
      get :mensajes
      expect(response).to render_template(:mensajes)
    end
  end

  describe 'PATCH #actualizar_imagen' do
    context 'with valid image' do
      it 'updates the user image' do
        mock_image = fixture_file_upload('mock_image.jpg', 'image/jpeg')
        patch :actualizar_imagen, params: { image: mock_image }
        expect(response).to redirect_to('/users/show')
        expect(flash[:notice]).to eq('Imagen actualizada correctamente')
        expect(@user.reload.image.attached?).to be_truthy
      end
    end

    context 'with invalid image' do
      it 'does not update the user image' do
        mock_invalid_image = fixture_file_upload('mock_image.txt', 'text/plain')
        patch :actualizar_imagen, params: { image: mock_invalid_image }
        expect(response).to redirect_to('/users/show')
        # rubocop:disable Layout/LineLength

        expect(flash[:error]).to eq('Hubo un error al actualizar la imagen. Verifique que la imagen es de formato jpg, jpeg, png, gif o webp')
        # rubocop:enable Layout/LineLength

        expect(@user.reload.image.attached?).to be_falsey
      end
    end
  end

  describe 'DELETE #eliminar_deseado' do
    it 'removes a product from the user\'s wishlist' do
      @user.update(deseados: [@product1.id])
      delete :eliminar_deseado, params: { deseado_id: @product1.id }
      expect(response).to redirect_to('/users/deseados')
      expect(flash[:notice]).to eq('Producto quitado de la lista de deseados')
      expect(@user.reload.deseados).to be_empty
    end

    it 'sets flash[:error] when there is an error removing a product from the wishlist' do
      # Add the product to the user's wishlist
      @user.update(deseados: [@product1.id])

      # Stub the save method to return false
      allow_any_instance_of(User).to receive(:save).and_return(false)

      # Perform the delete action
      delete :eliminar_deseado, params: { deseado_id: @product1.id }

      # Check the response
      expect(response).to redirect_to('/users/deseados')

      # Check the flash message
      expect(flash[:error]).to eq('Hubo un error al quitar el producto de la lista de deseados')
    end
  end
end
