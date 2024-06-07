require 'rails_helper'


RSpec.describe Ability, type: :model do

       before(:each) do
              @user = User.create!(name: 'John1', password: 'Nonono123!', email: 'asdf@gmail.com')
              @ability = Ability.new(@user)
       end

       it 'if is admin, can manage all' do
              @user.role = 'admin'
              @ability = Ability.new(@user)
              expect(@ability.can? :manage, :all).to eq(true)
       end

       it 'if present user, can leer, insertar and crear Product' do
              expect(@ability.can? :index, Product).to eq(true)
              expect(@ability.can? :leer, Product).to eq(true)
              expect(@ability.can? :insertar, Product).to eq(true)
              expect(@ability.can? :crear, Product).to eq(true)
       end

       it 'if present user, can leer, insertar and crear Review' do
              expect(@ability.can? :index, Review).to eq(true)
              expect(@ability.can? :leer, Review).to eq(true)
              expect(@ability.can? :insertar, Review).to eq(true)
              expect(@ability.can? :crear, Review).to eq(true)
       end

       it 'if present user, can leer and insertar Message' do
              expect(@ability.can? :leer, Message).to eq(true)
              expect(@ability.can? :insertar, Message).to eq(true)
       end

       it 'user can insertar Product deseado if it does not belong to him' do
              @user_2 = User.create!(name: 'John2', password: 'Nonono123!', email: 'asda@gmail.com')
              @product = Product.create!(nombre: 'John1', precio: 4000, stock: 1, user_id: @user_2.id, categories: 'Cancha')
              expect(@ability.can? :insert_deseado, @product).to eq(true)
       end

       it 'user can not insertar Product deseado if it belongs to him' do
              @product = Product.new(nombre: 'John1', precio: 4000, stock: 1, user_id: @user.id, categories: 'Cancha')
              expect(@ability.can? :insert_deseado, @product).to eq(false)
       end

       it 'user can insert Solicitud if it does not belong to him' do
              @user_2 = User.create!(name: 'John2', password: 'Nonono123!', email: 'test@gmail.com')
              @product = Product.create!(nombre: 'John1', precio: 4000, stock: 1, user_id: @user_2.id, categories: 'Cancha')
              @solicitud = Solicitud.new(user_id: @user_2.id, product_id: @product.id)
              expect(@ability.can? :insertar, @solicitud).to eq(true)
       end

       it 'user can not insertar Solicitud if it belongs to him' do
              @product = Product.new(nombre: 'John1', precio: 4000, stock: 1, user_id: @user.id, categories: 'Cancha')
              @solicitud = Solicitud.new(user_id: @user.id, product_id: @product.id)
              expect(@ability.can? :insertar, @solicitud).to eq(false)
       end

       it 'user can eliminar and actualizar Product if it belongs to him' do
              @product = Product.new(nombre: 'John1', precio: 4000, stock: 1, user_id: @user.id, categories: 'Cancha')
              expect(@ability.can? :eliminar, @product).to eq(true)
              expect(@ability.can? :actualizar_producto, @product).to eq(true)
              expect(@ability.can? :actualizar, @product).to eq(true)
       end

       it 'user can eliminar and leer Solicitud if it belongs to him' do
              @product = Product.create!(nombre: 'John1', precio: 4000, stock: 1, user_id: @user.id, categories: 'Cancha')
              @solicitud = Solicitud.new(user_id: @user.id, product_id: @product.id)
              expect(@ability.can? :eliminar, @solicitud).to eq(true)
              expect(@ability.can? :leer, @solicitud).to eq(true)
       end

       it 'user can eliminar and actualizar Solicitud if the product of the Solicitud belongs to him' do
              @product = Product.create!(nombre: 'John1', precio: 4000, stock: 1, user_id: @user.id, categories: 'Cancha')
              @solicitud = Solicitud.new(user_id: @user.id, product_id: @product.id)
              expect(@ability.can? :eliminar, @solicitud).to eq(true)
              expect(@ability.can? :actualizar, @solicitud).to eq(true)
       end

       it 'user can eliminar and actualizar Review if it belongs to him' do
              @review = Review.new(user_id: @user.id)
              expect(@ability.can? :eliminar, @review).to eq(true)
              expect(@ability.can? :actualizar_review, @review).to eq(true)
              expect(@ability.can? :actualizar, @review).to eq(true)
       end

       it 'user can eliminar Message if it belongs to him' do
              @message = Message.new(user_id: @user.id)
              expect(@ability.can? :eliminar, @message).to eq(true)
       end

       it 'user can not eliminar Message if it does not belong to him' do
              @user_2 = User.create!(name: 'John2', password: 'Nonono123!', email: 'asda@gmail.com')
              @message = Message.new(user_id: @user_2.id)
              expect(@ability.can? :eliminar, @message).to eq(false)
       end

       it 'if user is nil, can leer Product, Review and Message' do
              @ability = Ability.new(nil)
              expect(@ability.can? :index, Product).to eq(true)
              expect(@ability.can? :leer, Product).to eq(true)
              expect(@ability.can? :index, Review).to eq(true)
              expect(@ability.can? :leer, Review).to eq(true)
              expect(@ability.can? :leer, Message).to eq(true)
       end

              
end