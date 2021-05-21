# List-Windows-Volumes-And-All-Mountpoints
This script will list Windows Mountpoints (other than Root drives) for each volumes on a given server or workstation

# Download the current version of this repository here

Right-Click and chose "Save Link As" to save the current script on your hard drive:

[ListAllVolumeMountPoints.ps1](https://raw.githubusercontent.com/SammyKrosoft/List-Windows-Volumes-And-All-Mountpoints/main/ListAllVolumeMountPoints.ps1)

# Usage

```powershell
.\ListVolumeAndContents.ps1 -Server "E2016-01" | ft
```

> Hint: type the following on Windows PowerAhell :

```powershell
Show-Command .\ListVolumeAndContents.ps1
```

>And you'll be presented a sort of GUI helping you to fill the parameters:

![image](https://user-images.githubusercontent.com/33433229/119179800-5f535400-ba3d-11eb-8902-3cc9192d7b82.png)

>**NOTE**: that works for all PowerShell cmdlets and scripts using parameters !

Sample output:

![image](https://user-images.githubusercontent.com/33433229/119164649-a421bf80-ba2a-11eb-8fa2-9d1a834af576.png)


in Red on the above output sample you can see the output file location:
![image](https://user-images.githubusercontent.com/33433229/119164854-d501f480-ba2a-11eb-9975-3bad028f8855.png)

