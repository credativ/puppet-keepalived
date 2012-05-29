# Define defaults for the keepalived module
class keepalived::params {
    # Module options
    $ensure             = present
    $manage_config      = true
    $config_template    = 'keepalived/keepalived.conf.erb'
    $config_source      = undef
}
