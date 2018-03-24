Write-Host "Starting Script."

if(Test-Path -Path "ult.bin") {
    remove-item "ult.bin" -Force
}
if(Test-Path -Path "ultimem.img") {
    remove-item "ultimem.img" -Force
}

New-Item -ItemType file "ult.bin"
Get-Content "_a000.bin" -Raw | Add-Content "ult.bin" -NoNewline
Get-Content "_ultimem.bin" -Raw | Add-Content "ult.bin" -NoNewline
Get-Content "_hive.bin" -Raw | Add-Content "ult.bin" -NoNewline

$ps = new-object System.Diagnostics.Process
$ps.StartInfo.Filename = "bash.exe"
$ps.StartInfo.Arguments = "--verbose -c ""tools/makecart ult.bin ultimem.img 8388608 < files.txt "" "
$ps.StartInfo.UseShellExecute = $true
$ps.StartInfo.RedirectStandardOutput = $false
$ps.StartInfo.CreateNoWindow = $true
$ps.Start()
$ps.WaitForExit()

Write-Host "Script Finished."