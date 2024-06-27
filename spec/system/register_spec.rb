require 'rails_helper'

RSpec.describe 'User registration', type: :system do
  before do
    driven_by(:rack_test)
  end

  describe 'register page' do
    before do
      visit '/register'
    end

    it 'displays the register form' do
      expect(page).to have_selector('h2', text: 'Registro')
      expect(page).to have_field('user[email]')
      expect(page).to have_field('user[name]')
      expect(page).to have_field('user[password]')
      expect(page).to have_field('user[password_confirmation]')
      expect(page).to have_field('user[role]')
      expect(page).to have_button('Registrarse')
    end

    context 'with valid information' do
      it 'allows user to register' do
        fill_in 'user[email]', with: 'junio@corre.com'
        fill_in 'user[name]', with: 'DiegoTest'
        fill_in 'user[password]', with: 'Testing2024'
        fill_in 'user[password_confirmation]', with: 'Testing2024'

        expect {
          click_button 'Registrarse'
        }.to change(User, :count).by(1)

        expect(page).to have_content('¡Bienvenid@! Te has registrado exitosamente.')
      end
    end

    context 'with invalid information' do
      it 'does not allow user to register' do
        click_button 'Registrarse'

        expect(page).to have_content('Email: no puede estar en blanco')
        expect(page).to have_content('Password: no puede estar en blanco')
        expect(page).to have_content('Name: no puede estar en blanco')
      end

      it 'shows error for non matching passwords' do
        fill_in 'user[email]', with: 'contra@mala.com'
        fill_in 'user[name]', with: 'FredDumb'
        fill_in 'user[password]', with: 'contra123'
        fill_in 'user[password_confirmation]', with: 'sena456'

        click_button 'Registrarse'

        expect(page).to have_content('Password confirmation: no coincide')
      end
    end

    context 'admin registration' do
      it 'allows admin registration with correct secret code' do
        fill_in 'user[email]', with: 'admin@gmail.com'
        fill_in 'user[name]', with: 'El Admins'
        fill_in 'user[password]', with: 'adminpass.123'
        fill_in 'user[password_confirmation]', with: 'adminpass.123'
        fill_in 'user[role]', with: 'admin'

        click_button 'Registrarse'

        expect(User.last.role).to eq('admin')
      end
    end
  end
end