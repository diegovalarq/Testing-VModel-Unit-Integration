require 'rails_helper'

RSpec.describe Solicitud, type: :model do
    before(:each) do
        @user = User.create!(name: 'John1', password: 'Nonono123!', email: 'asdf@gmail.com',
            role: 'admin')
        @product = Product.create!(nombre: 'John1', precio: 4000, stock: 1, user_id: @user.id, categories: 'Cancha')
        @solicitud = Solicitud.new(
            stock: 1,
            status: 'En espera',
            product_id: @product.id,
            user_id: @user.id
        )
    end

    it 'is valid with valid attributes' do
        expect(@solicitud).to be_valid
    end

    it 'is invalid without stock' do
        @solicitud.stock = nil
        expect(@solicitud).to_not be_valid
    end

    it 'is invalid with a stock less than 1' do
        @solicitud.stock = 0
        expect(@solicitud).to_not be_valid
    end

    it 'is invalid without stock non integer' do
        @solicitud.stock = 1.1
        expect(@solicitud).to_not be_valid
    end

    it 'is invalid without status' do
        @solicitud.status = nil
        expect(@solicitud).to_not be_valid
    end

end