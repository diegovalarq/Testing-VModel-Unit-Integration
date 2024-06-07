require 'rails_helper'

RSpec.describe 'Users', type: :request do
  before do
    @user = User.create!(name: 'John', password: 'Password123!', email: 'john@example.com', role: 'user')
    sign_in @user
    @user2 = User.create!(name: 'Steve', password: 'Password321!', email: 'example@example.com', role: 'user')
  end

  describe 'GET /users/show' do
    it 'renders the show template' do
      get '/users/show'
      expect(response).to render_template(:show)
    end
  end

  describe 'GET /users/deseados' do
    it 'renders the deseados template' do
      get '/users/deseados'
      expect(response).to render_template(:deseados)
    end
  end

  describe 'GET /users/mensajes' do
    it 'renders the mensajes template' do
      get '/users/mensajes'
      expect(response).to render_template(:mensajes)
    end
  end

  describe 'PATCH /users/actualizar_imagen' do
    context 'with valid image' do
      it 'updates the user image' do
        mock_image = Rack::Test::UploadedFile.new('spec/fixtures/files/test_image.jpg', 'image/jpeg')
        patch '/users/actualizar_imagen', params: { image: mock_image }
        expect(response).to redirect_to('/users/show')
        expect(flash[:notice]).to eq('Imagen actualizada correctamente')
        expect(@user.reload.image.attached?).to be_truthy
      end
    end

    context 'with invalid image' do
      it 'does not update the user image' do
        mock_invalid_image = Rack::Test::UploadedFile.new('spec/fixtures/files/test_file.txt', 'text/plain')
        patch '/users/actualizar_imagen', params: { image: mock_invalid_image }
        expect(response).to redirect_to('/users/show')
        expect(flash[:error]).to eq('Hubo un error al actualizar la imagen. Verifique que la imagen es de formato jpg, jpeg, png, gif o webp')
        expect(@user.reload.image.attached?).to be_falsey
      end
    end
  end

  describe 'DELETE /users/eliminar_deseado' do
    it 'removes a product from the user\'s wishlist' do
      @user.deseados = ['product1', 'product2']
      @user.save
      delete "/users/eliminar_deseado/#{@user2.id}", params:{ prodcutId: product1.id }
      expect(response).to redirect_to('/users/deseados')
      expect(flash[:notice]).to eq('Producto quitado de la lista de deseados')
      expect(@user.reload.deseados).to eq(['product2'])
    end
  end
end