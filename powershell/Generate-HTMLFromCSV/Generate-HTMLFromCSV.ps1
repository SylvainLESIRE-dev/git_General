param ($CSVFilePath)

$ScriptPath = $MyInvocation.MyCommand.Path
# to comment 
$CSVFilePath = "C:\dev\powershell\Generate-HTMLFromCSV\gp_tasks-test.csv"


#HTML Path
$htmlPathFile = "C:\dev\powershell\Generate-HTMLFromCSV\Untitled-1.html"
# get content of htmPathlFile
$htmlContent = get-content $htmlPathFile -Encoding UTF8


$Client = "Nom du client"
$ProjectName = "Move To Cloud"
$ProjectNameshort = "Move2Cloud" 


$WBSFileName = "WBS#"+$client+"#"+$ProjectNameshort

$outputWBSPathFile = "C:\dev\powershell\Generate-HTMLFromCSV\"+$WBSFileName+ ".html" 

$htmlTASKs = ('
    <h3 id="#ID#">#ID# #TACHE#</h3>
            <table>
                <tr>
                    <th><img src="img/ok_r.png">Nom de la tache</th>
                    <td>#TACHE#</td>
                    <th><img src="img/link_b.png">Parent</th>
                    <td>#Parent#</td>
                </tr>
                <tr>
                    <th><img src="img/idea_r.png">Description</th>
                    <td colspan="3">#Description#</td>   
                </tr>
                <tr>
                    <th><img src="img/smile_r.png">Responsable(s)</th>
                    <td>#Responsable#</td>
                    <th><img src="img/flash_b.png">Budget</th>
                    <td>#Budget#</td>
                </tr>
                <tr>
                    <th><img src="img/where_r.png">Date estimée de début</th>
                    <td>#startdate#</td>
                    <th><img src="img/where_b.png">Durée estimée</th>
                    <td>#delay#</td>
                </tr>
                <tr>
                    <th><img src="img/link_r.png">Dépendance</th>
                    <td>#IDDependency#</td>
                    <th><img src="img/statut_b.png">Status de la tâche</th>
                    <td>#statut#</td>
                </tr>
                <tr>
                    <th><img src="img/search_r.png">Réferences</th>
                    <td colspan="3"><a href="#URL#">#URLdesc#</a></td>
                </tr>

                <tr>
                    <th><img src="img/search_r.png">Risques, points d'+ "'"+'attention</th>
                    <td>#Risk#</td>
                    <th><img src="img/search_b.png">Recommandations, préconisations</th>
                    <td>#preco#</td>
                <tr>
                    <th><img src="img/search_r.png">Livrable</th>
                    <td colspan="3">#Delivery#</td>
                </tr>
            </table>
')

# check argument CSVFilePath
if ($CSVFilePath -eq $null -or $CSVFilePath -eq "") {
    Write-host "Pas de fichier spécifé" -ForegroundColor Red
    Write-host "Syntaxe : & $ScriptPath -csvFilePath C:\scriptPath\MonFichier.csv" -ForegroundColor Red
    exit
}

$MyCSV = $content = $null

$MyCSV = import-csv $CSVFilePath -Delimiter ";" -Encoding Default
write-host "Nombre de Taches à ajouter" $MyCSV.count


$MyCSV | % {
    write-host "Nom de la tache ajoutée:"$_.Name

    $tmphtmlTasks = $htmlTASKs

    $tmphtmlTasks=$tmphtmlTasks.Replace("#ID#",$_.'Outline number') 

    $Value = $_.'Outline number'
    $Array = $Value.Split(".")
    $Nb = $Array.Count -1

    $val=$null

    if ($Nb -ge 1) { 
        For($i=0 ; $i -lt $nb ; $i++) 
        { 
           $val+=$Array[$i]+"."
        }

        $ParentID = $Val.Substring(0,$Val.Length-1)
        $TmpArr= $MyCSV | where {$_.'Outline number' -eq $ParentID } 
        #$TmpArr
        $TmpArr| % {$Parent = $ParentID + " "+ $_.Name}
        $ParentValue = ('<a href="#'+$ParentID+'">'+$Parent +'</a>')
    } Else {
        $ParentValue="Racine"
    }

    $tmphtmlTasks=$tmphtmlTasks.Replace("#Parent#",$ParentValue)

    $tmphtmlTasks=$tmphtmlTasks.Replace("#TACHE#",$_.Name) 
    $tmphtmlTasks=$tmphtmlTasks.Replace("#Description#",$_.Notes) 
    $responsable = $_.Assignments.split(";") | % {$_ +"<br>"}
    $tmphtmlTasks=$tmphtmlTasks.Replace("#Responsable#", $responsable) 
    $tmphtmlTasks=$tmphtmlTasks.Replace("#startdate#", $_.'Begin Date')
    $tmphtmlTasks=$tmphtmlTasks.Replace("#delay#", $_.Duration + " J" )
    $tmphtmlTasks=$tmphtmlTasks.Replace("#statut#", $_.Completion)
    $tmphtmlTasks=$tmphtmlTasks.Replace("#Budget#", $_.Cost) 


    $Value = $_.Predecessors
    $dependencies=$null
    if ($value -ne "" -and $value -ne $null) {
        $Array = $Value.Split(";")
        $Nb = $Array.Count -1
    
        if ($nb -eq 0) {
            $TmpArr= $MyCSV | where {$_.ID -eq $value}
            $TmpArr| % {$Parent = $_.Name ; $id = $_.'Outline number'}

            $dependencies = ('<a href="#'+$id +'">'+$Parent +'</a>') 
        }
        if ($nb -ge 1) {

            $Array | % {
                $tmpdependencies = @()
                $value = $_
                $TmpArr= $MyCSV | where {$_.ID -eq $value}
                $TmpArr| % {
                    $Parent = $_.Name ; $id = $_.'Outline number'         
                    }

                $tmpdependencies = ('<a href="#'+$id +'">'+$Parent +'</a><br>') 
                $dependencies+= $tmpdependencies
                }
        }
        #$dependencies
    }Else {
        $dependencies="&nbsp;"
    }

    $tmphtmlTasks=$tmphtmlTasks.Replace("#IDDependency#", $dependencies) 


    $content +=$tmphtmlTasks

}

$htmlContent = $htmlContent.Replace("##ADDTASKS##",$content) 
$htmlContent = $htmlContent.Replace("#CLIENT#",$Client) 

$htmlContent = $htmlContent.Replace("#DATE#",$(Get-Date -Format "dd/MM/yyyy")) 
$htmlContent = $htmlContent.Replace("#PROJET#",$ProjectName) 



$htmlContent | Out-File $outputWBSPathFile -Encoding UTF8