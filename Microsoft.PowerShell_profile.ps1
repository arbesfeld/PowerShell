# General variables
$pathToPortableGit = "C:\shared_tools\tools\PortableGit"
$scripts = "D:\shared_tools\scripts"

# Add Git executables to the mix.
[System.Environment]::SetEnvironmentVariable("PATH", $Env:Path + ";" + (Join-Path $pathToPortableGit "\bin") + ";" + $scripts, "Process")

# Setup Home so that Git doesn't freak out.
[System.Environment]::SetEnvironmentVariable("HOME", (Join-Path $Env:HomeDrive $Env:HomePath), "Process")

$Global:CurrentUser = [System.Security.Principal.WindowsIdentity]::GetCurrent()
$UserType = "User"
$CurrentUser.Groups | foreach { 
    if ($_.value -eq "S-1-5-32-544") {
        $UserType = "Admin" } 
    }

function prompt {
     # Fun stuff if using the standard PowerShell prompt; not useful for Console2.
     # This, and the variables above, could be commented out.
     if($UserType -eq "Admin") {
       $host.UI.RawUI.WindowTitle = "" + $(get-location) + " : Admin"
       $host.UI.RawUI.ForegroundColor = "white"
      }
     else {
       $host.ui.rawui.WindowTitle = $(get-location)
     }

    Write-Host("")
    $status_string = ""
    $symbolicref = git symbolic-ref HEAD
    if($symbolicref -ne $NULL) {
        $status_string += "[" + $symbolicref.substring($symbolicref.LastIndexOf("/") +1) + "] "

        $differences = (git diff-index --name-status HEAD)
        $git_update_count = [regex]::matches($differences, "M`t").count
        $git_create_count = [regex]::matches($differences, "A`t").count
        $git_delete_count = [regex]::matches($differences, "D`t").count

        $status_string += "c:" + $git_create_count + " u:" + $git_update_count + " d:" + $git_delete_count + " "
    }
    else {
        $status_string = "PS "
    }

    if ($status_string.StartsWith("GIT")) {
        Write-Host ($status_string + $(get-location) + ">") -nonewline -foregroundcolor yellow
    }
    else {
        Write-Host ($status_string + $(get-location) + ">") -nonewline -foregroundcolor green
    }
    return " "
 }  
function subl ($loc) {
$path = Get-Location
runas /savecred /user:THINK\Matthew "C:\Program Files\Sublime Text 2\sublime_text.exe $path\$loc\"
}
function rspec ($loc) {
bundle exec rspec $loc
}
function rake ($param) {
bundle exec rake $param
}