# Get the drive letter you want to encrypt
$driveLetter = "C:"
$password = ConvertTo-SecureString "S11@jd%1500" -AsPlainText -Force
$Cred = New-Object System.Management.Automation.PSCredential ("jdoe@spectrumfurniture.com", $password)
$HN = Hostname

# Check if BitLocker is already enabled on the drive
$bitlockerStatus = Get-BitLockerVolume -MountPoint $driveLetter | Select-Object -ExpandProperty EncryptionPercentage -ErrorAction SilentlyContinue

if ($bitlockerStatus -eq $null) {
    # BitLocker is not enabled, so enable it
    Enable-BitLocker -MountPoint $driveLetter -EncryptionMethod XtsAes256
    
    # Add BitLocker recovery key protector to store in Active Directory
    $recoveryKeyProtector = Add-BitLockerKeyProtector -MountPoint $driveLetter -RecoveryPasswordProtector
    
    # Backup key to AD
    Backup-BitLockerKeyProtector -MountPoint "C:" -KeyProtectorId $recoveryKeyProtector.KeyProtector[1].KeyProtectorId
   
   # Invoke-Command -ScriptBlock {
   #          BackupToAAD-BitLockerKeyProtector -MountPoint "C:" -KeyProtectorId $recoveryKeyProtector.KeyProtector[1].KeyProtectorId
   #     } -cn $HN -Credential $Cred
         
} else {
    
    Write-Host "Backing up BitLocker Key on drive $($driveLetter)."
   # $BLV = Get-BitLockerVolume -MountPoint "C:"
   # Invoke-Command -ScriptBlock {
   #         BackupToAAD-BitLockerKeyProtector -MountPoint "C:" -KeyProtectorId $BLV.KeyProtector[1].KeyProtectorId
   #     } -Credential $Cred -cn $HN
    
    # Add BitLocker recovery key protector to store in Active Directory
    $recoveryKeyProtector = Add-BitLockerKeyProtector -MountPoint $driveLetter -RecoveryPasswordProtector
    Backup-BitLockerKeyProtector -MountPoint "C:" -KeyProtectorId $recoveryKeyProtector.KeyProtector[1].KeyProtectorId
   
}
