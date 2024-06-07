require 'rails_helper'

RSpec.describe SolicitudController, type: :controller do
  before do
    @admin_user = User.create!(name: 'Admin', password: 'Password123!', email: 'admins@example.com', role: 'admin')
    @product = Product.create!(nombre: 'Product1', precio: 5000, stock: 5, user_id: @admin_user.id, categories: 'Cancha')
    sign_in @admin_user
  end

  describe 'GET #index' do
    it 'renders the index template' do
      get :index
      expect(response).to render_template(:index)
    end
  end

  describe 'POST #insertar' do
    context 'with valid parameters' do
      it 'creates a new solicitud' do
        solicitud_params = { solicitud: { stock: 5 }, product_id: 
        @product.id }
        expect {
          post :insertar, params: solicitud_params
        }.to change(Solicitud, :count).by(1)
        expect(response).to redirect_to("/products/leer/#{@product.id}")
        expect(flash[:notice]).to eq('Solicitud de compra creada correctamente!')
      end
    end

    context 'with invalid parameters' do
      it 'does not create a new solicitud' do
        solicitud_params = { solicitud: { stock: 15 }, product_id: @product.id }
        post :insertar, params: solicitud_params
        expect(response).to redirect_to("/products/leer/#{@product.id}")
        expect(flash[:error]).to eq('No hay suficiente stock para realizar la solicitud!')
      end
    end
  end

  describe 'DELETE #eliminar' do
    it 'deletes an existing solicitud' do
      solicitud = Solicitud.create!(status: 'Pendiente', stock: 5, product: @product, user: @admin_user)
      expect {
        delete :eliminar, params: { id: solicitud.id }
      }.to change(Solicitud, :count).by(-1)
      expect(response).to redirect_to('/solicitud/index')
      expect(flash[:notice]).to eq('Solicitud eliminada correctamente!')
    end
  end

  describe 'PATCH #actualizar' do
    it 'updates the status of a solicitud' do
      solicitud = Solicitud.create!(status: 'Pendiente', stock: 5, product: @product, user: @admin_user)
      patch :actualizar, params: { id: solicitud.id }
      expect(response).to redirect_to('/solicitud/index')
      expect(flash[:notice]).to eq('Solicitud aprobada correctamente!')
      expect(solicitud.reload.status).to eq('Aprobada')
    end
  end
end
