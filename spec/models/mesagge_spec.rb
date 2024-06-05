require 'rails_helper'

RSpec.describe Message, type: :model do
    before(:each) do
        @user = User.create!(name: 'John1', password: 'Nonono123!', email: 'asdf@gmail.com',
            role: 'admin')
        @product = Product.create!(nombre: 'John1', precio: 4000, stock: 1, user_id: @user.id, categories: 'Cancha')
        @message = Message.new(body: 'Hola', user_id: @user.id, product_id: @product.id)
    end

    it 'is valid with valid attributes' do
        expect(@message).to be_valid
    end

    it 'is invalid without a body' do
        @message.body = nil
        expect(@message).to_not be_valid
    end

end