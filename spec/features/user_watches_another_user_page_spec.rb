require 'rails_helper'

RSpec.feature 'User watches another user page', type: :feature do
  let(:user) { FactoryGirl.create :user, name: 'Вован' }
  let(:another_user) { FactoryGirl.create :user, name: 'Димон' }

  let!(:games) do
    [
      FactoryGirl.create(:game, id: 28, user: another_user, prize: 1000, current_level: 7, is_failed: true, created_at: Time.parse('2019-01-01 13:00'), finished_at: Time.parse('2019-01-01 13:02')),
      FactoryGirl.create(:game, id: 29, user: another_user, prize: 32000, current_level: 11, created_at: Time.parse('2019-02-02 13:20'))
    ]
  end

  before(:each) do
    login_as user
  end

  scenario 'successfully' do
    visit '/'
    click_link 'Димон'

    expect(page).to have_current_path "/users/#{another_user.id}"
    expect(page).to have_link 'Вован - 0 ₽', href: user_path(user)
    expect(page).to have_content 'Димон'
    expect(page).not_to have_content 'Сменить имя и пароль'

    expect(page).to have_content '29'
    expect(page).to have_content 'в процессе'
    expect(page).to have_content '02 февр., 13:20'
    expect(page).to have_content '11'
    expect(page).to have_content '32 000 ₽'

    expect(page).to have_content '28'
    expect(page).to have_content 'проигрыш'
    expect(page).to have_content '01 янв., 13:00'
    expect(page).to have_content '7'
    expect(page).to have_content '1 000 ₽'
  end
end
