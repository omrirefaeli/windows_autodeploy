Set-ExecutionPolicy Bypass -Scope Process -Force

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
