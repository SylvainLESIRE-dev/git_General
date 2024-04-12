$SAMAccountName = $env:USERNAME

[adsisearcher]$searcher="(&(objectClass=user)(SAMAccountName="+ $SAMAccountName +") )"
$searcher.PageSize = 10

$Users = $searcher.findall()
foreach ($user in $Users) {

    $user.properties

}      