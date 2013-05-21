##
# Perform the actions a user would do to login.
#
# This method is intended to be called during an acceptance (also called feature) test.

def login_user_for_feature(user)
  visit new_user_session_path
  fill_in 'Email', with: user.email
  fill_in 'Password', with: user.password
  click_on 'Sign in'
end

##
# Test that a user is logged in, during an acceptance test.
#
# To see if the user is logged in, we check the presence of a "Logout" link in the navbar.

def user_should_be_logged_in
  page.should have_css 'div.navbar div.navbar-inner ul li a#sign_out'
end

##
# Test that a user is not logged in, during an acceptance test.
#
# To see if the user is not logged in, we check the absence of a "Logout" link in the navbar.

def user_should_not_be_logged_in
  page.should_not have_css 'div.navbar div.navbar-inner ul li a#sign_out'
end

##
# Test that an email has been sent during acceptance testing. Accepts an options hash supporting the following options:
#
# - :path - if passed, tests that the mail contains a link to this path. Ideally we'd like to test using full URLs
# but this not possible because during testing links inside emails generated by ActionMailer use the hostname
# "www.example.com" instead of the actual "localhost:3000" returned by Rails URL helpers.
# - :to - if passed, tests that this is the value of the email's "to" header.
#
# Return value is the href of the link if "path" option is passed, nil otherwise.

def mail_should_be_sent(options={})
  default_options = {path: nil, to: nil}
  options = default_options.merge options

  email = ActionMailer::Base.deliveries.pop
  email.present?.should be_true

  if options[:path].present?
    emailBody = Nokogiri::HTML email.body.to_s
    link = emailBody.at_css "a[href*=\"#{options[:path]}\"]"
    link.present?.should be_true
    href = link[:href]
  end

  if options[:to].present?
    email.to.first.should eq options[:to]
  end

  return href
end

##
# Test that no email has been sent during acceptance testing

def mail_should_not_be_sent
  email = ActionMailer::Base.deliveries.pop
  email.present?.should be_false
end

##
# Open a folder in the sidebar. Receives the folder id as argument, accepts "all" to open
# the All Subscriptions folder.

def open_folder(folder_id)
  page.should have_css "#folders-list li#folder-#{folder_id}"
  # Open folder only if it is closed
  if !page.has_css? "#folders-list ul#feeds-#{folder_id}.in"
    find("a[data-target='#feeds-#{folder_id}']").click
  end
end

##
# Click on a feed to read its entries during acceptance testing. Receives as arguments:
#
# - feed_id: mandatory argument, with the id of the id of the feed to read.
# - folder_id: optional argument, with the id of the folder under which the feed will be clicked.
#
# The folder_id argument accepts the value "all"; this means the feed will be clicked under the All Subscriptions
# folder.
#
# If the folder_id argument is not present, it defaults to "all".
#
# If the feed is not under the folder passed as argument, the test will immediately fail.

def read_feed(feed_id, folder_id = 'all')
  open_folder folder_id
  within "#folders-list li#folder-#{folder_id}" do
    page.should have_css "[data-sidebar-feed][data-feed-id='#{feed_id}']"

    # Click on feed to read its entries
    find("[data-sidebar-feed][data-feed-id='#{feed_id}']").click
  end
end

##
# Click on the "read all subscriptions" link under a folder to read its entries during acceptance testing.
# Receives as argument:
#
# - folder_id: mandatory argument, with the id of the id of the feed to read. It accepts the special value "all",
# which means clicking on "read all subscriptions" under the All Subscriptions folder.
#
# If the folder does not exist, the test will immediately fail.

def read_folder(folder_id)
  open_folder folder_id
  within "#folders-list li#folder-#{folder_id}" do
    find("[data-sidebar-feed][data-feed-id='all']").click
  end
end