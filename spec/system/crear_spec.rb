require 'rails_helper'

RSpec.describe 'Products', type: :system do
  before do
    driven_by(:rack_test)

    @user_admin = User.create!(name: 'Admin Fred', password: 'FredAgainNo456!',
                               email: "admin_#{SecureRandom.uuid}@fredagain.com", role: 'admin')
    @regular_user = User.create!(name: 'Regular Diego', password: 'Sisisi321?',
                                 email: "diego_#{SecureRandom.uuid}@gmail.com", role: 'user')
  end

  describe 'visiting /products/crear' do
    context 'as an admin' do
      before do
        login_as(@user_admin, scope: :user)
        visit '/products/crear'
      end

      it 'displays product creation form' do
        expect(page).to have_selector('h1', text: 'Crear Producto')
        expect(page).to have_field('Nombre')
        expect(page).to have_field('Precio')
        expect(page).to have_field('Stock')
        expect(page).to have_select('product[categories]')
        expect(page).to have_selector('label', text: 'Imagen')
        expect(page).to have_selector('input[type="file"]')
        expect(page).to have_button('Guardar')
      end

      it 'allows creating a product' do
        fill_in 'Nombre', with: 'Cancha de PADEL AYYY'
        select 'Cancha', from: 'product[categories]'
        fill_in 'Precio', with: '10000321'
        fill_in 'Stock', with: '13'
        attach_file 'product[image]', Rails.root.join('spec/fixtures/files/mock_image.jpg')

        expect do
          click_button 'Guardar'
        end.to change(Product, :count).by(1)

        expect(page).to have_current_path('/products/index')
        expect(page).to have_content('Producto creado Correctamente !')
      end

      it 'includes horarios in the form' do
        expect(page).to have_field('product[horarios]', visible: :hidden)
      end
    end

    context 'as a regular user' do
      it 'shows access denied message' do
        login_as(@regular_user, scope: :user)
        visit '/products/crear'
        expect(page).to have_content('Esta página es exclusiva para administradores.')
      end
    end

    context 'non registered user' do
      it 'redirects to root path' do
        visit '/products/crear'
        expect(page).to have_current_path(root_path)
      end
    end
  end
end
