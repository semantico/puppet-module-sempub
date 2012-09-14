
# get a file from our fileserver via puppet:// URL
define remotefile($source, $path = "", $owner = root, $group = root, $mode = 0644, $recurse = false , $ensure = "present") {

    case $path {
        "": { $our_path = $title }
        default: { $our_path = $path }
    }

    file { "$our_path":
        source => "puppet://$fileserver/$source",
        owner => $owner,
        group => $group,
        mode  => $mode,
        recurse => $recurse,
        ensure => $ensure
    }
}

