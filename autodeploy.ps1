Set-ExecutionPolicy Bypass -Scope Process -Force
#################################### Chocolately ##############################################
Write-Host -ForegroundColor black -BackgroundColor Cyan "installing chocolately & packages"
[System.Net.ServicePointManager]::SecurityProtocol = [System.Net.ServicePointManager]::SecurityProtocol -bor 3072; iex ((New-Object System.Net.WebClient).DownloadString('https://community.chocolatey.org/install.ps1'))

$install_array = @("googlechrome", "7zip.install", "git", "notepadplusplus", "everything", "adobereader")

$personal_additions = @("evernote")
Write-Host -ForegroundColor black -BackgroundColor Cyan "Would you like to include the personal software additions? The packages are:`n$($personal_additions)"
do
{
$personal_bool = Read-Host "Please enter [y/n]"
}
while ($personal_bool -notin @("y","n"))

if ($personal_bool -eq "y") {$install_array += $personal_additions} 

$install_string = $install_array -join " "
Write-Host -ForegroundColor black -BackgroundColor Cyan "Installing the packages: `n$($install_string)"

$install_array | %{
choco install $_ -y
}

#################################### RC Revert ##############################################
Write-Host -ForegroundColor black -BackgroundColor Cyan "Reverting the new Right Click menu to the old Windows 10 one"

try {
    $key = get-itemproperty "HKCU:\SOFTWARE\CLASSES\CLSID\{86ca1aa0-34aa-4e8b-a509-50c905bae2a2}\InprocServer32\"
    if ($($key.psobject.properties | select -ExpandProperty Name ) -contains "(default)") {
        Write-Host -ForegroundColor Green "Revert Right Click registry key already exists"
    }
    else {
        throw [System.Management.Automation.ItemNotFoundException]
    }
  
}
catch {
    new-item -path "HKCU:\SOFTWARE\CLASSES\CLSID" -name "{86ca1aa0-34aa-4e8b-a509-50c905bae2a2}" -Force
    new-item -path "HKCU:\SOFTWARE\CLASSES\CLSID\{86ca1aa0-34aa-4e8b-a509-50c905bae2a2}" -name "InprocServer32" -Force
    New-ItemProperty  -path "HKCU:\SOFTWARE\CLASSES\CLSID\{86ca1aa0-34aa-4e8b-a509-50c905bae2a2}\InprocServer32" -Name "(Default)" -Value ""
    $key = get-itemproperty "HKCU:\SOFTWARE\CLASSES\CLSID\{86ca1aa0-34aa-4e8b-a509-50c905bae2a2}\InprocServer32\"
    if ($($key.psobject.properties | select -ExpandProperty Name ) -contains "(default)") {
        Write-Host -ForegroundColor Green "Revert Right Click registry change successfully implemented"
    }
    else {
        Write-Host -ForegroundColor Red -BackgroundColor Black "Revert Right Click registry change did not implement successfully"
    }
}


#################################### Elevated Terminal Shortcut ##############################################
CreateShortcut -name "Terminal Admin" -Target "C:\Program Files\WindowsApps\Microsoft.WindowsTerminal_1.15.2875.0_x64__8wekyb3d8bbwe\wt.exe" -OutputDirectory "C:\Users\omrirefaeli\Desktop" -Elevated True -HotKey "CTRL+ALT+T"

#################################### Enable WSL ##############################################
Enable-WindowsOptionalFeature -Online -FeatureName Microsoft-Windows-Subsystem-Linux 

#################################### Help Functions ##############################################

# https://blog.ctglobalservices.com/powershell/hra/create-shortcut-with-elevated-rights/ 
Function CreateShortcut
{
    [CmdletBinding()]
    param (    
        [parameter(Mandatory=$true)]
        [ValidateScript( {[IO.File]::Exists($_)} )]
        [System.IO.FileInfo] $Target,
    
        [ValidateScript( {[IO.Directory]::Exists($_)} )]
        [System.IO.DirectoryInfo] $OutputDirectory,
    
        [string] $Name,
        [string] $Description,
    
        [string] $Arguments,
        [System.IO.DirectoryInfo] $WorkingDirectory,
    
        [string] $HotKey,
        [int] $WindowStyle = 1,
        [string] $IconLocation,
        [switch] $Elevated
    )

    try {
        #region Create Shortcut
        if ($Name) {
            [System.IO.FileInfo] $LinkFileName = [System.IO.Path]::ChangeExtension($Name, "lnk")
        } else {
            [System.IO.FileInfo] $LinkFileName = [System.IO.Path]::ChangeExtension($Target.Name, "lnk")
        }
    
        if ($OutputDirectory) {
            [System.IO.FileInfo] $LinkFile = [IO.Path]::Combine($OutputDirectory, $LinkFileName)
        } else {
            [System.IO.FileInfo] $LinkFile = [IO.Path]::Combine($Target.Directory, $LinkFileName)
        }

       
        $wshshell = New-Object -ComObject WScript.Shell
        $shortCut = $wshShell.CreateShortCut($LinkFile) 
        $shortCut.TargetPath = $Target
        $shortCut.WindowStyle = $WindowStyle
        $shortCut.Description = $Description
        $shortCut.WorkingDirectory = $WorkingDirectory
        $shortCut.HotKey = $HotKey
        $shortCut.Arguments = $Arguments
        if ($IconLocation) {
            $shortCut.IconLocation = $IconLocation
        }
        $shortCut.Save()
        #endregion

        #region Elevation Flag
        if ($Elevated) {
            $tempFileName = [IO.Path]::GetRandomFileName()
            $tempFile = [IO.FileInfo][IO.Path]::Combine($LinkFile.Directory, $tempFileName)
        
            $writer = new-object System.IO.FileStream $tempFile, ([System.IO.FileMode]::Create)
            $reader = $LinkFile.OpenRead()
        
            while ($reader.Position -lt $reader.Length)
            {        
                $byte = $reader.ReadByte()
                if ($reader.Position -eq 22) {
                    $byte = 34
                }
                $writer.WriteByte($byte)
            }
        
            $reader.Close()
            $writer.Close()
        
            $LinkFile.Delete()
        
            Rename-Item -Path $tempFile -NewName $LinkFile.Name
        }
        #endregion
    } catch {
        Write-Error "Failed to create shortcut. The error was '$_'."
        return $null
    }
    return $LinkFile
}