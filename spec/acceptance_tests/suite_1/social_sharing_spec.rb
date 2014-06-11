require 'rails_helper'

describe 'social sharing', type: :feature do

  before :each do
    @user = FactoryGirl.create :user
    @feed = FactoryGirl.create :feed
    @entry = FactoryGirl.build :entry, feed_id: @feed.id
    @feed.entries << @entry
    @user.subscribe @feed.fetch_url

    login_user_for_feature @user
    read_feed @feed, @user
  end

  it 'shows twitter share link', js: true do
    read_entry @entry

    within "#entry-#{@entry.id}-summary .entry-toolbar" do
      expect(page).to have_css "a[target='_blank'][href='https://twitter.com/intent/tweet?url=#{@entry.url}&via=feedbunch&text=#{@entry.title}']"
    end
  end

  it 'shows facebook share link', js: true do
    read_entry @entry

    within "#entry-#{@entry.id}-summary .entry-toolbar" do
      expect(page).to have_css "a[target='_blank'][ng-click='share_facebook_entry(entry)']"
    end
  end

end