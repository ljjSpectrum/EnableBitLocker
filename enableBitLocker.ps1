# Get the drive letter you want to encrypt
$driveLetter = "C:"

# Check if BitLocker is already enabled on the drive
$bitlockerStatus = Get-BitLockerVolume -MountPoint $driveLetter | Select-Object -ExpandProperty EncryptionPercentage -ErrorAction SilentlyContinue

if ($bitlockerStatus -eq $null) {
    # BitLocker is not enabled, so enable it
    Enable-BitLocker -MountPoint $driveLetter -EncryptionMethod XtsAes256
    
    # Add BitLocker recovery key protector to store in Active Directory
    $recoveryKeyProtector = Add-BitLockerKeyProtector -MountPoint $driveLetter -RecoveryPasswordProtector
    
    # Backup key to AD
    BackupToAAD-BitLockerKeyProtector -MountPoint "C:" -KeyProtectorId $recoveryKeyProtector.KeyProtector[1].KeyProtectorId

   
    # Display the recovery key
    $recoveryKey = $recoveryKeyProtector.RecoveryPassword
    Write-Host "BitLocker has been enabled on drive $($driveLetter)."
    Write-Host "Recovery Key: $recoveryKey"
      
} else {
    Write-Host "BitLocker is already enabled on drive $($driveLetter)."
    Write-Host "Backing up BitLocker Key on drive $($driveLetter)."
    $BLV = Get-BitLockerVolume -MountPoint "C:"
    BackupToAAD-BitLockerKeyProtector -MountPoint "C:" -KeyProtectorId $BLV.KeyProtector[1].KeyProtectorId
   
}
