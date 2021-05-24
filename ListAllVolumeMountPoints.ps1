
<#PSScriptInfo

.VERSION 1.0

.GUID 85403e0e-00ad-42aa-bace-8bda1b9018f6

.AUTHOR Administrator

.COMPANYNAME 

.COPYRIGHT 

.TAGS 

.LICENSEURI 

.PROJECTURI 

.ICONURI 

.EXTERNALMODULEDEPENDENCIES 

.REQUIREDSCRIPTS 

.EXTERNALSCRIPTDEPENDENCIES 

.RELEASENOTES


#>

<# 

.DESCRIPTION 
    This script dumps the list of volumes of a server (Local or remote) and its associated mountpoints.
    Also, as I developped this script for Exchange servers, it will list all EDB files in each volume
    displaying the number of files, their total size, and their names (semi-colon separated), as well as
    the LOG files in each volumes, but for these I dump only the total size and the number of files as
    there might be hundreds or thousands of LOG files on a server...

    The core of the script is the Get-WMIObject command on the Win32_MountPoints class that dumps all mountpoints
    and their corresponding volumes:

        Get-WmiObject -Class Win32_MountPoint

    The rest is PowerShell grouping (Group-Object cmdlet) for mountpoints grouping for each volume,
     or Measure-Object to add all EDB or LOG file sizes to have a global size.

    The script dumps the results on the screen and on a file which name is built on the concatenation of
     the script name (ListVolumesAndContents) with the server name (_E2016-01_), the date and 
     time stamp (-01_21-05-2021-11-12-15) and the extension (.csv)

.EXAMPLE
    ListVolumeAndContents.ps1 -Servers "Server01" -OutputFolder "c:\temp\"
    This will list all volumes and mountpoints of Server01, and dump the result on the screen and into
    a file located in the C:\temp directory.

.EXAMPLE
    ListVolumeAndContents.ps1 -Servers "Server01", "Server02", "Server03" -OutputFolder "c:\temp\"
    This will list and save a file with all volumes and mountpoints of 3 servers, Server01, Server02
    and Server03


#> 
[CmdletBinding()]
param (
    [parameter(Mandatory = $true)]
    [string[]]$Servers = "E2016-01",
    [string]$OutputFolder="c:\temp\",
    [switch]$CountEDBandLOGs
)

If($($Servers.count) -gt 1){
    $OutputFile = $OutputFolder + "ListVolumesAndContents_$($Servers[0])_MultipleServers_$(Get-Date -F "dd-MM-yyy-hh-mm-ss").csv"
} Else {
    $OutputFile = $OutputFolder + "ListVolumesAndContents_$($Servers)_$(Get-Date -F "dd-MM-yyy-hh-mm-ss").csv"
}

# Initializing Volume collection variable
$VolCollection = @()

Foreach ($Server in $Servers){

    Write-Host "Server : $Server" -ForegroundColor DarkBlue -BackgroundColor Yellow
    # Getting the list of mountpoints of the server using Win32_MountPoint class. That gets all the mountpoints of the machine, and indicates the corresponding volume as well for each mountpoint. We can have the same volume for multiple mountpoints.
    $Vols = Get-WmiObject -Class Win32_MountPoint -ComputerName $Server | Select Volume, Directory,@{label="Server";Expression = {$_.__Server}}



    # Populating Volume collection variable through a Foreach loop, with a custom PowerShell object [pscustomobject] and only if it's a mountpoint (excluding root directory)
    Foreach ($volume in $Vols){
        $ObjectPRoperties = @{
            # Getting the volume directory that is after the first double-quote.
            Server = $Volume.Server
            MountPoint = $volume.Directory.split('"')[1]
            Volume = $Volume.Volume
        }
        If ($ObjectPRoperties.MountPoint.Length -gt 4){
            $VolCollection += [pscustomobject]$ObjectPRoperties
        }
    }

    # Grouping volumes to have unique volumes and the list of mountpoints per volume
    $MountPointsGrouped = $VolCollection | Group-Object Volume

    $MountPointsCollection = @()
    # Storing the volume and its corresponding mountpoints in a custom variable
    Foreach ($MountPointVol in $MountPointsGrouped){

        if ($CountEDBandLOGs){
            # Extracting first mountpoint just to do a Get-ChildItem on a valid folder...
            $FirstMountPoint = $(If ($MountPointVol.Group.Mountpoint.count -gt 1){$MountPointVol.Group.Mountpoint[0]} Else {$MountPointVol.Group.Mountpoint})

            Write-Host "Parsing database files on $FirstMountPoint, please wait..." -ForegroundColor Green
            # NOW getting all EDB file under current mountpoint/volume...
            $AllEDBFilesObjects = Get-ChildItem  "$($FirstMountPoint)\*.edb" -recurse
            # Counting number of files
            $NumberofEDBFileObjects = $AllEDBFilesObjects.count
            Write-Host "Getting size of all EDB files, please wait..."
            # Getting total EDB files sizes
            $SizeofEDBFileObjects = $("{0:N2} GB" -f (($AllEDBFilesObjects | Measure-Object -Property Length -Sum -ErrorAction Stop).Sum / 1GB))

            # Adding EDB files names as per Po's request
            $EDBFilesFullNamesJoined = $AllEDBFilesObjects | ? {$_.Name -notlike "*tmp.edb*"}  | % {$_.FullName}
            $EDBFilesFullNamesJoined = $EDBFilesFullNamesJoined -join ";"
            $EDBFilesSimpleNamesJoined = $AllEDBFilesObjects | ? {$_.Name -notlike "*tmp.edb*"} | % {$_.Name}
            $EDBFilesSimpleNamesJoined = $EDBFilesSimpleNamesJoined -join ";"

            #doing the same for LOG files...
            Write-Host "Parsing log files on $FirstMountPoint, please wait, this can take a VERY long time..." -ForegroundColor Green
            # NOW getting all EDB file under current mountpoint/volume...
            $AllLOGFilesObjects = Get-ChildItem  "$($FirstMountPoint)\*.log" -recurse
            # Counting number of files
            $NumberofLogFileObjects = $AllLOGFilesObjects.count
            Write-Host "Getting size of all LOG files, please wait..."
            # Getting total LOG files sizes
            $SizeofLOGFileObjects = $("{0:N2} GB" -f (($AllLOGFilesObjects | Measure-Object -Property Length -Sum -ErrorAction Stop).Sum / 1GB))
        }


        # Now populating properties of the collection (Server/Volume/Mountpoints/NumberOfEDB/SizeOfEDB)
        $Hash=@{
            Server = $(if($MountPointVol.Group.Server.count -eq 1){$MountPointVol.Group.Server}else{$MountPointVol.Group.Server[0]})
            Volume = $MountPointVol.Name.split('"')[1].Replace('\\', '\')
            Mountpoints = $MountPointVol.Group.Mountpoint.Replace('\\', '\') -join ";"
        }

        If ($CountEDBandLOGs){
            $Hash.add("NumberOfEDBFiles" , "$NumberofEDBFileObjects")
            $Hash.add("SizeOfEDBFiles" , "$SizeofEDBFileObjects")
            $Hash.add("NumberOfLOGFiles" , "$NumberofLogFileObjects")
            $Hash.add("SizeofLOGFiles" , "$SizeofLOGFileObjects")
            $Hash.add("EDBFilesFullPath" , "$EDBFilesFullNamesJoined")
            $Hash.add("EDBFilesNames" , "$EDBFilesSimpleNamesJoined")
        }

        $MountPointsCollection += [pscustomobject]$Hash

    } # enf of the Foreach ($MountVol in $MountVolCollection) loop
}
    #Display mountpoint collection on screen
    Write-host "Export saved on $OutputFile" -backgroundColor DarkRed -ForegroundColor White
    If ($CountEDBandLOGs){
        $MountPointsCollection | select Server, volume, mountpoints,NumberOfEDBFiles, SizeOfEDBFiles, NumberOfLOGFiles, SizeofLOGFiles,EDBFilesFullPath,EDBFilesNames | Export-csv -NoTypeInformation $OutputFile
        return $MountPointsCollection | select Server, volume, mountpoints,NumberOfEDBFiles, SizeOfEDBFiles, NumberOfLOGFiles, SizeofLOGFiles,EDBFilesFullPath,EDBFilesNames
    } Else {
        $MountPointsCollection | select Server, volume, mountpoints | Export-csv -NoTypeInformation $OutputFile
        return $MountPointsCollection | select Server, volume, mountpoints
    }

    <#If you make the above a function, use it like below :

        ListMountPointsPerVolume -Server "E2016-01" | ft
        ListMountPointsPerVolume -Server "E2016-02" | ft

    To make this script a function, add "Function {" at the very beginning before the Param() statement, and 
    don't forget to close the function bracket "}" at the end of the script, either before or after this comment block
    #>
