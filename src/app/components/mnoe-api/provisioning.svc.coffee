# Service for managing the users.
angular.module 'mnoEnterpriseAngular'
  .service 'MnoeProvisioning', ($q, $log, MnoeApiSvc, MnoeOrganizations, MnoErrorsHandler) ->
    _self = @

    subscriptionsApi = (id) -> MnoeApiSvc.one('/organizations', id).all('subscriptions')

    subscription = {}

    defaultSubscription = {
      id: null
      product: null
      product_pricing: null
      custom_data: {}
    }

    @setSubscription = (s) ->
      subscription = s

    @getCachedSubscription = () ->
      subscription

    # Return the subscription
    # if productNid: return the default subscription
    # if subscriptionId: return the fetched subscription
    # else: return the subscription in cache (edition mode)
    @initSubscription = ({productId = null, subscriptionId = null}) ->
      deferred = $q.defer()
      # Edit a subscription
      if !_.isEmpty(subscription)
        deferred.resolve(subscription)
      else if subscriptionId?
        _self.fetchSubscription(subscriptionId).then(
          (response) ->
            angular.copy(response, subscription)
            deferred.resolve(subscription)
        )
      else if productId?
        # Create a new subscription to a product
        angular.copy(defaultSubscription, subscription)
        deferred.resolve(subscription)
      else
        deferred.resolve({})

      return deferred.promise

    @createSubscription = (s) ->
      deferred = $q.defer()
      subscription_params = {product_id: s.product.id, product_pricing_id: s.product_pricing?.id, max_licenses: s.max_licenses, custom_data: s.custom_data}
      MnoeOrganizations.get().then(
        (response) ->
          subscriptionsApi(response.organization.id).post({subscription: subscription_params}).then(
            (response) ->
              deferred.resolve(response)
          )
      )
      return deferred.promise

    @updateSubscription = (s) ->
      deferred = $q.defer()
      MnoeOrganizations.get().then(
        (response) ->
          subscription.patch({subscription: {product_id: s.product.id, product_pricing_id: s.product_pricing?.id,
          max_licenses: s.max_licenses, custom_data: s.custom_data, edit_action: s.edit_action}}).then(
            (response) ->
              deferred.resolve(response)
          )
      )
      return deferred.promise

    # Detect if the subscription should be a POST or A PUT and call corresponding method
    @saveSubscription = (subscription) ->
      unless subscription.id
        _self.createSubscription(subscription)
      else
        _self.updateSubscription(subscription)

    @fetchSubscription = (id) ->
      deferred = $q.defer()
      MnoeOrganizations.get().then(
        (response) ->
          MnoeApiSvc.one('/organizations', response.organization.id).one('subscriptions', id).get().then(
            (response) ->
              deferred.resolve(response)
          )
      )
      return deferred.promise

    @getSubscriptions = () ->
      deferred = $q.defer()
      MnoeOrganizations.get().then(
        (response) ->
          subscriptionsApi(response.organization.id).getList().then(
            (response) ->
              deferred.resolve(response)
          )
      )
      return deferred.promise

    @getProductSubscriptions = (productId) ->
      deferred = $q.defer()
      MnoeOrganizations.get().then(
        (response) ->
          params = { where: { product_id: productId } }
          subscriptionsApi(response.organization.id).getList(params).then(
            (response) ->
              deferred.resolve(response)
          )
      )
      return deferred.promise

    @cancelSubscription = (s) ->
      MnoeOrganizations.get().then(
        (response) ->
          MnoeApiSvc.one('organizations', response.organization.id).one('subscriptions', s.id).post('/cancel').catch(
            (error) ->
              MnoErrorsHandler.processServerError(error)
              $q.reject(error)
          )
      )

    @getSubscriptionEvents = (subscriptionId) ->
      deferred = $q.defer()
      MnoeOrganizations.get().then(
        (response) ->
          MnoeApiSvc.one('organizations', response.organization.id).one('subscriptions', subscriptionId). customGET('/subscription_events').then(
            (response) ->
              deferred.resolve(response)
          )
      )
      return deferred.promise

    return
