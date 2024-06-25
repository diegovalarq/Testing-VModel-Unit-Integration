require 'rails_helper'

RSpec.describe 'Products', type: :system do
  before do
    @user_admin = User.create!(name: 'John1', password: 'Nonono123!', email: "user_#{SecureRandom.uuid}@example.com",
                         role: 'admin')
    @regular_user = User.create!(name: 'Benjamin', password: 'Nonono123!', 
                                 email: "user_#{SecureRandom.uuid}@example.com", role: 'user')
  end

  describe 'visiting the product form as admin' do
    it 'have form' do
      login_as(@user_admin, scope: :user)
      visit '/products/crear'
      expect(page).to have_selector('h1', text: 'Crear Producto')
    end

    it 'not allowed on the product form' do
      logout(:user)
      visit '/products/crear'
      expect(page).to have_selector('div', text: 'No estás autorizado para acceder a esta página')
    end
  end

  describe 'Visiting Canchas y productos as regular user from landing page' do
    it 'have Canchas y productos h1' do
      login_as(@regular_user, scope: :user)
      visit root_path
      click_link 'Productos'
      expect(page).to have_selector('h1', text: 'Canchas y productos')
    end
  end

  describe 'Visiting Cancha post as regular user from landing page' do
    it 'have Cancha fútbol p' do
      # Create a product as admin
      login_as(@user_admin, scope: :user)
      @product = Product.create!(nombre: 'Cancha fútbol', precio: 5000, stock: 5, user_id: @user_admin.id,
        categories: 'Cancha')
      logout(:user)
      # Visit the product as regular user
      login_as(@regular_user, scope: :user)
      visit root_path
      visit "/products/leer/#{Product.last.id}"
      expect(page).to have_selector('p', text: 'Cancha fútbol')
    end

    it 'have price' do
       # Create a product as admin
       login_as(@user_admin, scope: :user)
       @product = Product.create!(nombre: 'Cancha fútbol', precio: 5000, stock: 5, user_id: @user_admin.id,
         categories: 'Cancha')
       logout(:user)
       # Visit the product as regular user
       login_as(@regular_user, scope: :user)
       visit root_path
       visit "/products/leer/#{Product.last.id}"
       expect(page).to have_selector('p', text: '$ 5.000')
    end
  end

  describe 'visiting solicitud created by regular user' do
    it 'solicitud of Cancha fútbol' do
    # Create a product as admin
    login_as(@user_admin, scope: :user)
       @product = Product.create!(nombre: 'Cancha fútbol', precio: 5000, stock: 5, user_id: @user_admin.id,
         categories: 'Cancha')
       logout(:user)
       # Create a reservation as regular user
        login_as(@regular_user, scope: :user)
        @solicitud = Solicitud.create!(
          stock: 1,
          status: 'Pendiente',
          product_id: @product.id,
          user_id: @regular_user.id
        )
        visit root_path
        visit "/solicitud/index"
        expect(page).to have_selector('p', text: 'Solicitud de reserva para la cancha: Cancha fútbol')
    end
  end

end
