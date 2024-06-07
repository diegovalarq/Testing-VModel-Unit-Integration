require 'rails_helper'

RSpec.describe Review, type: :model do
  before(:each) do
    @user = User.create!(name: 'John1', password: 'Nonono123!', email: 'asdf@gmail.com')
    @product = Product.create!(nombre: 'Pala Babolat', precio: 4000, stock: 1, user_id: @user.id,
                               categories: 'Cancha')
    @review = Review.new(user_id: @user.id, product_id: @product.id, tittle: 'Excelente',
                         description: 'Muy buena pala', calification: 3)
  end

  it 'is valid with valid attributes' do
    expect(@review).to be_valid
  end

  it 'is invalid without a tittle' do
    @review.tittle = nil
    expect(@review).to_not be_valid
  end

  it 'is invalid with tittle lenght greater than 100' do
    @review.tittle = 'a' * 101
    expect(@review).to_not be_valid
  end

  it 'is valid with tittle lenght equal to 100' do
    @review.tittle = 'a' * 100
    expect(@review).to be_valid
  end

  it 'is valid with tittle lenght less than 100' do
    @review.tittle = 'a' * 99
    expect(@review).to be_valid
  end

  it 'is invalid without a description' do
    @review.description = nil
    expect(@review).to_not be_valid
  end

  it 'is invalid with description lenght greater than 500' do
    @review.description = 'a' * 501
    expect(@review).to_not be_valid
  end

  it 'is valid with description lenght equal to 500' do
    @review.description = 'a' * 500
    expect(@review).to be_valid
  end

  it 'is valid with description lenght less than 500' do
    @review.description = 'a' * 499
    expect(@review).to be_valid
  end

  it 'is invalid without a calification' do
    @review.calification = nil
    expect(@review).to_not be_valid
  end

  it 'is invalid with calification less than 1' do
    @review.calification = 0
    expect(@review).to_not be_valid
  end

  it 'is valid with calification equal to 1' do
    @review.calification = 1
    expect(@review).to be_valid
  end

  it 'is valid with calification equal to 5' do
    @review.calification = 5
    expect(@review).to be_valid
  end

  it 'is invalid with calification greater than 5' do
    @review.calification = 6
    expect(@review).to_not be_valid
  end

  it 'is invalid with non integeger calification' do
    @review.calification = 'Un diez!'
    expect(@review).to_not be_valid
  end
end
