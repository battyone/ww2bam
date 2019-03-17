require 'rails_helper'
require 'support/my_spec_helper'

RSpec.describe GamesController, type: :controller do
  let(:user) { FactoryGirl.create(:user) }
  let(:admin) { FactoryGirl.create(:user, is_admin: true) }
  let(:game_w_questions) { FactoryGirl.create(:game_with_questions, user: user) }

  context 'Anon' do
    it 'cannot create new game' do
      generate_questions(15)
      post :create
      game = assigns(:game)

      expect(game).to be_nil
      expect(response.status).not_to eq 200
      expect(response).to redirect_to(new_user_session_path)
      expect(flash[:alert]).to be
    end

    it 'kicks from #show' do
      get :show, id: game_w_questions.id

      expect(response.status).not_to eq 200
      expect(response).to redirect_to(new_user_session_path)
      expect(flash[:alert]).to be
    end

    it 'cannot answer' do
      put :answer, id: game_w_questions.id, letter: game_w_questions.current_game_question.correct_answer_key
      game = assigns(:game)

      expect(game).to be_nil
      expect(response.status).not_to eq 200
      expect(response).to redirect_to(new_user_session_path)
      expect(flash[:alert]).to be
    end

    it 'cannot take_money' do
      put :take_money, id: game_w_questions.id
      game = assigns(:game)

      expect(game).to be_nil
      expect(response.status).not_to eq 200
      expect(response).to redirect_to(new_user_session_path)
      expect(flash[:alert]).to be
    end
  end

  context 'Usual user' do
    before(:each) { sign_in user }

    it 'creates game' do
      generate_questions(15)
      post :create
      game = assigns(:game)

      expect(game.finished?).to be false
      expect(game.user).to eq(user)
      expect(response).to redirect_to(game_path(game))
      expect(flash[:notice]).to be
    end

    it '#show game' do
      get :show, id: game_w_questions.id
      game = assigns(:game)

      expect(game.finished?).to be false
      expect(game.user).to eq(user)
      expect(response.status).to eq 200
      expect(response).to render_template(:show)
    end

    it 'answers correct' do
      put :answer, id: game_w_questions.id, letter: game_w_questions.current_game_question.correct_answer_key
      game = assigns(:game)

      expect(game.finished?).to be false
      expect(game.status).to eq :in_progress
      expect(game.current_level).to be > 0
      expect(response).to redirect_to(game_path(game))
      expect(flash.empty?).to be true
    end

    it 'answers wrong' do
      q = game_w_questions.current_game_question
      wrong = %w[a b c d].find { |a| a != q.correct_answer_key }
      put :answer, id: game_w_questions.id, letter: wrong
      game = assigns(:game)

      expect(game.finished?).to be true
      expect(game.status).to eq :fail
      expect(game.current_level).to be_zero
      expect(response).to redirect_to(user_path(user))
      expect(flash[:alert]).to be
    end

    it 'cannot call #show foreign game' do
      foreign_game = FactoryGirl.create(:game_with_questions)
      get :show, id: foreign_game.id

      expect(response.status).not_to eq 200
      expect(response).to redirect_to(root_path)
      expect(flash[:alert]).to be
    end

    it 'should perform #take_money action' do
      game_w_questions.update_attribute(:current_level, 2)
      put :take_money, id: game_w_questions.id
      game = assigns(:game)

      expect(response).to redirect_to(user_path(user))
      expect(flash[:warning]).to include Game::PRIZES.second.to_s
      expect(game.finished?).to be true
      expect(game.status).to eq :money

      user.reload
      expect(user.balance).to eq Game::PRIZES.second
    end

    it 'should perform #goto_game_in_progress!' do
      expect(game_w_questions.finished?).to be false
      expect { post :create }.to change(Game, :count).by(0)

      game = assigns(:game)

      expect(game).to be_nil
      expect(response).to redirect_to(game_path(game_w_questions))
      expect(flash[:alert]).to be
    end

    it 'uses fifty_fifty' do
      expect(game_w_questions.current_game_question.help_hash[:fifty_fifty]).not_to be
      expect(game_w_questions.audience_help_used).to be false

      put :help, id: game_w_questions.id, help_type: :fifty_fifty
      game = assigns(:game)

      expect(game.finished?).to be false
      expect(game.fifty_fifty_used).to be true
      expect(game.current_game_question.help_hash[:fifty_fifty]).to include(game.current_game_question.correct_answer_key)
      expect(game.current_game_question.help_hash[:fifty_fifty].count).to eq 2
      expect(response).to redirect_to(game_path(game))
    end

    it 'uses audience help' do
      expect(game_w_questions.current_game_question.help_hash[:audience_help]).not_to be
      expect(game_w_questions.audience_help_used).to be false

      put :help, id: game_w_questions.id, help_type: :audience_help
      game = assigns(:game)

      expect(game.finished?).to be false
      expect(game.audience_help_used).to be true
      expect(game.current_game_question.help_hash[:audience_help]).to be
      expect(game.current_game_question.help_hash[:audience_help].keys).to match_array %w[a b c d]
      expect(response).to redirect_to(game_path(game))
    end
  end
end
