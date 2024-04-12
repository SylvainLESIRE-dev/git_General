$Name = "LESIRE"

[adsisearcher]$searcher="(&(objectClass=user)(Name=*"+ $Name +"*) )"
$searcher.PageSize = 10

$Users = $searcher.findall()
foreach ($user in $Users) {

    $user.properties

}      