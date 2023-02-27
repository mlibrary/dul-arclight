module DulArclight
  # The value used to authenticate the webhook
  # (not a repo deploy token)
  mattr_accessor :gitlab_token do
    ENV['GITLAB_TOKEN']
  end

  mattr_accessor :finding_aid_data do
    ENV.fetch('FINDING_AID_DATA') # Set in Dockerfile
  end

  mattr_accessor :google_analytics_tracking_id do
    ENV['GOOGLE_ANALYTICS_TRACKING_ID']
  end

  mattr_accessor :google_analytics_debug do
    ENV['GOOGLE_ANALYTICS_DEBUG']
  end

  mattr_accessor :matomo_analytics_debug do
    ENV['MATOMO_ANALYTICS_DEBUG']
  end

  mattr_accessor :matomo_analytics_host do
    ENV['MATOMO_ANALYTICS_HOST']
  end

  mattr_accessor :matomo_analytics_site_id do
    ENV['MATOMO_ANALYTICS_SITE_ID']
  end
end
