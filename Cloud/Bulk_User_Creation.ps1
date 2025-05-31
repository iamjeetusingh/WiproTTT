cls

# calling the CSV file within PS script
$csvPath = "E:\Wipro\TTT-Batch\users.csv"

# importing the file
$users = Import-Csv -Path $csvPath

# running the foreach loop to create accounts
foreach ($user in $users) {
    $userName = $user.UserName                    # fetching user names
    $password = $user.Password                    # fetching user's password
    $group    = $user.Group                          # fetching group name

    Write-Host "Creating IAM user: $userName"

    # Create the IAM user
    aws iam create-user --user-name $userName

    # Create login profile for console access
    aws iam create-login-profile --user-name $userName --password $password --password-reset-required

    # Add user to group
    aws iam add-user-to-group --user-name $userName --group-name $group

    Write-Host "User $userName created and added to group $group`n"
}
