module MySpecHelper
  def generate_questions(number)
    number.times { FactoryBot.create(:question) }
  end
end

RSpec.configure { |c| c.include MySpecHelper }
