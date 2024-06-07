require 'rails_helper'

RSpec.describe User, type: :model do
    before(:each) do
        @user = User.create!(name: 'John1', password: 'Nonono123!', email: 'asdf@gmail.com')
    end

    it 'is valid with valid attributes' do
        expect(@user).to be_valid
    end

    it 'is invalid without a name' do
        @user.name = nil
        expect(@user).to_not be_valid
    end

    it 'is invalid with a name shorter than 2 characters' do
        @user.name = 'x'
        expect(@user).to_not be_valid
    end

    it 'is invalid with a name longer than 25 characters' do
        @user.name = 'x' * 26
        expect(@user).to_not be_valid
    end

    it 'is invalid with repeated email' do
        @user2 = User.new(name: 'John2', password: 'Nonono', email: 'asdf@gmail.com')
        expect(@user2).to_not be_valid
    end

    it 'is invalid without an email' do
        @user.email = nil
        expect(@user).to_not be_valid
    end

    it 'is admin when role is admin' do
        @user.role = 'admin'
        expect(@user.admin?).to eq(true)
    end

    it 'password strenght validation return nil when password is nil' do
        @user.password = nil
        expect(@user.validate_password_strength).to eq(nil)
    end

    it 'password strenght validation return nil when password is valid' do
        @user.password = 'Nonono123!'
        expect(@user.validate_password_strength).to eq(nil)
    end

    it 'adds an error when password is missing an uppercase letter' do
        @user.password = 'nonono123!'
        @user.validate_password_strength
        expect(@user.errors[:password]).to include('no es válido incluir como minimo una mayuscula, minuscula y un simbolo')
    end

    it 'adds an error when password is missing an symbol' do
        @user.password = 'nonono123'
        @user.validate_password_strength
        expect(@user.errors[:password]).to include('no es válido incluir como minimo una mayuscula, minuscula y un simbolo')
    end

    it 'not error when wish product is empty' do
        @user.deseados = []
        @user.validate_new_wish_product
        expect(@user.errors[:deseados]).to eq([])
    end

    it 'not error when wish product is valid' do
        @product = Product.create!(nombre: 'John1', precio: 4000, stock: 1, user_id: @user.id, categories: 'Cancha')
        @user.deseados = [@product.id]
        @user.validate_new_wish_product
        expect(@user.errors[:deseados]).to eq([])
    end

    it 'error when product added to wish list does not exist' do
        @product = Product.create!(nombre: 'John1', precio: 4000, stock: 1, user_id: @user.id, categories: 'Cancha')
        @user.deseados = [@product.id + 1]
        @user.validate_new_wish_product
        expect(@user.errors[:deseados]).to include('el articulo que se quiere ingresar a la lista de deseados no es valido')
    end


end