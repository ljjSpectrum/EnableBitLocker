# Get the drive letter you want to encrypt
$driveLetter = "C:"

# Check if BitLocker is already enabled on the drive
$bitlockerStatus = Get-BitLockerVolume -MountPoint $driveLetter | Select-Object -ExpandProperty EncryptionPercentage -ErrorAction SilentlyContinue

if ($bitlockerStatus -eq $null) {
    # BitLocker is not enabled, so enable it
    Enable-BitLocker -MountPoint $driveLetter -EncryptionMethod XtsAes256

    # Add BitLocker recovery key protector to store in Active Directory
    $recoveryKeyProtector = Add-BitLockerKeyProtector -MountPoint $driveLetter -RecoveryPasswordProtector

    # Display the recovery key
    $recoveryKey = $recoveryKeyProtector.RecoveryPassword
    Write-Host "BitLocker has been enabled on drive $($driveLetter)."
    Write-Host "Recovery Key: $recoveryKey"

    # You may want to backup the recovery key to a secure location in addition to Active Directory
    # Backup-BitLockerKeyProtector -MountPoint $driveLetter -KeyProtectorId $recoveryKeyProtector.KeyProtectorId
    # Replace the above line with the appropriate command for your backup strategy
} else {
    Write-Host "BitLocker is already enabled on drive $($driveLetter)."
}
