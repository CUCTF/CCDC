﻿<# 
.SYNOPSIS
    Recursively gets file listing and metadata
#>

gci c:\ -force | select Name, Fullname, Extension, Mode, Length, CreationTime, LastAccessTime, LastWriteTime, Attributes, IsReadOnly | export-csv dir_list.csv