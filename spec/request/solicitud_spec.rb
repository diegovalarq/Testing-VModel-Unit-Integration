require 'rails_helper'

RSpec.describe 'Solicitud', type: :request do
  before do
    @user = User.create!(name: 'John', password: 'Password123!', email: 'john@example.com', role: 'user')
    @product = Product.create!(nombre: 'Product1', precio: 5000, stock: 10, user_id: @user.id, categories: 'Cancha')
    sign_in @user
  end

  describe 'GET /solicitud/index' do
    it 'renders the index template' do
      get '/solicitud/index'
      expect(response).to render_template(:index)
    end
  end

  describe 'POST /solicitud/insertar' do
    context 'with valid parameters' do
      it 'creates a new solicitud' do
        solicitud_params = { solicitud: { stock: 5 }, product_id: @product.id }
        expect {
          post '/solicitud/insertar', params: solicitud_params
        }.to change(Solicitud, :count).by(1)
        expect(response).to redirect_to("/products/leer/#{@product.id}")
        expect(flash[:notice]).to eq('Solicitud de compra creada correctamente!')
      end
    end

    context 'with invalid parameters' do
      it 'does not create a new solicitud' do
        solicitud_params = { solicitud: { stock: 15 }, product_id: @product.id }
        post '/solicitud/insertar', params: solicitud_params
        expect(response).to redirect_to("/products/leer/#{@product.id}")
        expect(flash[:error]).to eq('No hay suficiente stock para realizar la solicitud!')
      end
    end
  end

  describe 'DELETE /solicitud/eliminar' do
    it 'deletes an existing solicitud' do
      solicitud = Solicitud.create!(status: 'Pendiente', stock: 5, product_id: @product.id, user_id: @user.id)
      delete "/solicitud/eliminar/#{solicitud.id}"
      expect(response).to redirect_to('/solicitud/index')
      expect(flash[:notice]).to eq('Solicitud eliminada correctamente!')
      expect(Solicitud.exists?(solicitud.id)).to be_falsey
    end
  end

  describe 'PATCH /solicitud/actualizar' do
    it 'updates the status of a solicitud' do
      solicitud = Solicitud.create!(status: 'Pendiente', stock: 5, product_id: @product.id, user_id: @user.id)
      patch "/solicitud/actualizar/#{solicitud.id}"
      expect(response).to redirect_to('/solicitud/index')
      expect(flash[:notice]).to eq('Solicitud aprobada correctamente!')
      expect(solicitud.reload.status).to eq('Aprobada')
    end
  end
end