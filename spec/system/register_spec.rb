require 'rails_helper'

RSpec.describe 'User registration', type: :system do
  before do
    driven_by(:rack_test)
  end

  describe 'signup page' do
    before { visit new_user_registration_path }

    it 'displays the signup form' do
      expect(page).to have_selector('h2', text: 'Registro')
      expect(page).to have_field('user[email]')
      expect(page).to have_field('user[name]')
      expect(page).to have_field('user[password]')
      expect(page).to have_field('user[password_confirmation]')
      expect(page).to have_field('user[role]')
      expect(page).to have_button('Registrarse')
    end

    context 'with valid information' do
      it 'allows user to sign up' do
        fill_in 'user[email]', with: 'test@example.com'
        fill_in 'user[name]', with: 'Test User'
        fill_in 'user[password]', with: 'password123'
        fill_in 'user[password_confirmation]', with: 'password123'

        expect {
          click_button 'Registrarse'
        }.to change(User, :count).by(1)

        expect(page).to have_content('¡Bienvenid@! Te has registrado exitosamente.')
      end
    end

    context 'with invalid information' do
      it 'does not allow user to sign up' do
        click_button 'Registrarse'

        expect(page).to have_content('Email: no puede estar en blanco')
        expect(page).to have_content('Password: no puede estar en blanco')
        expect(page).to have_content('Name: no puede estar en blanco')
      end

      it 'shows error for mismatched passwords' do
        fill_in 'user[email]', with: 'test@example.com'
        fill_in 'user[name]', with: 'Test User'
        fill_in 'user[password]', with: 'password123'
        fill_in 'user[password_confirmation]', with: 'password456'

        click_button 'Registrarse'

        expect(page).to have_content('Password confirmation: no coincide')
      end
    end

    context 'admin registration' do
      it 'allows admin registration with correct secret code' do
        fill_in 'user[email]', with: 'admin@example.com'
        fill_in 'user[name]', with: 'Admin User'
        fill_in 'user[password]', with: 'password123'
        fill_in 'user[password_confirmation]', with: 'password123'
        fill_in 'user[role]', with: 'correct_secret_code'

        click_button 'Registrarse'

        expect(User.last.role).to eq('admin')
      end
    end
  end
end