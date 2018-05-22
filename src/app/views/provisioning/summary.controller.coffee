angular.module 'mnoEnterpriseAngular'
  .controller('ProvisioningSummaryCtrl', ($scope, $state, $stateParams, MnoeOrganizations, MnoeProvisioning, MnoeConfig) ->

    vm = this
    vm.isLoading = true
    vm.selectedCurrency = MnoeProvisioning.getSelectedCurrency()
    MnoeProvisioning.initSubscription({subscriptionId: $stateParams.subscriptionId})
      .then((response) -> vm.subscription = response)
      .finally(() -> vm.isLoading = false)

    MnoeOrganizations.get().then(
      (response) ->
        vm.orgCurrency = response.organization?.billing_currency || MnoeConfig.marketplaceCurrency()
    )

    # Delete the cached subscription.
    $scope.$on('$stateChangeStart', (event, toState) ->
      MnoeProvisioning.setSubscription({})
    )

    return
  )
