class roundcube::params {
  # Installation
  $apt_mirror                 = 'http://ftp.debian.org/debian'
  $roundcube_backend          = 'pgsql'
  $install_extra_plugins      = true

  # Configuration
  $dbconfig_file              = '/etc/dbconfig-common/roundcube.conf'
  $confdir                    = '/etc/roundcube'
  $main_inc_php_erb           = 'roundcube/main.inc.php.erb'

  # Database
  $database_host              = 'localhost'
  $database_port              = undef
  $database_name              = 'roundcubedb'
  $database_username          = 'roundcubedb'
  $database_password          = 'roundcubedb'
  $database_ssl               = false

  # WebServer - Apache
  $install_apache             = false
  $default_vhost_on           = true
  $default_mods               = false
  $default_confd_files        = false
  $purge_configs              = true
  $mpm_module                 = 'prefork'
  $install_apache_mods        = false

  $ssl                        = false
  $redirect_to_ssl            = false

  $port                       = undef
  $non_ssl_port               = undef

  $servername                 = $::fqdn
  $serveraliases              = []

  $documentroot               = '/var/lib/roundcube'

  $ssl_ca                     = undef
  $ssl_cert                   = undef
  $ssl_key                    = undef

  # Database - PostgreSQL
  $install_postgresql         = false
  $ip_mask_allow_all_users    = '0.0.0.0/0'
  $listen_addresses           = $::fqdn

  # Legacy
  # TODO - Remove after testing
  #  $roundcube_webserver        = 'apache'
  #  $force_https                = false
  #  $addhandlers                = []
  #  $rewrites                   = undef
  #  $suphp_user                 = 'roundcube'
  #  $suphp_group                = 'roundcube'
}
