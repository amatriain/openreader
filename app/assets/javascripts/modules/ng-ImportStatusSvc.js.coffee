########################################################
# AngularJS service to load data import status data in the scope.
#
# Note.- The first time this is invoked on page load by the angular controller, passing
# a false to the "show_alerts" argument of load_data. This means that if the import is not running
# (error, success or none, doesn't matter), no alert will be shown.
#
# However if the import is found to be running, the function will be called every 5 seconds, with
# a true to the "show_alerts" argument.
#
# Basically this means that if when the page is loaded the import is running, and it finishes
# afterwards, then and only then will an alert be displayed.
########################################################

angular.module('feedbunch').service 'importStatusSvc',
['$rootScope', '$http', '$timeout', 'feedsFoldersSvc',
($rootScope, $http, $timeout, feedsFoldersSvc)->

  load_import_status = ($scope, show_alerts)->
    $http.get('/data_imports.json')
    .success (data)->
      $scope.import_status = data["status"]
      if data["status"] == "RUNNING"
        # Update status from the server periodically while import is running
        $scope.import_processed = data["import"]["processed"]
        $scope.import_total = data["import"]["total"]
        $timeout ->
          load_import_status $scope, true
        , 5000
      else if data["status"] == "ERROR" && show_alerts
        # Show an alert when the process finishes with an error
        $rootScope.error_importing = true
        # Close alert after 5 seconds
        $timeout ->
          $rootScope.error_importing = false
        , 5000
      else if data["status"] == "SUCCESS" && show_alerts
        # Automatically load new feeds and folders without needing a refresh
        feedsFoldersSvc.load_data $scope
        # Show an alert when the process finishes successfully
        $rootScope.success_importing = true
        # Close alert after 5 seconds
        $timeout ->
          $rootScope.success_importing = false
        , 5000
    .error ->
      # Show alert
      $rootScope.error_loading_import_status = true
      # Close alert after 5 seconds
      $timeout ->
        $rootScope.error_loading_import_status = false
    , 5000

  return load_data: load_import_status
]