<# 
.SYNOPSIS
    Gets a list of all users who have logged on since the date specified
#>


import-module activedirectory

get-aduser -filter {lastlogondate -gt "7/18/2015"} -Properties lastlogondate | select Name,LastLogonDate | sort name