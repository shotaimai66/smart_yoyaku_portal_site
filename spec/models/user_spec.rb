require 'rails_helper'

RSpec.describe User, type: :model do
  before do
    @user = build(:user)
  end

  it "有効なuserを持つこと" do
    expect(@user).to be_valid
  end
end
