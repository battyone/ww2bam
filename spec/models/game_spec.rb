require 'rails_helper'
require 'support/my_spec_helper'

RSpec.describe Game, type: :model do
  let(:user) { FactoryBot.create(:user) }
  let(:game_w_questions) { FactoryBot.create(:game_with_questions, user: user) }

  context 'Game Factory' do
    it 'Game.create_game! new correct game' do
      generate_questions(60)
      game = nil

      expect { game = Game.create_game_for_user!(user) }.to change(Game, :count).by(1).
        and(change(GameQuestion, :count).by(15).and(change(Question, :count).by(0)))
      expect(game.user).to eq(user)
      expect(game.status).to eq(:in_progress)
      expect(game.game_questions.size).to eq(15)
      expect(game.game_questions.map(&:level)).to eq (0..14).to_a
    end
  end

  context 'game mechanics' do
    it 'answer correct continues game' do
      level = game_w_questions.current_level
      q = game_w_questions.current_game_question

      expect(game_w_questions.status).to eq(:in_progress)

      game_w_questions.answer_current_question!(q.correct_answer_key)

      expect(game_w_questions.current_level).to eq(level + 1)
      expect(game_w_questions.current_game_question).not_to eq(q)
      expect(game_w_questions.status).to eq(:in_progress)
      expect(game_w_questions.finished?).to be_falsey
    end

    it '#take_money! finishes the game' do
      q = game_w_questions.current_game_question
      game_w_questions.answer_current_question!(q.correct_answer_key)

      game_w_questions.take_money!

      expect(game_w_questions.status).to eq :money
      expect(game_w_questions.finished?).to be true
      expect(game_w_questions.prize).to eq Game::PRIZES.first
      expect(user.balance).to eq game_w_questions.prize
    end
  end

  context 'status' do
    before(:each) do
      game_w_questions.finished_at = Time.now
      expect(game_w_questions.finished?).to be true
    end

    it ':won' do
      game_w_questions.current_level = Question::QUESTION_LEVELS.max + 1
      expect(game_w_questions.status).to eq :won
    end

    it ':fail' do
      game_w_questions.is_failed = true
      expect(game_w_questions.status).to eq :fail
    end

    it ':timeout' do
      game_w_questions.created_at = 1.hour.ago
      game_w_questions.is_failed = true
      expect(game_w_questions.status).to eq :timeout
    end

    it ':money' do
      expect(game_w_questions.status).to eq :money
    end
  end

  context 'current_game_question' do
    it 'returns current game question' do
      expect(game_w_questions.current_game_question).to eq game_w_questions.game_questions.first
    end
  end

  context 'previous_level' do
    it 'returns previous game level' do
      expect(game_w_questions.previous_level).to eq -1

      q = game_w_questions.current_game_question
      game_w_questions.answer_current_question!(q.correct_answer_key)
      expect(game_w_questions.previous_level).to eq 0
    end
  end

  context 'answer_current_question!' do
    let(:q) { game_w_questions.current_game_question }
    let(:wrong) { %w[a b c d].delete_if { |a| a == q.correct_answer_key }.sample }

    it 'answer is correct' do
      expect(game_w_questions.answer_current_question!(q.correct_answer_key)).to be true
      expect(game_w_questions.current_level).to eq 1
      expect(game_w_questions.status).to eq :in_progress
      expect(game_w_questions.finished?).to be false
    end

    it 'answer is wrong' do
      expect(game_w_questions.answer_current_question!(wrong)).to be false
      expect(game_w_questions.status).to eq :fail
      expect(game_w_questions.finished?).to be true
    end

    it 'question is last' do
      game_w_questions.current_level = Question::QUESTION_LEVELS.max
      game_w_questions.answer_current_question!(q.correct_answer_key)

      expect(game_w_questions.status).to eq :won
      expect(game_w_questions.finished?).to be true
      expect(game_w_questions.prize).to eq Game::PRIZES.last
    end

    it 'timeout' do
      game_w_questions.created_at = 1.hour.ago

      expect(game_w_questions.answer_current_question!(q.correct_answer_key)).to be false
      expect(game_w_questions.status).to eq :timeout
      expect(game_w_questions.finished?).to be true
    end
  end
end
