require 'spec_helper'

describe DestroyUserJob do

  before :each do
    @user = FactoryGirl.create :user
  end

  it 'destroys user' do
    User.exists?(@user.id).should be_true
    DestroyUserJob.perform @user.id
    User.exists?(@user.id).should be_false
  end

  context 'validations' do

    it 'does nothing if the user does not exist' do
      User.any_instance.should_not_receive :destroy!
      User.any_instance.should_not_receive :destroy
      DestroyUserJob.perform 1234567890
    end

  end
end