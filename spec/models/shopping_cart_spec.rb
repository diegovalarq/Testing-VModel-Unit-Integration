require 'rails_helper'

RSpec.describe ShoppingCart, type: :model do
    before(:each) do
        @user = User.create!(name: 'John1', password: 'Nonono123!', email: 'asdf@gmail.com')
        @product_1 = Product.create!(nombre: 'Pala Babolat', precio: 4000, stock: 1, user_id: @user.id, categories: 'Cancha')
        @product_2 = Product.create!(nombre: 'Pelota', precio: 1000, stock: 1, user_id: @user.id, categories: 'Cancha')
        @shopping_cart = ShoppingCart.new(user_id: @user.id, products: { @product_1.id => 1, @product_2.id => 1 })
        end

    it 'is valid with valid attributes' do
        expect(@shopping_cart).to be_valid
    end

    it 'is valid with blank products' do
        @shopping_cart.products = {}
        expect(@shopping_cart).to be_valid
    end

    it 'precio total return total price of products' do
        expect(@shopping_cart.precio_total).to eq(5000)
    end 

    it 'precio total return return 0 when no products' do
        @shopping_cart.products = {}
        expect(@shopping_cart.precio_total).to eq(0)
    end

    it 'precio total increase when product stock increases' do
        @shopping_cart.products[@product_1.id.to_s] += 1
        expect(@shopping_cart.precio_total).to eq(9000)
    end

    it 'cost envio equal to the addition of 5% of the price of each product plus 1000' do
        cost = @product_1.precio.to_i * 0.05 * @product_1.stock.to_i + @product_2.precio.to_i * 0.05 * @product_2.stock.to_i + 1000
        expect(@shopping_cart.costo_envio).to eq(cost.round(0))
    end
    
    it 'cost envio equal to 1000 when no products' do
        @shopping_cart.products = {}
        expect(@shopping_cart.costo_envio).to eq(1000)
    end

end