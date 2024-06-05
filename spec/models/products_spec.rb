# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Product, type: :model do
  before(:each) do
    @user = User.create!(name: 'John1', password: 'Nonono123!', email: 'asdf@gmail.com')
    @product = Product.new(nombre: 'Pala Babolat', precio: 4000, stock: 1, user_id: @user.id, categories: 'Cancha')
  end

  it 'is valid with valid attributes' do
    expect(@product).to be_valid
  end

  it 'is invalid without a category' do
    @product.categories = nil
    expect(@product).to_not be_valid
  end

  it 'is invalid with multiple categories' do
    @product.categories = 'Cancha, Accesorio tecnologico'
    expect(@product).to_not be_valid
  end

  it 'is invalid with empty a name' do
    @product.nombre = nil
    expect(@product).to_not be_valid
  end

  it 'is invalid with empty a stock' do
    @product.stock = nil
    expect(@product).to_not be_valid
  end

  it 'is valid with stock greater than 0' do
    @product.stock = 100
    expect(@product).to be_valid
  end

  it 'is valid with stock equal to 0' do
    @product.stock = 0
    expect(@product).to be_valid
  end

  it 'is invalid with stock less than 0' do
    @product.stock = -1
    expect(@product).to_not be_valid
  end

  it 'is invalid with empty a price' do
    @product.precio = nil
    expect(@product).to_not be_valid
  end

  it 'is valid with price greater than 0' do
    @product.precio = 100
    expect(@product).to be_valid
  end

  it 'is valid with price equal to 0' do
    @product.precio = 0
    expect(@product).to be_valid
  end

  it 'is invalid with price less than 0' do
    @product.precio = -1
    expect(@product).to_not be_valid
  end




end
