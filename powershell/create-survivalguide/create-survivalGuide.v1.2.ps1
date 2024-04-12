#VERSION 1.2
# Created by Sylvain LESIRE

$HTMLdoc = $null

$HTMLdoc = @('<html>
<style type="text/css">
p {
  font-family: Helvetica, sans-serif;
  font-size: 60%
}

* { margin:0; padding:0; }
.navbar ul {
  font-family: Helvetica, sans-serif;
  font-size: 90%;
  position:relative;
  width:100%; 
  list-style:none outside none;
}
.navbar ul li {
  float:left; /* menu, sous-menus horizontaux */
}
.navbar ul:before, .navbar ul:after {
  display:table; content:''''; clear:both;
  /* permet de remettre les li float:left dans le flux */
}
.navbar > ul li ul {
  display:none; /* sous-menu masqués */
  position:absolute;
  top:100%;
  left:0;
}
.navbar li:hover > ul {
  display:block; /* sous-menu affiché */
}
 
/* ----------------------- */
/* DECO */
.navbar ul { /* niveau 1 */
  background:#aaa;
}
.navbar ul ul { /* niveau 2 */
  background:#bbb;
}
.navbar ul ul ul { /* niveau 3 */
  background:#ccc;
}
.navbar ul li a {
  display:block;
  padding:10px 15px;
  color:#111;
  text-decoration:none;
}

.navbar ul li:hover > a {
  background:#666;
  color:#fff;
}

.inprivate {
    background-color: red;
}
.navbar ul li a {
  border-right:1px solid #fff;
}

table, th, td {
  font-family: Helvetica, sans-serif;
  font-size: 90%;
  border: 1px solid black;
  border-collapse: collapse;
}
th {
    background-color: #bbb;

}
h2 {
  font-family: Helvetica, sans-serif;
}

</style>
<title>Survival Guide - Liens utiles</title>
<body>
<img src="Head.jpg" width="200">  <br>
    <nav class="navbar" id="topmenu">
        <ul>
          <li> &nbsp;&nbsp;&nbsp;
            
          </li>  


')

#  survival guide DB path 
$BDDFile = $env:OneDriveCommercial + "\page d'accueil\DB_survivalGuide.csv"
# import DB
$DBSG = import-csv $BDDFile  -Delimiter ";" | sort Catégorie,application

# create top menu
$AllCategories = ($DBSG | group catégorie).Name
$n=0
foreach ($Categorie in $AllCategories) {
   $HTMLdoc += @('          <li> <a href="#">'+ $Categorie + '</a>  
            <ul>')


   $DBSG | where {$_.catégorie -eq $Categorie} | %{
        $n++
         $HTMLdoc += @('
               <li class="'+$_.inprivate+'" Title="'+$_.commentaires+'"> <a target="_new" href="'+$_.url+'" id="'+$n +'"> '+ $_.application +'</a>
                </li>')           
   
   }

   $HTMLdoc += @('           </ul>
          </li> ')

}

# create main page

 $HTMLdoc +=@('

        </ul>
      </nav>   
 ')


$HTMLdoc +=@('
<br>
<br>
<br>
')


$oldCat = $null
$DBSG | % {

$newCat =  $_.catégorie 

if ($newCat -ne $oldCat) {
  if ($oldCat -ne $null ) {
    $HTMLdoc +=@('</table>')
  } 
  $HTMLdoc +=@('
  <br>
  <H2>'+ $newCat + '</h2>
  <table width="100%">

    <tr>
        <th width=10%> Catégorie </th>
        <th width=20%> Applications</th>
        <th> Commentaires</th>
        <th width=10%> Navigateur recommandé</th>
        <th width=10%> Mode de Navigation</th>
    </tr>
  ')

} 
$HTMLdoc +=@('
    <tr>
        <td> ' +$_.catégorie + '</td>
        <td> <a href="'+$_.url+'" target="_new">' +$_.Application + '</a> </td>
        <td> ' +$_.commentaires + '</td>
        <td> ' +$_.Navigateur + '</td>
        <td> ' +$_.inprivate + '</td>
    </tr>
')

$oldCat = $_.catégorie 

}


# footer page

[String]$dateRapport = Get-Date -Format "dddd dd/MM/yyyy HH:mm "
$mypath = $MyInvocation.MyCommand.Path
 
 $HTMLdoc +=@('
    </table>
<br>
<br>
<br>
<p>Document généré le : '+$daterapport +' </p>
<p>Emplacement de la BDD : '+$BDDFile+ '</p>
<p>Emplacement du script de generation du document : '+$mypath + '</p>
</body>

</html>')

 

# copy old file
$rootFolder = $env:OneDriveCommercial + "\page d'accueil"
$webPage = $rootFolder + "\Page_acc.html"
$bkpfolder= $webPagebkp = $env:OneDriveCommercial + "\Documents\Tools\Powershell\Create-survivalGuide\"
$webPagebkp = $env:OneDriveCommercial + "\Documents\Tools\Powershell\Create-survivalGuide\Page_acc.BKP"
$webPageNew = $env:OneDriveCommercial + "\Documents\Tools\Powershell\Create-survivalGuide\Page_acc.new"
$dbbkp = $env:OneDriveCommercial + "\Documents\Tools\Powershell\Create-survivalGuide\DB_survivalGuide.csv.bkp"
copy-item $webPage -Destination $webPagebkp -Force

# create HTML
$HTMLdoc | Out-File $webPage -Encoding utf8

# copy new file
copy-item $webPage -Destination $webPageNew -Force

# Copy BDD
copy-item $BDDFile -Destination $dbbkp -Force

# script path
$scriptfolder = split-path -parent $MyInvocation.MyCommand.Definition
# select file to delete
$filetodelete = dir $bkpfolder -Exclude *.zip,*.ps1,*old | where {$_.FullName -notlike "*Archive*"}
# select file to bkp
$filetobackup = dir $bkpfolder -Exclude *.zip  | where {$_.FullName -notlike "*Archive*"}

# date format ANNEEMOISJOUR
$datef = Get-Date -Format "yyyyMMdd"
# bkp file path
$bkpfilePath  = $bkpfolder + "\" + $datef + "_Bkp_SurvivalGuide.zip"

# create archive of filestobackup in bkp fie path
$filetobackup | Compress-Archive -DestinationPath $bkpfilePath -Force -CompressionLevel Optimal 

# remove file to delete (=/= bkp file)
remove-item $filetodelete 
