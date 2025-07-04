<#

.SYNOPSIS
PSAppDeployToolkit - This script performs the installation or uninstallation of an application(s).

.DESCRIPTION
- The script is provided as a template to perform an install, uninstall, or repair of an application(s).
- The script either performs an "Install", "Uninstall", or "Repair" deployment type.
- The install deployment type is broken down into 3 main sections/phases: Pre-Install, Install, and Post-Install.

The script imports the PSAppDeployToolkit module which contains the logic and functions required to install or uninstall an application.

PSAppDeployToolkit is licensed under the GNU LGPLv3 License - (C) 2024 PSAppDeployToolkit Team (Sean Lillis, Dan Cunningham, Muhammad Mashwani, Mitch Richters, Dan Gough).

This program is free software: you can redistribute it and/or modify it under the terms of the GNU Lesser General Public License as published by the
Free Software Foundation, either version 3 of the License, or any later version. This program is distributed in the hope that it will be useful, but
WITHOUT ANY WARRANTY; without even the implied warranty of MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the GNU General Public License
for more details. You should have received a copy of the GNU Lesser General Public License along with this program. If not, see <http://www.gnu.org/licenses/>.

.PARAMETER DeploymentType
The type of deployment to perform. Default is: Install.

.PARAMETER DeployMode
Specifies whether the installation should be run in Interactive, Silent, or NonInteractive mode. Default is: Interactive. Options: Interactive = Shows dialogs, Silent = No dialogs, NonInteractive = Very silent, i.e. no blocking apps. NonInteractive mode is automatically set if it is detected that the process is not user interactive.

.PARAMETER AllowRebootPassThru
Allows the 3010 return code (requires restart) to be passed back to the parent process (e.g. SCCM) if detected from an installation. If 3010 is passed back to SCCM, a reboot prompt will be triggered.

.PARAMETER TerminalServerMode
Changes to "user install mode" and back to "user execute mode" for installing/uninstalling applications for Remote Desktop Session Hosts/Citrix servers.

.PARAMETER DisableLogging
Disables logging to file for the script. Default is: $false.

.EXAMPLE
powershell.exe -File Invoke-AppDeployToolkit.ps1 -DeployMode Silent

.EXAMPLE
powershell.exe -File Invoke-AppDeployToolkit.ps1 -AllowRebootPassThru

.EXAMPLE
powershell.exe -File Invoke-AppDeployToolkit.ps1 -DeploymentType Uninstall

.EXAMPLE
Invoke-AppDeployToolkit.exe -DeploymentType "Install" -DeployMode "Silent"

.INPUTS
None. You cannot pipe objects to this script.

.OUTPUTS
None. This script does not generate any output.

.NOTES
Toolkit Exit Code Ranges:
- 60000 - 68999: Reserved for built-in exit codes in Invoke-AppDeployToolkit.ps1, and Invoke-AppDeployToolkit.exe
- 69000 - 69999: Recommended for user customized exit codes in Invoke-AppDeployToolkit.ps1
- 70000 - 79999: Recommended for user customized exit codes in PSAppDeployToolkit.Extensions module.

.LINK
https://psappdeploytoolkit.com

#>

[CmdletBinding()]
param
(
    [Parameter(Mandatory = $false)]
    [ValidateSet('Install', 'Uninstall', 'Repair')]
    [System.String]$DeploymentType = 'Install',

    [Parameter(Mandatory = $false)]
    [ValidateSet('Interactive', 'Silent', 'NonInteractive')]
    [System.String]$DeployMode = 'Interactive',

    [Parameter(Mandatory = $false)]
    [System.Management.Automation.SwitchParameter]$AllowRebootPassThru,

    [Parameter(Mandatory = $false)]
    [System.Management.Automation.SwitchParameter]$TerminalServerMode,

    [Parameter(Mandatory = $false)]
    [System.Management.Automation.SwitchParameter]$DisableLogging
)


##================================================
## MARK: Variables
##================================================

$adtSession = @{
    # App variables.
    AppVendor = 'Microsoft'
    AppName = 'MSPowerBIDesktop'
    AppVersion = '2.138.1452.0'
    AppArch = 'x64'
    AppLang = 'EN'
    AppRevision = '01'
    AppSuccessExitCodes = @(0)
    AppRebootExitCodes = @(1641, 3010)
    AppScriptVersion = '1.0.0'
    AppScriptDate = '2025-02-17'
    AppScriptAuthor = 'Vivek'
    AppID = "1058_Microsoft_MSPowerBIDesktop_2.138.1452.0_PKG_R1"

    # Install Titles (Only set here to override defaults set by the toolkit).
    InstallName = '1058_Microsoft_MSPowerBIDesktop_2.138.1452.0_PKG_R1'
    InstallTitle = '1058_Microsoft_MSPowerBIDesktop_2.138.1452.0_PKG_R1'

    # Script variables.
    DeployAppScriptFriendlyName = $MyInvocation.MyCommand.Name
    DeployAppScriptVersion = '4.0.5'
    DeployAppScriptParameters = $PSBoundParameters
}

function Install-ADTDeployment
{
    ##================================================
    ## MARK: Pre-Install
    ##================================================
    $adtSession.InstallPhase = "Pre-$($adtSession.DeploymentType)"

    ## <Perform Pre-Installation tasks here>

    ##Giving defer prompt if the application process is running:
    Show-ADTInstallationWelcome -CloseProcesses @{ Name = 'PBIDesktop'; Description = 'PBIDesktop' },@{ Name = 'PowerBIReportBuilder'; Description = 'PowerBIReportBuilder' },@{ Name = 'TabularEditor'; Description = 'TabularEditor' },@{ Name = 'DaxStudio'; Description = 'DaxStudio' } -AllowDeferCloseProcesses -DeferTimes 3 -PersistPrompt -NoMinimizeWindows


	    ##<Perform Uninstallation of PowerBIDesktop if present>
		#==========================================================================================================================
        ##Microsoft Power BI Desktop (x64)
            if(Test-Path "HKLM:SOFTWARE\Microsoft\Windows\CurrentVersion\Uninstall\{03d5b012-927e-40b0-b97d-31a7fcdef92d}")
            {
                       Start-ADTMsiProcess -Action 'Uninstall' -ProductCode '{03d5b012-927e-40b0-b97d-31a7fcdef92d}' -ArgumentList '/QN'		                         
            }

        ##Microsoft Analysis Services OLE DB Provider
            if(Test-Path "HKLM:SOFTWARE\Microsoft\Windows\CurrentVersion\Uninstall\{13104D4F-CDAC-41A8-A197-E646EED2A1DC}")
            {

                       Start-ADTMsiProcess -Action 'Uninstall' -ProductCode '{13104D4F-CDAC-41A8-A197-E646EED2A1DC}' -ArgumentList '/QN'		                         
            }

        ##Power BI Report Builder
            if(Test-Path "HKLM:SOFTWARE\Microsoft\Windows\CurrentVersion\Uninstall\{E1574425-A3D1-45BA-8A6A-DCFA55C47AC5}")
            {
                      Start-ADTMsiProcess -Action 'Uninstall' -ProductCode '{E1574425-A3D1-45BA-8A6A-DCFA55C47AC5}' -ArgumentList '/QN'		                         
            }

        ##DAX Studio 3.0.7.916
            if (Test-Path -Path "$envProgramFiles\DAX Studio\unins000.exe")
            {
                Start-ADTProcess -FilePath "$envProgramFiles\DAX Studio\unins000.exe" -ArgumentList "/VERYSILENT" -WindowStyle 'Hidden'
            }
        
        ##Tabular Editor
            if(Test-Path "HKLM:SOFTWARE\WOW6432Node\Microsoft\Windows\CurrentVersion\Uninstall\{EACBA567-E11C-4CB7-8F6C-17036EB58B0E}")
            {
                      Start-ADTMsiProcess -Action 'Uninstall' -ProductCode '{EACBA567-E11C-4CB7-8F6C-17036EB58B0E}' -ArgumentList '/QN'
		                         
            } 
	   		   

           #==================================================================================================

          ##<Remove registry branding of PowerBIDesktop>

           Remove-ADTRegistryKey -Key 'HKEY_LOCAL_MACHINE\SOFTWARE\AMC\Packages\804_Microsoft_MSPowerBIDesktop_2.132.1053.0_PKG_R1'
    Invoke-ADTAllUsersRegistryAction -ScriptBlock {
    #Remove-ADTRegistryKey -Key 'HKEY_CURRENT_USER\SOFTWARE\Microsoft\Microsoft Power BI Desktop' -Recurse -SID $_.SID
           }


           #=========================================================================================================


        Remove-ADTFileFromUserProfiles -Path "AppData\Local\Microsoft\Power BI Report Builder\15.7" -Recurse
        Remove-ADTFileFromUserProfiles -Path "AppData\Local\Microsoft\Power BI Desktop\User.zip"




    ##================================================
    ## MARK: Install
    ##================================================
    $adtSession.InstallPhase = $adtSession.DeploymentType

    ## Handle Zero-Config MSI installations.
    if ($adtSession.UseDefaultMsi)
    {
        $ExecuteDefaultMSISplat = @{ Action = $adtSession.DeploymentType; FilePath = $adtSession.DefaultMsiFile }
        if ($adtSession.DefaultMstFile)
        {
            $ExecuteDefaultMSISplat.Add('Transform', $adtSession.DefaultMstFile)
        }
        Start-ADTMsiProcess @ExecuteDefaultMSISplat
        if ($adtSession.DefaultMspFiles)
        {
            $adtSession.DefaultMspFiles | Start-ADTMsiProcess -Action Patch
        }
    }

    ## <Perform Installation tasks here>



    ##Install Power BI Desktop EXE:
    Start-ADTProcess -FilePath "$($adtSession.DirFiles)\PBIDesktopSetup_x64.exe" -ArgumentList "-s -norestart ACCEPT_EULA=1 INSTALLDESKTOPSHORTCUT=0 DISABLE_UPDATE_NOTIFICATION=1"

        If (Test-Path "$envProgramFiles\Microsoft Power BI Desktop\bin\PBIDesktop.exe"){
          Set-ADTRegistryKey -Key 'HKEY_LOCAL_MACHINE\SOFTWARE\Microsoft\Windows\CurrentVersion\Uninstall\{2445f577-1578-434b-bc21-ce16be98d610}' -Name 'NoRemove' -Type 'DWord' -Value '1'
          Set-ADTRegistryKey -Key 'HKEY_LOCAL_MACHINE\SOFTWARE\Microsoft\Windows\CurrentVersion\Uninstall\{2445f577-1578-434b-bc21-ce16be98d610}' -Name 'NoModify' -Type 'DWord' -Value '1'

          Set-ADTRegistryKey -Key 'HKEY_LOCAL_MACHINE\SOFTWARE\WOW6432Node\Microsoft\Windows\CurrentVersion\Uninstall\{f3b3bd4d-e177-42a2-9c14-e6b419ca11a4}' -Name 'NoRemove' -Type 'DWord' -Value '1'
          Set-ADTRegistryKey -Key 'HKEY_LOCAL_MACHINE\SOFTWARE\WOW6432Node\Microsoft\Windows\CurrentVersion\Uninstall\{f3b3bd4d-e177-42a2-9c14-e6b419ca11a4}' -Name 'NoModify' -Type 'DWord' -Value '1'   
          }

    Invoke-ADTAllUsersRegistryAction -ScriptBlock {
    Set-ADTRegistryKey -Key 'HKCU\Software\Microsoft\Microsoft Power BI Desktop' -Name 'EnableCustomerExperienceProgram' -Type 'DWord' -Value '0' -SID $_.SID
           }



     ##Install OLEDB
    Start-ADTMsiProcess -Action 'Install' -FilePath "$($adtSession.DirFiles)\x64_17.0.219.0_SQL_AS_OLEDB.msi" -Transforms "$($adtSession.DirFiles)\1058_SQL_OLEDB_17.0.219.0_PKG_R1.Mst" -ArgumentList '/QN' -LogFileName "1058_SQL_OLEDB_17.0.219.0_PKG_R1"

     ##Install OLEDB
    Start-ADTMsiProcess -Action 'Install' -FilePath "$($adtSession.DirFiles)\PowerBIReportBuilder.msi" -Transforms "$($adtSession.DirFiles)\1058_PowerBiReportBuilder_15.7.1813.16_PKG_R1.Mst" -ArgumentList '/QN' -LogFileName "1058_PowerBiReportBuilder_15.7.1813.16_PKG_R1"



     ##Install DaxStudio_setup
    Start-ADTProcess -FilePath "$($adtSession.DirFiles)\DaxStudio_3_2_1_setup.exe" -ArgumentList "/LOADINF=""$($adtSession.DirFiles)\DaxStudio.inf"" /VERYSILENT /ALLUSERS /NORESTART" -WindowStyle 'Hidden'

        If (Test-Path "$envProgramFiles\DAX Studio\DaxStudio.exe"){
          Set-ADTRegistryKey -Key 'HKEY_LOCAL_MACHINE\SOFTWARE\Microsoft\Windows\CurrentVersion\Uninstall\{CE2CEA93-9DD3-4724-8FE3-FCBF0A0915C1}_is1' -Name 'NoRemove' -Type 'DWord' -Value '1'
          Set-ADTRegistryKey -Key 'HKEY_LOCAL_MACHINE\SOFTWARE\Microsoft\Windows\CurrentVersion\Uninstall\{CE2CEA93-9DD3-4724-8FE3-FCBF0A0915C1}_is1' -Name 'NoModify' -Type 'DWord' -Value '1'  
          }


     ##Install Tabular Editor
    Start-ADTMsiProcess -Action 'Install' -FilePath "$($adtSession.DirFiles)\TabularEditor.2.22.0.Installer.msi" -Transforms "$($adtSession.DirFiles)\1058_TabularEditor_2.22.0_PKG_R1.Mst" -ArgumentList '/QN' -LogFileName "1058_TabularEditor_2.22.0_PKG_R1"

        ##====================================================================================================================
        ##Coping user config files to each user
            $defusr = "$env:Systemdrive\Users\Default"
            $ProfilePaths = Get-ADTUserProfiles | Select-Object -ExpandProperty 'ProfilePath'
            ForEach ($Path in $ProfilePaths)
            {
                If($Path -ne $defusr){
                #copy config files
                $testPath = Test-Path "$Path\AppData\Local\Microsoft\Power BI Report Builder\15.7"
                if ($testpath)
                {
		            Copy-ADTFile -path "$($adtSession.DirFiles)\user.config" -Destination "$Path\AppData\Local\Microsoft\Power BI Report Builder\15.7\" -Recurse
                }
                else
                {
                    New-ADTFolder -Path "$Path\AppData\Local\Microsoft\Power BI Report Builder"
                    New-ADTFolder -Path "$Path\AppData\Local\Microsoft\Power BI Report Builder\15.7"
		            Copy-ADTFile -path "$($adtSession.DirFiles)\user.config" -Destination "$Path\AppData\Local\Microsoft\Power BI Report Builder\15.7\" -recurse
                }
 
                ##copy settings.xml
                $testPath1 = Test-Path "$Path\AppData\Local\Microsoft\Power BI Desktop"
                if ($testpath1)
                {
		            Copy-ADTFile -path "$($adtSession.DirFiles)\User.zip" -Destination "$Path\AppData\Local\Microsoft\Power BI Desktop\" -recurse
                }
                else
                {
                    New-ADTFolder -Path "$Path\AppData\Local\Microsoft\Power BI Desktop"
		            Copy-ADTFile -path "$($adtSession.DirFiles)\User.zip" -Destination "$Path\AppData\Local\Microsoft\Power BI Desktop\" -recurse -ErrorAction SilentlyContinue
                }

             }
            }



    ##================================================
    ## MARK: Post-Install
    ##================================================
    $adtSession.InstallPhase = "Post-$($adtSession.DeploymentType)"

    ## <Perform Post-Installation tasks here>

    ##Branding key:
    $AppExist = Get-ADTRegistryKey -Key "HKEY_LOCAL_MACHINE\SOFTWARE\Microsoft\Windows\CurrentVersion\Uninstall\{2445f577-1578-434b-bc21-ce16be98d610}" -Name "DisplayVersion"
    if ($AppExist -eq "2.138.1452.0") 
    {
        Branding-Key -Action "Create"
    }

}

function Uninstall-ADTDeployment
{
    ##================================================
    ## MARK: Pre-Uninstall
    ##================================================
    $adtSession.InstallPhase = "Pre-$($adtSession.DeploymentType)"
    
    ## <Perform Pre-Uninstallation tasks here>

    ##Close process silently if running:


     Show-ADTInstallationWelcome -CloseProcesses "PBIDesktop","PowerBIReportBuilder","DaxStudio","TabularEditor" -Silent


    ##================================================
    ## MARK: Uninstall
    ##================================================
    $adtSession.InstallPhase = $adtSession.DeploymentType

    ## Handle Zero-Config MSI uninstallations.
    if ($adtSession.UseDefaultMsi)
    {
        $ExecuteDefaultMSISplat = @{ Action = $adtSession.DeploymentType; FilePath = $adtSession.DefaultMsiFile }
        if ($adtSession.DefaultMstFile)
        {
            $ExecuteDefaultMSISplat.Add('Transform', $adtSession.DefaultMstFile)
        }
        Start-ADTMsiProcess @ExecuteDefaultMSISplat
    }

    ## <Perform Uninstallation tasks here>




	    ##<Perform Uninstallation of PowerBIDesktop>
		#==========================================================================================================================
        ##Microsoft Power BI Desktop (x64)
            if(Test-Path "HKLM:SOFTWARE\Microsoft\Windows\CurrentVersion\Uninstall\{2445f577-1578-434b-bc21-ce16be98d610}")
            {
                       Start-ADTMsiProcess -Action 'Uninstall' -ProductCode '{2445f577-1578-434b-bc21-ce16be98d610}' -ArgumentList '/QN'
          Remove-ADTRegistryKey -Key 'HKEY_LOCAL_MACHINE\SOFTWARE\Microsoft\Windows\CurrentVersion\Uninstall\{2445f577-1578-434b-bc21-ce16be98d610}' -Recurse                       
            }

            if (Test-Path -Path "$envProgramData\Package Cache\{f3b3bd4d-e177-42a2-9c14-e6b419ca11a4}\PBIDesktopSetup_x64.exe")
            {
                Start-ADTProcess -FilePath "$envProgramData\Package Cache\{f3b3bd4d-e177-42a2-9c14-e6b419ca11a4}\PBIDesktopSetup_x64.exe" -ArgumentList "/UNINSTALL /quiet /NORESTART" -WindowStyle 'Hidden'

            } 

        ##Microsoft Analysis Services OLE DB Provider
            if(Test-Path "HKLM:SOFTWARE\Microsoft\Windows\CurrentVersion\Uninstall\{492C3816-7F36-4F2B-8A6C-1D1DAED047E7}")
            {

                       Start-ADTMsiProcess -Action 'Uninstall' -ProductCode '{492C3816-7F36-4F2B-8A6C-1D1DAED047E7}' -ArgumentList '/QN'		                         
            }

        ##Power BI Report Builder
            if(Test-Path "HKLM:SOFTWARE\Microsoft\Windows\CurrentVersion\Uninstall\{C5C89CD5-A660-4447-82D9-76914DC76C90}")
            {
                      Start-ADTMsiProcess -Action 'Uninstall' -ProductCode '{C5C89CD5-A660-4447-82D9-76914DC76C90}' -ArgumentList '/QN'		                         
            }

        ##DAX Studio 3.1.2
            if (Test-Path -Path "$envProgramFiles\DAX Studio\unins000.exe")
            {
                Start-ADTProcess -FilePath "$envProgramFiles\DAX Studio\unins000.exe" -ArgumentList "/VERYSILENT" -WindowStyle 'Hidden'
            }
        
        ##Tabular Editor
            if(Test-Path "HKLM:SOFTWARE\WOW6432Node\Microsoft\Windows\CurrentVersion\Uninstall\{EACBA567-E11C-4CB7-8F6C-17036EB58B0E}")
            {
                      Start-ADTMsiProcess -Action 'Uninstall' -ProductCode '{EACBA567-E11C-4CB7-8F6C-17036EB58B0E}' -ArgumentList '/QN'
		                         
            } 
        start-sleep -seconds 30



    ##================================================
    ## MARK: Post-Uninstallation
    ##================================================
    $adtSession.InstallPhase = "Post-$($adtSession.DeploymentType)"

    ## <Perform Post-Uninstallation tasks here>


       ##<Remove user files/folders>
		#================================================================================================================================
        $ProfilePaths = Get-ADTUserProfiles | Select-Object -ExpandProperty 'ProfilePath'
        ForEach ($Path in $ProfilePaths)
        {
        $testPath = Test-Path "$Path\AppData\Local\Microsoft\Power BI Report Builder\15.7\user.config"
        if ($testpath)
         {
           Remove-Item -Path "$path\AppData\Local\Microsoft\Power BI Report Builder\15.7\user.config" -Force -Recurse -ErrorAction SilentlyContinue
         }
        }

        $ProfilePaths = Get-ADTUserProfiles | Select-Object -ExpandProperty 'ProfilePath'
        ForEach ($Path in $ProfilePaths)
        {
        $testPath = Test-Path "$Path\AppData\Local\Microsoft\Power BI Report Builder"
        if ($testpath)
         {
           Remove-ADTFolder -Path "$path\AppData\Local\Microsoft\Power BI Report Builder"
         }
        }

        $ProfilePaths = Get-ADTUserProfiles | Select-Object -ExpandProperty 'ProfilePath'
        ForEach ($Path in $ProfilePaths)
        {
        $testPath1 = Test-Path "$Path\AppData\Local\Microsoft\Power BI Desktop\User.zip"
        if ($testpath1)
         {
           Remove-Item -Path "$path\AppData\Local\Microsoft\Power BI Desktop\User.zip" -Force -Recurse -ErrorAction SilentlyContinue
         }
        }


        $ProfilePaths = Get-ADTUserProfiles | Select-Object -ExpandProperty 'ProfilePath'
        ForEach ($Path in $ProfilePaths)
        {
        $testPath1 = Test-Path "$path\AppData\Local\Microsoft\Power BI Desktop"
        if ($testpath1)
         {
           Remove-ADTFolder -Path "$path\AppData\Local\Microsoft\Power BI Desktop"
         }
        }

        $ProfilePaths = Get-ADTUserProfiles | Select-Object -ExpandProperty 'ProfilePath'
        ForEach ($Path in $ProfilePaths)
        {
        $testPath1 = Test-Path "$path\AppData\Local\DaxStudio"
        if ($testpath1)
         {
           Remove-ADTFolder -Path "$path\AppData\Local\DaxStudio"
         }
        }

        $ProfilePaths = Get-ADTUserProfiles | Select-Object -ExpandProperty 'ProfilePath'
        ForEach ($Path in $ProfilePaths)
        {
        $testPath1 = Test-Path "$path\AppData\Local\TabularEditor"
        if ($testpath1)
         {
           Remove-ADTFolder -Path "$path\AppData\Local\TabularEditor"
         }
        }

        $testPath1 = Test-Path "$envProgramData\Microsoft\Power BI Report Builder"
        if ($testpath1)
         {
           Remove-ADTFolder -Path "$envProgramData\Microsoft\Power BI Report Builder"
         }

    ##Removing branding key:
    $AppExist = Get-ADTRegistryKey -Key "HKEY_LOCAL_MACHINE\SOFTWARE\Microsoft\Windows\CurrentVersion\Uninstall\{2445f577-1578-434b-bc21-ce16be98d610}" -Name "DisplayVersion"
    if (!($AppExist -eq "2.138.1452.0")) 
    {
        Branding-Key -Action "Delete"
    }

}

function Repair-ADTDeployment
{
    ##================================================
    ## MARK: Pre-Repair
    ##================================================
    $adtSession.InstallPhase = "Pre-$($adtSession.DeploymentType)"

    ## Show Welcome Message, close Internet Explorer with a 60 second countdown before automatically closing.
    Show-ADTInstallationWelcome -CloseProcesses iexplore -CloseProcessesCountdown 60

    ## Show Progress Message (with the default message).
    Show-ADTInstallationProgress

    ## <Perform Pre-Repair tasks here>


    ##================================================
    ## MARK: Repair
    ##================================================
    $adtSession.InstallPhase = $adtSession.DeploymentType

    ## Handle Zero-Config MSI repairs.
    if ($adtSession.UseDefaultMsi)
    {
        $ExecuteDefaultMSISplat = @{ Action = $adtSession.DeploymentType; FilePath = $adtSession.DefaultMsiFile }
        if ($adtSession.DefaultMstFile)
        {
            $ExecuteDefaultMSISplat.Add('Transform', $adtSession.DefaultMstFile)
        }
        Start-ADTMsiProcess @ExecuteDefaultMSISplat
    }

    ## <Perform Repair tasks here>


    ##================================================
    ## MARK: Post-Repair
    ##================================================
    $adtSession.InstallPhase = "Post-$($adtSession.DeploymentType)"

    ## <Perform Post-Repair tasks here>
}


##================================================
## MARK: Initialization
##================================================

# Set strict error handling across entire operation.
$ErrorActionPreference = [System.Management.Automation.ActionPreference]::Stop
$ProgressPreference = [System.Management.Automation.ActionPreference]::SilentlyContinue
Set-StrictMode -Version 1

# Import the module and instantiate a new session.
try
{
    $moduleName = if ([System.IO.File]::Exists("$PSScriptRoot\PSAppDeployToolkit\PSAppDeployToolkit.psd1"))
    {
        Get-ChildItem -LiteralPath $PSScriptRoot\PSAppDeployToolkit -Recurse -File | Unblock-File -ErrorAction Ignore
        "$PSScriptRoot\PSAppDeployToolkit\PSAppDeployToolkit.psd1"
    }
    else
    {
        'PSAppDeployToolkit'
    }
    Import-Module -FullyQualifiedName @{ ModuleName = $moduleName; Guid = '8c3c366b-8606-4576-9f2d-4051144f7ca2'; ModuleVersion = '4.0.5' } -Force
    try
    {
        $iadtParams = Get-ADTBoundParametersAndDefaultValues -Invocation $MyInvocation
        $adtSession = Open-ADTSession -SessionState $ExecutionContext.SessionState @adtSession @iadtParams -PassThru
    }
    catch
    {
        Remove-Module -Name PSAppDeployToolkit* -Force
        throw
    }
}
catch
{
    $Host.UI.WriteErrorLine((Out-String -InputObject $_ -Width ([System.Int32]::MaxValue)))
    exit 60008
}


##================================================
## MARK: Invocation
##================================================

try
{
    Get-Item -Path $PSScriptRoot\PSAppDeployToolkit.* | & {
        process
        {
            Get-ChildItem -LiteralPath $_.FullName -Recurse -File | Unblock-File -ErrorAction Ignore
            Import-Module -Name $_.FullName -Force
        }
    }
    & "$($adtSession.DeploymentType)-ADTDeployment"
    Close-ADTSession
}
catch
{
    Write-ADTLogEntry -Message ($mainErrorMessage = Resolve-ADTErrorRecord -ErrorRecord $_) -Severity 3
    Show-ADTDialogBox -Text $mainErrorMessage -Icon Stop | Out-Null
    Close-ADTSession -ExitCode 60001
}
finally
{
    Remove-Module -Name PSAppDeployToolkit* -Force
}

