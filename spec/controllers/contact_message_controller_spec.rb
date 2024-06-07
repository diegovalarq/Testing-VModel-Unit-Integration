require 'rails_helper'

RSpec.describe ContactMessageController, type: :controller do
  before do
    @admin_user = User.create!(name: 'Admin', password: 'Password123!', email: 'adminz@example.com', role: 'admin')
    @non_admin_user = User.create!(name: 'User', password: 'Password123!', email: 'user@example.com', role: 'user')
    @contact_message = ContactMessage.create!(name: 'John Doe', mail: 'john@example.com', phone: '+56912345678', title: 'Help', body: 'I need help.')
  end

  describe 'POST #crear' do
    let(:valid_params) { { contact: { name: 'Jane Doe', mail: 'jane@example.com', phone: '+56987654321', title: 'Support', body: 'I need support.' } } }
    let(:invalid_params) { { contact: { name: '', mail: 'jane@example.com', phone: '0987654321', title: 'Support', body: 'I need support.' } } }

    it 'creates a new contact message with valid parameters' do
      post :crear, params: valid_params
      expect(flash[:notice]).to eq('Mensaje de contacto enviado correctamente')
      expect(response).to redirect_to('/contacto')
    end

    it 'does not create a new contact message with invalid parameters' do
      expect {
        post :crear, params: invalid_params
      }.not_to change(ContactMessage, :count)
      expect(response).to redirect_to('/contacto')
      expect(flash[:alert]).to include('Error al enviar el mensaje de contacto')
    end
  end

  describe 'GET #mostrar' do
    it 'returns http success and assigns all contact messages' do
      get :mostrar
      expect(response).to have_http_status(:success)
      expect(assigns(:contact_messages)).to eq([@contact_message])
    end
  end

  describe 'DELETE #eliminar' do
    context 'as an admin user' do
      before { sign_in @admin_user }

      it 'deletes the contact message' do
        expect {
          delete :eliminar, params: { id: @contact_message.id }
        }.to change(ContactMessage, :count).by(-1)
        expect(response).to redirect_to('/contacto')
        expect(flash[:notice]).to eq('Mensaje de contacto eliminado correctamente')
      end

      it 'shows an error message if the contact message does not exist' do
        expect {
          delete :eliminar, params: { id: 999999 }
        }.not_to change(ContactMessage, :count)
        expect(response).to redirect_to('/contacto')
        expect(flash[:alert]).to eq('Error al eliminar el mensaje de contacto')
      end
    end

    context 'as a non-admin user' do
      before { sign_in @non_admin_user }

      it 'does not delete the contact message' do
        expect {
          delete :eliminar, params: { id: @contact_message.id }
        }.not_to change(ContactMessage, :count)
        expect(response).to redirect_to('/contacto')
        expect(flash[:alert]).to eq('Debes ser un administrador para eliminar un mensaje de contacto.')
      end
    end
  end

  describe 'DELETE #limpiar' do
    context 'as an admin user' do
      before { sign_in @admin_user }

      it 'deletes all contact messages' do
        expect {
          delete :limpiar
        }.to change(ContactMessage, :count).by(-1)
        expect(response).to redirect_to('/contacto')
        expect(flash[:notice]).to eq('Mensajes de contacto eliminados correctamente')
      end

      it 'shows an error message if there are no contact messages to delete' do
        ContactMessage.delete_all
        expect {
          delete :limpiar
        }.not_to change(ContactMessage, :count)
        expect(response).to redirect_to('/contacto')
        expect(flash[:alert]).to eq('Error al eliminar los mensajes de contacto')
      end
    end

    context 'as a non-admin user' do
      before { sign_in @non_admin_user }

      it 'does not delete any contact messages' do
        expect {
          delete :limpiar
        }.not_to change(ContactMessage, :count)
        expect(response).to redirect_to('/contacto')
        expect(flash[:alert]).to eq('Debes ser un administrador para eliminar los mensajes de contacto.')
      end
    end
  end
end