add-content -path "$env:USERPROFILE/.ssh/config" -value @'

Host ${hostname}
    Hostname ${hostname}
    User ${user}
    IdentityFile ${identityfile}
'@