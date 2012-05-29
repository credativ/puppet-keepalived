# Define defaults for the keepalived module
class keepalived::params {
    # Module options
    $ensure             = present
    $ensure_running     = true
    $ensure_enabled     = true
    $manage_config      = true
    $config_template    = 'keepalived/keepalived.conf.erb'
    $config_source      = undef
    $ensure_running     = true
}
