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
    @product.categories = 'Cancha, Accesorio tecnologico a'
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

  it 'day to number returns the correct number for each day' do
    expect(@product.day_to_number('Monday')).to eq(1)
    expect(@product.day_to_number('Tuesday')).to eq(2)
    expect(@product.day_to_number('Wednesday')).to eq(3)
    expect(@product.day_to_number('Thursday')).to eq(4)
    expect(@product.day_to_number('Friday')).to eq(5)
    expect(@product.day_to_number('Saturday')).to eq(6)
    expect(@product.day_to_number('Sunday')).to eq(7)
  end

  describe '#date_on_range' do
    it 'returns true if the date is in the range with same start and end day' do
      expect(@product.date_on_range(3, 3, '08:00', '20:00', '2024-06-05T12:00:00')).to eq(true)
    end

    it 'returns false if the date is out of range with same start and end day' do
      expect(@product.date_on_range(3, 3, '08:00', '20:00', '2024-06-05T21:00:00')).to eq(false)
    end

    it 'returns true if the date is within start day range' do
      expect(@product.date_on_range(3, 5, '08:00', '20:00', '2024-06-05T12:00:00')).to eq(true)
    end

    it 'returns true if the date is within end day range' do
      expect(@product.date_on_range(3, 5, '08:00', '20:00', '2024-06-07T12:00:00')).to eq(true)
    end

    it 'returns false if the date is out of end day range' do
      expect(@product.date_on_range(3, 5, '08:00', '10:00', '2024-06-07T11:00:00')).to eq(false)
    end

    it 'returns true if the date is between start and end day' do
      expect(@product.date_on_range(3, 5, '08:00', '20:00', '2024-06-06T12:00:00')).to eq(true)
    end

    it 'returns true if start_day > end_day and date is within range' do
      expect(@product.date_on_range(5, 4, '08:00', '20:00', '2024-06-03T12:00:00')).to eq(true)
    end

    it 'returns false if the date is out of the reversed range' do
      expect(@product.date_on_range(5, 3, '08:00', '20:00', '2024-06-07T07:00:00')).to eq(false)
    end

    it 'returns false if the date is completely out of range' do
      expect(@product.date_on_range(1, 2, '08:00', '10:00', '2024-06-07T09:00:00')).to eq(false)
    end
  end


end
