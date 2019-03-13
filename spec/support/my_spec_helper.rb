module MySpecHelper
  def generate_questions(number)
    number.times { FactoryGirl.create(:question) }
  end
end

RSpec.configure { |c| c.include MySpecHelper }
