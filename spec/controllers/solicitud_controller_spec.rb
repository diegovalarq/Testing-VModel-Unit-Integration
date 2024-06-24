require 'rails_helper'

RSpec.describe SolicitudController, type: :controller do
  before do
    @admin_user = User.create!(name: 'Admin', password: 'Password123!', email: 'admins@example.com', role: 'admin')
    @product = Product.create!(nombre: 'Product1', precio: 5000, stock: 5, user_id: @admin_user.id,
                               categories: 'Cancha')
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
        solicitud_params = { solicitud: { stock: 5, reservation_datetime: '2024-06-07T12:00:00' }, product_id:
        @product.id }
        expect do
          post :insertar, params: solicitud_params
        end.to change(Solicitud, :count).by(1)
        expect(response).to redirect_to("/products/leer/#{@product.id}")
        expect(flash[:notice]).to eq('Solicitud de compra creada correctamente!')
        @solicitud = Solicitud.last
        expect(@solicitud.reservation_info).to eq('Solicitud de reserva para el día 07/06/2024, a las 12:00 hrs')
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

    context 'with product with horario' do
      it 'creates a new solicitud with valid reservation' do
        @product.update(horarios: 'Wednesday,08:00,18:00;Friday,10:00,22:00')
        solicitud_params = { solicitud: { stock: 1, reservation_datetime: '2024-06-07T12:00:00' }, product_id:
        @product.id }
        expect do
          post :insertar, params: solicitud_params
        end.to change(Solicitud, :count).by(1)
        expect(response).to redirect_to("/products/leer/#{@product.id}")
        expect(flash[:notice]).to eq('Solicitud de compra creada correctamente!')
        @solicitud = Solicitud.last
        expect(@solicitud.reservation_info).to eq('Solicitud de reserva para el día 07/06/2024, a las 12:00 hrs')
      end

      it 'does not create a new solicitud with invalid day' do
        @product.update(horarios: 'Wednesday,08:00,18:00;Friday,20:00,22:00')
        solicitud_params = { solicitud: { stock: 1, reservation_datetime: '2024-06-08T12:00:00' }, product_id:
        @product.id }
        expect do
          post :insertar, params: solicitud_params
        end.to change(Solicitud, :count).by(0)
        expect(response).to redirect_to("/products/leer/#{@product.id}")
        expect(flash[:error]).to eq('No hay reservas disponibles en el día y hora seleccionada!')
      end

      it 'does not create a new solicitud with empty reservation date' do
        @product.update(horarios: 'Wednesday,08:00,18:00;Friday,20:00,22:00')
        solicitud_params = { solicitud: { stock: 1 }, product_id:
        @product.id }
        expect do
          post :insertar, params: solicitud_params
        end.to change(Solicitud, :count).by(0)
        expect(response).to redirect_to("/products/leer/#{@product.id}")
        expect(flash[:error]).to eq('Debe seleccionar una fecha y hora para la reserva!')
      end
    end
  end

  describe 'DELETE #eliminar' do
    it 'deletes an existing solicitud' do
      solicitud = Solicitud.create!(status: 'Pendiente', stock: 5, product: @product, user: @admin_user)
      expect do
        delete :eliminar, params: { id: solicitud.id }
      end.to change(Solicitud, :count).by(-1)
      expect(response).to redirect_to('/solicitud/index')
      expect(flash[:notice]).to eq('Solicitud eliminada correctamente!')
    end

    it 'does not deletes an existing solicitud' do
      solicitud = Solicitud.create!(status: 'Pendiente', stock: '1', product: @product, user: @admin_user)

      allow_any_instance_of(Solicitud).to receive(:destroy).and_return(false)
      expect do
        delete :eliminar, params: { id: solicitud.id }
      end.not_to change(Solicitud, :count)
      expect(response).to redirect_to('/solicitud/index')
      expect(flash[:error]).to eq('Hubo un error al eliminar la solicitud!')
    end

    it 'does not create a new solicitud' do
      solicitud_params = { solicitud: { stock: '' }, product_id: @product.id }

      expect do
        post :insertar, params: solicitud_params
      end.not_to change(Solicitud, :count)

      expect(response).to redirect_to("/products/leer/#{@product.id}")
      expect(flash[:error]).to eq('Hubo un error al guardar la solicitud!')
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

    it 'handles errors when updating the status of a solicitud' do
      solicitud = Solicitud.create!(status: 'Pendiente', stock: 5, product: @product, user: @admin_user)
      allow_any_instance_of(Solicitud).to receive(:update).and_return(false)
      patch :actualizar, params: { id: solicitud.id }
      expect(response).to redirect_to('/solicitud/index')
      expect(flash[:error]).to eq('Hubo un error al aprobar la solicitud!')
    end
  end
end
