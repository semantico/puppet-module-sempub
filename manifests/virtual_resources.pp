class sempub::virtual_resources {

    @file { "/var/lib/puppet/state/modules/sempub":
        ensure => directory,
        owner => root,
        group => root,
        mode => 1777,
    }

}
