angular.module 'mnoEnterpriseAngular'

#======================================================================================
# IMPAC-ROUTES: Configuring routes
#======================================================================================
.config((ImpacRoutesProvider, IMPAC_CONFIG) ->
  mnoHub = IMPAC_CONFIG.paths.mnohub_api

  data =
    mnoHub: mnoHub
    impacApi: "#{IMPAC_CONFIG.protocol}://#{IMPAC_CONFIG.host}/api"
    kpis:
      index: "#{mnoHub}/impac/kpis"

  ImpacRoutesProvider.configureRoutes(data)
)

#======================================================================================
# IMPAC-THEMING: Configuring colour theme, layout, labels, descriptions, and features
#======================================================================================
.config((ImpacThemingProvider) ->
  options =
    # link to the marketplace
    dataNotFoundConfig:
      linkUrl: '#!/marketplace'
      linkTarget: '_self'
    # remove useless messages
    dhbErrorsConfig:
      firstTimeCreated:
        note: ''
    # configurations for the dashboard selector feature.
    dhbSelectorConfig:
      pdfModeEnabled: true
    # kpis options
    dhbKpisConfig:
      enableKpis: false
    # alert notifications options
    alertsConfig:
      enableAlerts: false

  ImpacThemingProvider.configure(options)
)

#======================================================================================
# IMPAC-ASSETS: Configuring assets
#======================================================================================
.config((ImpacAssetsProvider) ->
  options =
    defaultImagesPath: '/dashboard/images'
    dataNotFound: '/dashboard/images/data_not_found'

  ImpacAssetsProvider.configure(options)
)

#======================================================================================
# IMPAC-LINKING: Configuring linking
#======================================================================================
.run((ImpacLinking, ImpacConfigSvc, IMPAC_CONFIG) ->
  # Example: override ACL for each organization
  # overrideAcl = (orgs) ->
  #   _.map(orgs, (org) ->
  #     angular.merge(org, {
  #       acl:
  #         related:
  #           impac: { show: true }
  #           dashboards: { update: true }
  #           widgets: { update: true }
  #           kpis: { show: true }
  #     })
  #   )
  # ImpacConfigSvc.configure(overrideAcl)
  
  data =
    user: ImpacConfigSvc.getUserData
    organizations: ImpacConfigSvc.getOrganizations

  data.pusher_key = IMPAC_CONFIG.pusher.key if IMPAC_CONFIG.pusher? && IMPAC_CONFIG.pusher.key?

  ImpacLinking.linkData(data)
)
