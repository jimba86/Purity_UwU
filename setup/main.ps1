# Self-elevate the script if required
if (-Not ([Security.Principal.WindowsPrincipal] [Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole([Security.Principal.WindowsBuiltInRole] 'Administrator')) {
 if ([int](Get-CimInstance -Class Win32_OperatingSystem | Select-Object -ExpandProperty BuildNumber) -ge 6000) {
  $CommandLine = "-File `"" + $MyInvocation.MyCommand.Path + "`" " + $MyInvocation.UnboundArguments
  Start-Process -FilePath PowerShell.exe -Verb Runas -ArgumentList $CommandLine
  Exit
 }
}
# important
cd $PSScriptRoot
cd ../
$currentloc = Get-Location
$currentloc

# message function
Function Output-Msg {
	Param ([string]$primary,[string]$secondary)
	Process {
		$a = @()
		$a += [pscustomobject]@{Component = $primary; Status = $secondary}
		$a | Format-Table @{
            Label = "Component"
            Expression =
            {
                $color = "36" #cyan
                $e = [char]27
                "$e[${color}m$($_.Component)${e}[0m"
            }
        }, @{
            Label = "Status"
            Expression =
            {
                if ("Installing" -eq $_.Status)
                {
                    $color = "33" #yellow
                }
                elseif ("Success" -eq $_.Status)
                {
                    $color = "32" #green
                }
				else
				{
					$color = "31" #red
				}
                $e = [char]27
                "$e[${color}m$($_.Status)${e}[0m"
            }
        }
	}
}

#Write-Host 'Removing old Windows Explorer context menu ...'
#Remove-Item -LiteralPath HKLM:\SOFTWARE\Classes\*\shell\run_Real-ESRGAN_image -Force -Recurse
#Remove-Item -LiteralPath HKLM:\SOFTWARE\Classes\*\shell\run_Real-ESRGAN_video -Force -Recurse
#Remove-Item -LiteralPath HKLM:\SOFTWARE\Classes\*\shell\run_Practical-RIFE -Force -Recurse
#Remove-Item -LiteralPath HKLM:\SOFTWARE\Classes\*\shell\run_Stable-Diffusion_image -Force -Recurse
#Remove-Item -LiteralPath HKLM:\SOFTWARE\Classes\*\shell\run_Stable-Diffusion_prompt-only -Force -Recurse

taskkill /f /im "python3.10.exe"
# PyTorch-CUDA
try {
	Output-Msg -primary 'PyTorch-1.12.1+cu116 ' -secondary 'Installing'
	python3 -m pip install --upgrade pip
	#pip3 uninstall torch torchvision torchaudio
	pip3 install torch torchvision torchaudio basicsr --force-reinstall --extra-index-url https://download.pytorch.org/whl/cu116 
	python3 ./setup/check_gpu.py
	Output-Msg -primary 'PyTorch-1.12.1+cu116 ' -secondary 'Success'
}
catch {
	Output-Msg -primary 'PyTorch-1.12.1+cu116 ' -secondary 'Failure'
}

Write-Host "Do you want to install " -f green -nonewline; Write-Host "Real-ESRGAN " -f blue -nonewline; Write-Host "?"
$choices  = '&Yes', '&No'
$decision = $Host.UI.PromptForChoice('', '', $choices, 1)
if ($decision -eq 0) {
    # Real-ESRGAN
	try {
		Output-Msg -primary 'Real-ESRGAN ' -secondary 'Installing'
		git clone https://github.com/xinntao/Real-ESRGAN
		pip3 install ./Real-ESRGAN 
		pip3 install -r ./Real-ESRGAN/requirements.txt
		
		New-Item -Path HKLM:\SOFTWARE\Classes\*\shell\run_Real-ESRGAN_image
		New-Item -Path HKLM:\SOFTWARE\Classes\*\shell\run_Real-ESRGAN_image\command
		Set-Item -LiteralPath HKLM:\SOFTWARE\Classes\*\shell\run_Real-ESRGAN_image\command -Value "powershell -File `"$currentloc\run_Real-ESRGAN.ps1`" `"%1`""

		New-Item -Path HKLM:\SOFTWARE\Classes\*\shell\run_Real-ESRGAN_video
		New-Item -Path HKLM:\SOFTWARE\Classes\*\shell\run_Real-ESRGAN_video\command
		Set-Item -LiteralPath HKLM:\SOFTWARE\Classes\*\shell\run_Real-ESRGAN_video\command -Value "powershell -File `"$currentloc\run_Real-ESRGAN.ps1`" `"%1`" `"video`""
		
		Output-Msg -primary 'Real-ESRGAN ' -secondary 'Success'
	}
	catch {
		Output-Msg -primary 'Real-ESRGAN ' -secondary 'Failure'
	}

	# Installing ffmpeg
	try {
		Output-Msg -primary 'ffmpeg ' -secondary 'Installing'
		pip3 install basicsr --quiet
		New-Item '.\setup' -ItemType Directory -ea 0
		python3 -c "import sys; from basicsr.utils.download_util import load_file_from_url; load_file_from_url(url='https://github.com/BtbN/FFmpeg-Builds/releases/download/latest/ffmpeg-master-latest-win64-gpl.zip', model_dir=r'.\setup', progress=True, file_name='ffmpeg-master-latest-win64-gpl.zip')"
	
		Write-Host 'Extracting ffmpeg-master-latest-win64-gpl.zip ...' -f green
		Expand-Archive '.\setup\ffmpeg-master-latest-win64-gpl.zip' -DestinationPath '.\' -Force
	
		Output-Msg -primary 'ffmpeg ' -secondary 'Success'
	}
	catch {
		Output-Msg -primary 'ffmpeg ' -secondary 'Failure'
	}
} else {
    Output-Msg -primary 'Real-ESRGAN ' -secondary 'Skipped'
}


Write-Host "Do you want to install " -f green -nonewline; Write-Host "Practical-RIFE " -f blue -nonewline; Write-Host "?"
$choices  = '&Yes', '&No'
$decision = $Host.UI.PromptForChoice('', '', $choices, 1)
if ($decision -eq 0) {
	# Practical-RIFE
	try {
		Output-Msg -primary 'Practical-RIFE ' -secondary 'Installing'
		git clone https://github.com/hzwer/Practical-RIFE
		pip3 install -r ./Practical-RIFE/requirements.txt 
		
		New-Item -Path HKLM:\SOFTWARE\Classes\*\shell\run_Practical-RIFE
		New-Item -Path HKLM:\SOFTWARE\Classes\*\shell\run_Practical-RIFE\command
		Set-Item -LiteralPath HKLM:\SOFTWARE\Classes\*\shell\run_Practical-RIFE\command -Value "powershell -File `"$currentloc\run_Practical-RIFE.ps1`" `"%1`""
		
		Output-Msg -primary 'Practical-RIFE ' -secondary 'Success'
	}
	catch {
		Output-Msg -primary 'Practical-RIFE ' -secondary 'Failure'
	}
} else {
    Output-Msg -primary 'Practical-RIFE ' -secondary 'Skipped'
}

Write-Host "Do you want to install " -f green -nonewline; Write-Host "Stable-Diffusion " -f blue -nonewline; Write-Host "?"

$choices  = '&Yes', '&No'
$decision = $Host.UI.PromptForChoice('', '', $choices, 1)
if ($decision -eq 0) {
# Stable-Diffusion
	try {
		Output-Msg -primary 'Stable-Diffusion ' -secondary 'Installing'
		git clone https://github.com/CompVis/stable-diffusion
		#pip3 install -r ./stable-diffusion/requirements.txt 
		pip3 install taming-transformers-rom1504 transformers==4.19.2 diffusers invisible-watermark 

		# create 3 empty __init__.py inside ldm
		Copy-Item './setup/__init__.py' -Destination './stable-diffusion/ldm/__init__.py' -Force
		Copy-Item './setup/__init__.py' -Destination './stable-diffusion/ldm/models/__init__.py' -Force
		Copy-Item './setup/__init__.py' -Destination './stable-diffusion/ldm/modules/__init__.py' -Force
		Copy-Item './setup/txt2img_nsfw.py' -Destination './stable-diffusion/scripts/txt2img_nsfw.py' -Force

		# patch pytorch SIGKILL to SIGINT
		Write-Host 'Patching PyTorch SIGNIT ...' -f green
		#$var = pip show torch | Select-String -Pattern "Location:" -SimpleMatch
		$var = pip3 list -v | Select-String -Pattern "\btorch\b"		
		$new_array = $var -split "\s+"
		$patch_file = $new_array[2] +'\torch\distributed\elastic\timer\file_based_local_timer.py'
		Write-Host $patch_file
		Copy-Item ./setup/file_based_local_timer.py -Destination $patch_file -force
		pip3 install ./stable-diffusion

		New-Item -Path HKLM:\SOFTWARE\Classes\*\shell\run_Stable-Diffusion_image
		New-Item -Path HKLM:\SOFTWARE\Classes\*\shell\run_Stable-Diffusion_image\command
		Set-Item -LiteralPath HKLM:\SOFTWARE\Classes\*\shell\run_Stable-Diffusion_image\command -Value "powershell -File `"$currentloc\run_Stable-Diffusion.ps1`" `"%1`""

		New-Item -Path HKLM:\SOFTWARE\Classes\*\shell\run_Stable-Diffusion_prompt-only
		New-Item -Path HKLM:\SOFTWARE\Classes\*\shell\run_Stable-Diffusion_prompt-only\command
		Set-Item -LiteralPath HKLM:\SOFTWARE\Classes\*\shell\run_Stable-Diffusion_prompt-only\command -Value "powershell -File `"$currentloc\run_Stable-Diffusion.ps1`""

		Output-Msg -primary 'Stable-Diffusion ' -secondary 'Success'

	} catch {
		Output-Msg -primary 'Stable-Diffusion ' -secondary 'Failure'
	}
} else {
    Output-Msg -primary 'Stable-Diffusion ' -secondary 'Skipped'
}

pause


