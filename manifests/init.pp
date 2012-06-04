# = Class: keepalived
#
# Module to manage keepalived
#
# == Requirements:
#
# - This module makes use of the example42 functions in the puppi module
#   (https://github.com/credativ/puppet-example42lib)
#
# == Parameters:
#
# [* ensure *]
#   What state to ensure for the package. Accepts the same values
#   as the parameter of the same name for a package type.
#   Default: present
#   
# [* ensure_running *]
#   Weither to ensure running keepalived or not.
#   Default: running
#
# [* ensure_enabled *]
#   Weither to ensure that keepalived is started on boot or not.
#   Default: true
#
# [* config_source *]
#   Specify a configuration source for the configuration. If this
#   is specified it is used instead of a template-generated configuration
#
# [* config_template *]
#   Override the default choice for the configuration template
#
# == Author:
#
#   Patrick Schoenfeld <patrick.schoenfeld@credativ.de>

class keepalived (
    $ensure             = params_lookup('ensure'),
    $manage_config      = params_lookup('manage_config'),
    $ensure_running     = params_lookup('ensure_running'),
    $ensure_enabled     = params_lookup('ensure_enabled'),
    $config_source      = params_lookup('config_source'),
    $config_template    = params_lookup('config_template'),
    $disabled_hosts     = params_lookup('disabled_hosts'),
    $smtp_server        = params_lookup('smtp_server'),
    $notification_mail  = params_lookup('notification_email'),
    $master             = params_lookup('master'),
    $vrrp_instances     = params_lookup('vrrp_instances'),
    ) inherits keepalived::params {

    package { 'keepalived':
        ensure => $ensure
    }

    service { 'keepalived':
        ensure      => $ensure_running,
        enabled     => $ensure_enabled,
        hasrestart  => true,
        hasstatus   => true,
        require     => Package['keepalived']
    }

    # Disable service on this host, if hostname is in disabled_hosts
    if $hostname in $disabled_hosts {
        Service <| title == 'keepalived' |> {
            ensure  => 'stopped',
            enabled => false,
        }
    }

    file { '/etc/keepalived/keepalived.conf':
        ensure  => present,
        mode    => '0644',
        owner   => 'root',
        group   => 'root',
        tag     => 'keepalived_config',
        require => Package['keepalived'],
        notify  => Service['keepalived']
    }

    if $config_source {
        File <| tag == 'keepalived_config' |> {
            source  => $config_source
        }
    } else {
        if $master == $::hostname {
            $state = 'MASTER'
        } else {
            $state = 'BACKUP'
        }

        if $vrrp_instances {
            File <| tag == 'keepalived_config' |> {
                content => template($config_template)
            }
        } else {
            fail("No vrrp_instances defined in backend")
        }
    }

    
}
