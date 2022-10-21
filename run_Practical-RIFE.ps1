cd $PSScriptRoot

Write-Host '+================+'
Write-Host '| Practical-RIFE |'
Write-Host '+================+'

cd .\Practical-RIFE\
New-Item '.\results' -ItemType Directory -ea 0
# ffmpeg
$env:Path += ";$PSScriptRoot\ffmpeg-master-latest-win64-gpl\bin"

# Get model
python3 -c "import sys; from basicsr.utils.download_util import load_file_from_url; load_file_from_url(url='https://artificigenix.com/others/RIFE_trained_model_v4.6.zip', model_dir=r'.', progress=True, file_name='RIFE_trained_model_v4.6.zip')"
Expand-Archive '.\RIFE_trained_model_v4.6.zip' -DestinationPath '.\' -Force

if ($args[0])
{
	$video = $args[0]
}
else
{
	$video = Read-Host -Prompt 'video (mandatory)'
}
[pscustomobject]@{'Input Video File' = $video} | Format-Table

# table
$table = @()
$table += [pscustomobject]@{Option = 'multi'; Description = 'fps multiplier' }
$table += [pscustomobject]@{Option = 'scale'; Description = 'resolution for optical flow model, try scale=0.5 for 4k video'}
$table | Format-Table

Write-Host 'Enter options value (leave empty for default)'
$multi = Read-Host -Prompt 'multi (default=2)'
$scale = Read-Host -Prompt 'scale (default=1.0)'
Write-Host ""
$output = [System.IO.Path]::GetFileName($video)

if ($scale){ $options += " --scale=$scale" }
if ($multi){ $options += " --multi=$multi" }

Invoke-Expression "python3 -W ignore inference_video.py --video='$video' --fp16 --output='.\results\$output' --UHD $options"

[pscustomobject]@{'Results Location' = "$PSScriptRoot\Practical-RIFE\results"} | Format-Table

Invoke-Item "$PSScriptRoot\Practical-RIFE\results"
Start-Sleep -Seconds 10

