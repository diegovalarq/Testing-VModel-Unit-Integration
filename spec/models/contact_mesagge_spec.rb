require 'rails_helper'

RSpec.describe ContactMessage, type: :model do
    before(:each) do
        @contact_message = ContactMessage.new(
            title: 'Title',
            body: 'Body',
            name: 'Name',
            mail: 'test@gmail.com',
            phone: '+56912345678'
        )
    end

    it 'is valid with valid attributes' do
        expect(@contact_message).to be_valid
    end

    it 'is invalid without title' do
        @contact_message.title = nil
        expect(@contact_message).to_not be_valid
    end

    it 'is invalid with a title longer than 50 characters' do
        @contact_message.title = 't' * 51
        expect(@contact_message).to_not be_valid
    end

    it 'is invalid without body' do
        @contact_message.body = nil
        expect(@contact_message).to_not be_valid
    end

    it 'is invalid with a body longer than 500 characters' do
        @contact_message.body = 'b' * 501
        expect(@contact_message).to_not be_valid
    end

    it 'is invalid without name' do
        @contact_message.name = nil
        expect(@contact_message).to_not be_valid
    end

    it 'is invalid with a name longer than 50 characters' do
        @contact_message.name = 'n' * 51
        expect(@contact_message).to_not be_valid
    end

    it 'is invalid without mail' do
        @contact_message.mail = nil
        expect(@contact_message).to_not be_valid
    end

    it 'is invalid with a mail longer than 50 characters' do
        @contact_message.mail = 'm' * 41 + '@gmail.com'
        expect(@contact_message).to_not be_valid
    end

    it 'is invalid with an wrong format mail' do
        @contact_message.mail = 'testgmail.com'
        expect(@contact_message).to_not be_valid
    end

    it 'is valid without phone' do
        @contact_message.phone = nil
        expect(@contact_message).to be_valid
    end

    it 'is invalid with a phone longer than 20 characters' do
        @contact_message.phone = '+569' + '1' * 17
        expect(@contact_message).to_not be_valid
    end

    it 'is invalid with more number than required by format (9)' do
        @contact_message.phone = '+5694248135'
        expect(@contact_message).to_not be_valid
    end

    it 'is invalid without prefix +56' do
        @contact_message.phone = '5694248135'
        expect(@contact_message).to_not be_valid
    end

end