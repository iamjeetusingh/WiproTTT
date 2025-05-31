# Fetching usernames
$csvPath = "E:\Wipro\TTT-Batch\users.csv"
$group = "WiproTTT"

# List of IAM users to delete
$UserList = (Import-Csv -Path $csvPath).username

foreach ($User in $UserList) {
    Write-Host "`nDeleting IAM user: $User" -ForegroundColor Yellow

    try {
        # 0. Remove user from User Group
        aws iam remove-user-from-group --user-name $User --group-name $group

        # 1. Delete login profile (if exists)
        aws iam delete-login-profile --user-name $User 2>$null

        # 2. Detach managed policies
        <#$policies = aws iam list-attached-user-policies --user-name $User | ConvertFrom-Json
        foreach ($policy in $policies.AttachedPolicies) {
            aws iam detach-user-policy --user-name $User --policy-arn $policy.PolicyArn
        }#>

        # 3. Delete inline policies
        <#$inlinePolicies = aws iam list-user-policies --user-name $User | ConvertFrom-Json
        foreach ($policyName in $inlinePolicies.PolicyNames) {
            aws iam delete-user-policy --user-name $User --policy-name $policyName
        }#>

        # 4. Delete access keys
        $accessKeys = aws iam list-access-keys --user-name $User | ConvertFrom-Json
        foreach ($key in $accessKeys.AccessKeyMetadata) {
            aws iam delete-access-key --user-name $User --access-key-id $key.AccessKeyId
        }

        # 5. Delete signing certificates
        <#$certs = aws iam list-signing-certificates --user-name $User | ConvertFrom-Json
        foreach ($cert in $certs.Certificates) {
            aws iam delete-signing-certificate --user-name $User --certificate-id $cert.CertificateId
        }#>

        # 6. Delete MFA devices
        $mfaDevices = aws iam list-mfa-devices --user-name $User | ConvertFrom-Json
        foreach ($device in $mfaDevices.MFADevices) {
            aws iam deactivate-mfa-device --user-name $User --serial-number $device.SerialNumber
            aws iam delete-virtual-mfa-device --serial-number $device.SerialNumber
        }

        # 7. Delete SSH public keys
        $sshKeys = aws iam list-ssh-public-keys --user-name $User | ConvertFrom-Json
        foreach ($key in $sshKeys.SSHPublicKeys) {
            aws iam delete-ssh-public-key --user-name $User --ssh-public-key-id $key.SSHPublicKeyId
        }

        # 8. Delete service-specific credentials (like CodeCommit)
        <#$serviceCreds = aws iam list-service-specific-credentials --user-name $User 2>$null | ConvertFrom-Json
        if ($serviceCreds.ServiceSpecificCredentials) {
            foreach ($cred in $serviceCreds.ServiceSpecificCredentials) {
                aws iam delete-service-specific-credential --user-name $User --service-specific-credential-id $cred.ServiceSpecificCredentialId
            }
        }#>

        # 9. Finally, delete the user
        aws iam delete-user --user-name $User

        Write-Host "Successfully deleted user: $User`n"
    } catch {
        Write-Warning "Failed to delete user: $User. Error: $_"
    }
}
