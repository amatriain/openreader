########################################################
# AngularJS service to enable keyboard shortcuts.
########################################################

angular.module('feedbunch').service 'keyboardShortcutsSvc',
['$rootScope', 'highlightedEntrySvc', 'entrySvc',
($rootScope, highlightedEntrySvc, entrySvc)->

  #---------------------------------------------
  # Start responding to keyboard shortcuts
  #---------------------------------------------
  start: ->
    # TODO - do not enable keyboard shortcuts while a text field is visible! (e.g. when creating a new folder,
    # renaming a feed, subscribing to a new feed etc). Otherwise e.g. we cannot enter a folder name with "j" or "k" chars

    $(document).keypress (event)->
      # spacebar=32, j=106, k=107
      if event.which in [32, 106, 107]
        if $rootScope.entries
          highlightedEntrySvc.next() if event.which == 106
          highlightedEntrySvc.previous() if event.which == 107
          entrySvc.toggle_open_entry highlightedEntrySvc.get() if event.which == 32
        event.preventDefault()
]