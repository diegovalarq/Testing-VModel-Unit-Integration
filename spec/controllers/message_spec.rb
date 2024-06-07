require 'rails_helper'

RSpec.describe 'Messages', type: :request do
  before do
    @admin_user = User.create!(name: 'Admin', password: 'Password123!', email: 'admin@example.com', role: 'admin')
    @non_admin_user = User.create!(name: 'User', password: 'Password123!', email: 'user@example.com', role: 'user')
    @product = Product.create!(nombre: 'Product1', precio: 5000, stock: 5, user_id: @admin_user.id, categories: 'Cancha')
    @message = Message.create!(body: 'This is a message', product_id: @product.id, user_id: @non_admin_user.id)
    sign_in @non_admin_user
  end

  describe 'POST /message/insertar' do
    let(:valid_params) { { message: { body: 'This is a new message' }, product_id: @product.id } }
    let(:invalid_params) { { message: { body: '' }, product_id: @product.id } }

    it 'creates a new message with valid parameters' do
      post '/message/insertar', params: valid_params
      expect(flash[:notice]).to eq('Pregunta creada correctamente!')
      expect(response).to redirect_to("/products/leer/#{@product.id}")
      expect(Message.last.body).to eq('This is a new message')
    end

    it 'does not create a new message with invalid parameters' do
      post '/message/insertar', params: invalid_params
      expect(flash[:error]).to eq('Hubo un error al guardar la pregunta. ¡Completa todos los campos solicitados!')
      expect(response).to redirect_to("/products/leer/#{@product.id}")
    end

    it 'creates a new message with ancestry' do
      parent_message = Message.create!(body: 'Parent message', product_id: @product.id, user_id: @non_admin_user.id)
      post '/message/insertar', params: valid_params.merge(message: { body: 'This is a child message', ancestry: parent_message.id.to_s })
      expect(flash[:notice]).to eq('Pregunta creada correctamente!')
      expect(response).to redirect_to("/products/leer/#{@product.id}")
      expect(Message.last.body).to eq('This is a child message')
      expect(Message.last.parent).to eq(parent_message)
    end
  end

  describe 'DELETE /message/eliminar' do
    it 'deletes a message' do
      delete '/message/eliminar', params: { message_id: @message.id, product_id: @product.id }
      expect(response).to redirect_to("/products/leer/#{@product.id}")
      expect(Message.exists?(@message.id)).to be_falsey
    end
  end
end
