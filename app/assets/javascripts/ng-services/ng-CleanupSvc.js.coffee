########################################################
# AngularJS service to remove feeds, folders, and hide read feeds in the view
########################################################

angular.module('feedbunch').service 'cleanupSvc',
['$rootScope', '$filter', 'findSvc',
($rootScope, $filter, findSvc)->

  #--------------------------------------------
  # PRIVATE FUNCTION: Update the model to account for a feed having been removed from a folder
  #--------------------------------------------
  feed_removed_from_folder = (folder_id)->
    folder = findSvc.find_folder folder_id
    if folder
      # Remove folder if it's empty
      feeds = findSvc.find_folder_feeds folder
      if !feeds || feeds?.length == 0
        index = $rootScope.folders.indexOf folder
        $rootScope.folders.splice index, 1 if index != -1

  service =

    #---------------------------------------------
    # Remove a feed from the feeds array.
    #---------------------------------------------
    remove_feed: (feed_id)->
      if $rootScope.feeds
        feed = findSvc.find_feed feed_id
        folder_id = feed.folder_id
        # Delete feed model from the scope
        index = $rootScope.feeds.indexOf feed
        if index != -1
          $rootScope.feeds.splice index, 1
          # Update folders
          feed_removed_from_folder folder_id

    #--------------------------------------------
    # Remove feeds without unread entries from the root scope, unless the user has
    # selected to display all feeds including read ones.
    # If the user clicks on the same feed or on its folder, do nothing.
    #--------------------------------------------
    hide_read_feeds: ->
      if $rootScope.feeds && !$rootScope.show_read
        read_feeds = $filter('filter') $rootScope.feeds, (feed)->
          return feed.unread_entries <= 0
        if read_feeds && read_feeds?.length > 0
          for feed in read_feeds
            if $rootScope.current_feed?.id != feed.id && $rootScope.current_folder?.id != feed.folder_id
              # Delete feed from the scope
              index = $rootScope.feeds.indexOf feed
              $rootScope.feeds.splice index, 1 if index != -1

  return service
]