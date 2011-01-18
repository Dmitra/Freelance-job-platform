APP_CONF = YAML::load(File.open("#{RAILS_ROOT}/config/site.yml"))
def property(key)
  APP_CONF[RAILS_ENV][key.to_s]
end

# Email settings
ActionMailer::Base.delivery_method = :smtp
ActionMailer::Base.smtp_settings = {
  #...
}

# SITE settings
SITE_NAME = 'Site name'
SITE_URL = 'order.cubicstudio.com.ua'
