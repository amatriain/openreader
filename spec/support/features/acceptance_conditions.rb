##
# Test that a user is logged in, during an acceptance test.
#
# To see if the user is logged in, we check the presence of a "Logout" link in the navbar.

def user_should_be_logged_in
  expect(page).to have_css 'div.navbar #user-dropdown', visible: true
end

##
# Test that a user is not logged in, during an acceptance test.
#
# To see if the user is not logged in, we check the absence of a "Logout" link in the navbar.

def user_should_not_be_logged_in
  expect(page).to have_no_css 'div.navbar div.navbar-inner ul li a#sign_out', visible: false
end

##
# Test that the page javascript has finished loading.

def page_should_finish_loading
  expect(page).not_to have_css '.sidebar-spinner'
  expect(page).to have_css '#subscription-stats'
end

##
# Test that an email has been sent during acceptance testing. Accepts the following arguments:
#
# - text - variable-length array of strings. The method tests that all strings are present in the email body.
# - path - optional. If passed, tests that the mail contains a link to this path. Ideally we'd like to test using full
# URLs but this not possible because during testing links inside emails generated by ActionMailer use the hostname
# "www.example.com" instead of the actual "localhost:3000" returned by Rails URL helpers.
# - to - optional. If passed, tests that this is the value of the email's "to" header.
#
# Return value is the href of the link if "path" option is passed, nil otherwise.

def mail_should_be_sent(*text, path: nil, to: nil)
  # Check up to 5 times if email has been sent, in case test runs too fast
  email = nil
  email_sent = false
  (1..5).each do
    email = ActionMailer::Base.deliveries.pop
    email_sent = email.present?
    break if email_sent
    sleep 1
  end

  expect(email_sent).to be true

  if to.present?
    expect(email.to.first).to eq to
  end

  href = nil
  # Test each part of a multipart email.
  if email.multipart?
    # A link to "path" must be found in at least one of the email parts
    if path.present?
      link_found = false
      email.parts.each do |part|
        partBody = Nokogiri::HTML part.body.to_s
        link = partBody.at_css "a[href*=\"#{path}\"]"
        if link.present?
          link_found = true
          href = link[:href]
        end
      end
      expect(link_found).to be true
    end

    # Each string passed in "text" must be found in at least one of the email parts
    if text.size > 0
      text.each do |t|
        text_found = false
        email.parts.each do |part|
          body_s = part.body.to_s
          if body_s.include? t
            text_found = true
          end
        end
        expect(text_found).to be true
      end
    end
  else
    if path.present?
      emailBody = Nokogiri::HTML email.body.to_s
      link = emailBody.at_css "a[href*=\"#{path}\"]"
      expect(link.present?).to be true
      href = link[:href]
    end

    if text.size > 0
      body_s = email.body.to_s
      text.each {|t| expect(body_s.include? t).to be true}
    end
  end

  return href
end

##
# Test that no email has been sent during acceptance testing

def mail_should_not_be_sent
  email = ActionMailer::Base.deliveries.pop
  expect(email.present?).to be false
end

##
# Test that the count of unread entries in a folder equals the passed argument.
# Receives as argument the folder and the expected entry count.

def unread_folder_entries_should_eq(folder, count)
  if folder=='all'
    within '#sidebar #folders-list #folder-none #feeds-all span.badge' do
      expect(page).to have_content "#{count}"
    end
  else
    within "#sidebar #folders-list #folder-#{folder.id} #open-folder-#{folder.id} span.folder-unread-badge" do
      expect(page).to have_content "#{count}"
    end
  end
end

##
# Test that the count of unread entries in a feed equals the passed argument.
# Receives as arguments:
# - the feed to look at
# - the expected entry count
# - the user performing the action

def unread_feed_entries_should_eq(feed, count, user)
  folder = feed.user_folder user
  folder_id = folder&.id || 'none'
  open_folder folder if folder.present?
  expect(page).to have_css "#sidebar #folders-list #folder-#{folder_id} a[data-sidebar-feed][data-feed-id='#{feed.id}']"
  within "#sidebar #folders-list #folder-#{folder_id} a[data-sidebar-feed][data-feed-id='#{feed.id}'] span.badge" do
    expect(page).to have_content "#{count}"
  end
end

##
# Test that an alert with the passed id is shown on the page, and that it disappears automatically
# after 5 seconds.

def should_show_alert(alert_id)
  expect(page).to have_css "div##{alert_id}", visible: true

  # It should close automatically after 5 seconds
  sleep 5
  expect(page).to have_no_css "div##{alert_id}", visible: true
end

##
# Test that an alert with the passed id is hidden-

def should_hide_alert(alert_id)
  expect(page).to have_no_css "div##{alert_id}", visible: true
end

##
# Test that the passed entry is visible.

def entry_should_be_visible(entry)
  expect(page).to have_css "#feed-entries #entry-#{entry.id}"
  within "#feed-entries #entry-#{entry.id}" do
    expect(page).to have_text entry.title
  end
end

##
# Test that the passed entry is not visible.

def entry_should_not_be_visible(entry)
  expect(page).to have_no_css "#feed-entries #entry-#{entry.id}"
end

##
# Test that the passed entry is visible and marked as read

def entry_should_be_marked_read(entry)
  expect(page).to have_css "a[data-entry-id='#{entry.id}'].entry-read"
end

##
# Test that the passed entry is visible and marked as unread

def entry_should_be_marked_unread(entry)
  expect(page).to have_css "a[data-entry-id='#{entry.id}'].entry-unread"
end

##
# Test that the passed entry is open.

def entry_should_be_open(entry)
  expect(page).to have_css "div#entry-#{entry.id} div#entry-#{entry.id}-summary.entry_open"
end

##
# Test that the passed entry is open.

def entry_should_be_closed(entry)
  expect(page).to have_css "div#entry-#{entry.id} div#entry-#{entry.id}-summary", visible: false
  expect(page).to have_no_css "div#entry-#{entry.id} div#entry-#{entry.id}-summary.entry_open", visible: true
  expect(page).to have_no_text entry.summary
end

##
# Test that the passed feed is currently selected for reading

def feed_should_be_selected(feed)
  expect(page).to have_css "#sidebar .active > [data-sidebar-feed][data-feed-id='#{feed.id}']"
end

##
# Test that the passed folder is open in the sidebar

def folder_should_be_open(folder)
  expect(page).to have_css "#sidebar #folders-list #folder-#{folder.id} #feeds-#{folder.id}.open-folder"
end

##
# Test that the passed folder is closed in the sidebar

def folder_should_be_closed(folder)
  expect(page).to have_css "#sidebar #folders-list #folder-#{folder.id} #feeds-#{folder.id}", visible: false
  expect(page).to have_no_css "#sidebar #folders-list #folder-#{folder.id} #feeds-#{folder.id}.open-folder"
end

##
# Test that the application tour is visible.
# Optionally accepts the title the tour bubble should have.

def tour_should_be_visible(title=nil)
  expect(page).to have_css 'div.hopscotch-bubble'
  if title.present?
    within 'div.hopscotch-bubble .hopscotch-title' do
      expect(page).to have_text title
    end
  end
end

##
# Test that the application tour is not visible.

def tour_should_not_be_visible
  expect(page).not_to have_css 'div.hopscotch-bubble'
end

##
# Test that the passed entry is highlighted

def entry_should_be_highlighted(entry)
  entry_should_be_visible entry
  within "#feed-entries #entry-#{entry.id}" do
    expect(page).to have_css 'a.open-entry-link.highlighted-entry'
    expect(page).to have_css 'i.fa-caret-right.current-entry', visible: true
  end
end

##
# Test that the passed entry is not highlighted

def entry_should_not_be_highlighted(entry)
  entry_should_be_visible entry
  within "#feed-entries #entry-#{entry.id}" do
    expect(page).not_to have_css 'a.open-entry-link.highlighted-entry'
    expect(page).not_to have_css 'i.fa-caret-right.current-entry', visible: true
  end
end

##
# Test that the start link is highlighted
def start_link_should_be_highlighted
  within '#sidebar' do
    expect(page).to have_css 'a#start-page.highlighted-link'
  end
end

##
# Test that the start link is not highlighted
def start_link_should_not_be_highlighted
  within '#sidebar' do
    expect(page).not_to have_css 'a#start-page.highlighted-link'
  end
end

##
# Test that feed sidebar link is highlighted
def feed_link_should_be_highlighted(feed)
  within "#sidebar #folders-list" do
    expect(page).to have_css "a[data-feed-id='#{feed.id}'].highlighted-link"
  end
end

##
# Test that feed sidebar link is not highlighted
def feed_link_should_not_be_highlighted(feed)
  within '#sidebar #folders-list' do
    expect(page).not_to have_css "a[data-feed-id='#{feed.id}'].highlighted-link"
  end
end

# Test that folder "all subscriptions" sidebar link is highlighted
def folder_link_should_be_highlighted(folder)
  if folder == 'none'
    id = 'none'
  else
    id = folder.id
  end
  within "#sidebar #folders-list #folder-#{id}" do
    expect(page).to have_css "a[data-feed-id='all'].highlighted-link"
  end
end

##
# Test that folder "all subscriptions" sidebar link is not highlighted
def folder_link_should_not_be_highlighted(folder)
  if folder == 'none'
    id = 'none'
  else
    id = folder.id
  end
  within "#sidebar #folders-list #folder-#{id}" do
    expect(page).not_to have_css "a[data-feed-id='all'].highlighted-link"
  end
end