
# Show the differences between two files, since puppet does not 
# support this yet. See sudoers module for how to use
define show_diff ($src, $dest, $logoutput = "true", $returns = 1) {
    exec { "diff -u $dest $src":
        tag => "show_diff",
        path => "/usr/bin:/bin",
        # if a cmp is fine, we don't need to run diff - the files are 
        # the same. This gets allows us to expect diff to have a return
        # code of 1.
        unless => "cmp $dest $src",
        logoutput => $logoutput,
        # diff should return 1, as we should always be different
        #  - would be nice if we could specify an array to 'returns'
        #    as this would negate the need for the cmp
        returns => $returns,
    }
}
