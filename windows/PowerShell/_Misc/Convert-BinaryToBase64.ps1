﻿Function Convert-BinaryToBase64 {

param (
[Parameter(Mandatory=$true)][string]$FilePath
   )
 
try 
    {
    $ByteArray = [System.IO.File]::ReadAllBytes($FilePath)
    }
catch 
    {
    throw "Failed to read file. Ensure that you have permission to the file, and that the file path is correct."
    }
if ($ByteArray) 
    {
    $Base64String = [System.Convert]::ToBase64String($ByteArray)
    }
else 
    {
    throw '$ByteArray is $null.'
    }
 
$Base64String
 
}