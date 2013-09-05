require 'spec_helper'

describe 'start page' do

  before :each do
    @user = FactoryGirl.create :user
    @feed1 = FactoryGirl.create :feed
    @user.subscribe @feed1.fetch_url
    @entry1 = FactoryGirl.build :entry, feed_id: @feed1.id
    @feed1.entries << @entry1

    login_user_for_feature @user
    visit feeds_path
  end

  it 'shows start page by default', js: true do
    page.should have_css '#start-info'
    page.should have_css '#feed-entries.hidden', visible: false
  end

  it 'hides feed title and entries by default', js: true do
    page.should have_css '#feed-title.hidden', visible: false
    page.should have_css '#feed-entries.hidden', visible: false
  end

  it 'hides entries management button by default', js: true do
    page.should have_css '#entries-management.hidden', visible: false
  end

  it 'hides start page when reading a feed', js: true do
    page.should have_css '#start-info'
    page.should have_css '#feed-entries.hidden', visible: false

    read_feed @feed1.id

    page.should have_css '#start-info.hidden', visible: false
    page.should have_css '#feed-entries'
  end

  context 'click on Start link' do

    before :each do
      # click on a feed, then click on the Start link
      read_feed @feed1.id
      find('#start-page').click
    end

    it 'shows start page', js: true do
      page.should have_css '#start-info'
      page.should have_css '#feed-entries.hidden', visible: false
    end

    it 'hides feed title and entries', js: true do
      page.should have_css '#feed-title.hidden', visible: false
      page.should have_css '#feed-entries.hidden', visible: false
    end

    it 'hides entries management button', js: true do
      page.should have_css '#entries-management.hidden', visible: false
    end

  end

  context 'stats' do

    before :each do
      @feed2 = FactoryGirl.create :feed
      @user.subscribe @feed2.fetch_url
      @entry2 = FactoryGirl.build :entry, feed_id: @feed2.id
      @entry3 = FactoryGirl.build :entry, feed_id: @feed2.id
      @feed2.entries << @entry2 << @entry3

      visit feeds_path
    end

    it 'shows number of subscribed feeds', js: true do
      page.should have_content '2 feeds'
    end

    it 'shows number of unread entries', js: true do
      page.should have_content '3 unread entries'
    end
  end

end