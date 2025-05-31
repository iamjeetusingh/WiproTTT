cls

# calling the CSV file within PS script
$csvPath = "E:\Wipro\TTT-Batch\users.csv"

# importing the file
$users = Import-Csv -Path $csvPath

# new password
$NewPassword = "NewP@s#w0rd2025"

# encrypted method
# $NewPassword = Read-Host -AsSecureString | ConvertFrom-SecureString

foreach ($user in $users) {
    $userName = $user.UserName
    
    aws iam update-login-profile `
        --user-name $userName `
        --password $NewPassword `
        --password-reset-required

    Write-Host "Password changed successfully for $userName..."

 
}