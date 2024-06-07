require 'rails_helper'

RSpec.describe ReviewController, type: :controller do
  before do
    @admin_user = User.create!(name: 'Admin', password: 'Password123!', email: 'adminx@example.com', role: 'admin')
    @non_admin_user = User.create!(name: 'User', password: 'Password123!', email: 'user@example.com', role: 'user')
    @product = Product.create!(nombre: 'Product1', precio: 5000, stock: 5, user: @non_admin_user, categories: 'Cancha')

    @review = Review.create!(tittle: 'Great Product', description: 'Todo bien', calification: 5, product_id: @product.id, user_id: @non_admin_user.id)
    sign_in @non_admin_user
  end

  describe 'POST #insertar' do
    let(:valid_params) { { review: { tittle: 'Awesome', description: 'Me encanta el producto', calification: 5, product_id: @product, user_id: @non_admin_user.id} } }
    let(:invalid_params) { { review: { tittle: '', description: '', calification: 5 }, product_id: @product.id, user: @non_admin_user} }

    it 'creates a new review with valid parameters' do
      post :insertar, params: valid_params
      puts flash[:error]

      expect(response).to redirect_to("/products/leer/#{@product.id}")
      expect(flash[:notice]).to eq('Review creado Correctamente!')

      # new_review = Review.order(created_at: :desc).first
      # expect(new_review.tittle).to eq('Awesome')
    end

    it 'does not create a new review with invalid parameters' do
      post :insertar, params: invalid_params
      expect(flash[:error]).to eq('Hubo un error al guardar la reseña; debe completar todos los campos solicitados.')
      expect(response).to redirect_to("/products/leer/#{@product.id}")
    end
  end

  describe 'PATCH #actualizar_review' do
    let(:update_params) { { review: { tittle: 'Updated Title', description: 'Actualizado', calification: 4 } } }

    it 'updates an existing review with valid parameters' do
      patch :actualizar_review, params: { id: @review.id }.merge(update_params)
      expect(response).to redirect_to("/products/leer/#{@product.id}")
      # expect(@review.reload.tittle).to eq('Updated Title')
    end

    it 'does not update a review with invalid parameters' do
      patch :actualizar_review, params: { id: @review.id, review: { tittle: '', description: 'Bueno', calification: 4 } }
      puts flash[:error]
      expect(flash[:error]).to eq('Hubo un error al editar la reseña. Complete todos los campos solicitados!')
      expect(response).to redirect_to("/products/leer/#{@product.id}")
    end
  end

  describe 'DELETE #eliminar' do
    it 'deletes an existing review' do
      delete :eliminar, params: { id: @review.id }
      expect(response).to redirect_to("/products/leer/#{@product.id}")
      expect(Review.exists?(@review.id)).to be_falsey
    end
  end
end
