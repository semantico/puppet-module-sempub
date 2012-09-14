
define mkdir ($path = "", 
              $mode = 2755, 
              $owner = "root", 
              $group = "root", 
              $ensure = "directory"
              ) {

    case $path {
        "": { $our_path = $title }
        default: { $our_path = $path }
    }
    
    case $ensure {
        "directory", "present": {
            file { "$our_path":
                ensure => directory,
                mode => $mode,
                owner => $owner,
                group => $group,
            }
        }
        "absent": {
            file { "$our_path":
                ensure => $ensure,
            }
        }
    }
}

