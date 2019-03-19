require 'rails_helper'

RSpec.describe 'users/show', type: :view do
  context 'somebody watches user page' do
    before(:each) do
      assign(:user, FactoryGirl.build_stubbed(:user, name: 'Вован'))
      assign(:games, [FactoryGirl.build_stubbed(:game, id: 22, created_at: Time.now, current_level: 11)])

      render
    end

    it 'renders player name' do
      expect(rendered).to match 'Вован'
    end

    it 'does not render link for changing registration data' do
      expect(rendered).not_to match 'Сменить имя и пароль'
    end

    it 'renders games info' do
      assert_template partial: 'users/_game'
    end
  end

  context 'user watches own page' do
    before(:each) do
      user = FactoryGirl.create(:user, name: 'Вован')
      sign_in user
      assign(:user, user)

      assign(:games, [FactoryGirl.build_stubbed(:game, id: 22, created_at: Time.now, current_level: 11)])

      render
    end

    it 'renders player name' do
      expect(rendered).to match 'Вован'
    end

    it 'renders link for changing registration data only for relevant user' do
      expect(rendered).to match 'Сменить имя и пароль'
    end

    it 'renders games info' do
      assert_template partial: 'users/_game'
    end
  end
end
