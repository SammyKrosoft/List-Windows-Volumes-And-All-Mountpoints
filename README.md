# List-Windows-Volumes-And-All-Mountpoints
This script will list Windows Mountpoints (other than Root drives) for each volumes on a given server or workstation. 
Also, optionnally with the -CountEDBandLOGs switch, it will count and display total size of EDB and LOG files (for Exchange Server) on each volume.

# Download the current version of this repository here

Right-Click and chose "Save Link As" to save the current script on your hard drive:

[ListAllVolumeMountPoints.ps1](https://raw.githubusercontent.com/SammyKrosoft/List-Windows-Volumes-And-All-Mountpoints/main/ListAllVolumeMountPoints.ps1)

# Usage

- To export the volumes, all their mointpoints and the EDB and LOG files stats (can be long):
```powershell
ListVolumeAndContents.ps1 -OutputFolder c:\temp\ -Server E2016-01 -CountEDBandLOGs
```

- To export only the volumes and all their mointpoints (very fast):
```powershell
ListVolumeAndContents.ps1 -OutputFolder c:\temp\ -Server E2016-01
```

> Hint: type the following on Windows PowerAhell :

```powershell
Show-Command .\ListVolumeAndContents.ps1
```

>And you'll be presented a sort of GUI helping you to fill the parameters and directly click the "Run" button to execute the script:

![image](https://user-images.githubusercontent.com/33433229/119203569-55434c80-ba61-11eb-9d3d-f8449cd7dd40.png)

>**NOTE**: that works for all PowerShell cmdlets and scripts using parameters !

#Outputs

## Console output

Sample output:

![image](https://user-images.githubusercontent.com/33433229/119164649-a421bf80-ba2a-11eb-8fa2-9d1a834af576.png)


in Red on the above output sample you can see the output file location:
![image](https://user-images.githubusercontent.com/33433229/119164854-d501f480-ba2a-11eb-9975-3bad028f8855.png)

## File output

The file is stored as indicated on the console output. Here's a simple content for one of my Lab servers:

![image](https://user-images.githubusercontent.com/33433229/119180328-28317280-ba3e-11eb-80f0-499977d91eb6.png)

And you can format by copy/pasting the content or directly opening the CSV in Excel:

![image](https://user-images.githubusercontent.com/33433229/119181179-3c29a400-ba3f-11eb-98e4-b431a74257cc.png)
