cd $PSScriptRoot

if ($args[1] -eq 'video')
{
	Write-Host '+==========================+'
	Write-Host '| Real-ESRGAN (Video Mode) |'
	Write-Host '+==========================+'
}
else
{
	Write-Host '+==========================+'
	Write-Host '| Real-ESRGAN (Image Mode) |'
	Write-Host '+==========================+'
}
cd .\Real-ESRGAN\

if ($args[0])
{
	$input = $args[0]
}
else
{
	$input = Read-Host -Prompt 'input (mandatory)'
}

[pscustomobject]@{'Input File/Folder' = $input} | Format-Table
# table
$table = @()
$table += [pscustomobject]@{Option = 'outscale'; Description = 'the final upsampling scale of the image, ie: 1,2 or 4'}
$table += [pscustomobject]@{Option = 'tile'; Description = 'tile size, 0 for no tile (fastest but require lots of VRAM for big image)'}
$table += [pscustomobject]@{Option = 'model_name'; Description = 'model name, see table below'}
$table | Format-Table

# table
$table = @()
$table += [pscustomobject]@{model_name = 'RealESRGAN_x4plus'; Description = 'x4, optimized for real life photo'}
$table += [pscustomobject]@{model_name = 'RealESRGAN_x2plus'; Description = 'x2, optimized for real life photo'}
$table += [pscustomobject]@{model_name = 'RealESRNet_x4plus'; Description = 'not ideal, feel free to try'}
$table += [pscustomobject]@{model_name = 'RealESRGAN_x4plus_anime_6B'; Description = 'optimized for anime images, small model size'}
$table += [pscustomobject]@{model_name = 'realesr-animevideov3'; Description = 'optimized for animation video'}
$table += [pscustomobject]@{model_name = 'realesr-general-x4v3'; Description = 'optimized for general scenes, tiny model size'}
$table | Format-Table

Write-Host 'Enter options value (leave empty for default)'
$outscale = Read-Host -Prompt 'outscale (default=4)'
$tile = Read-Host -Prompt 'tile (default=0)'
$model_name = Read-Host -Prompt 'model_name (default=RealESRGAN_x4plus)'
Write-Host ""

if ($outscale){ $options += " --outscale $outscale" }
if ($tile){ $options += " --tile $tile" }
if ($model_name){ $options += " --model_name $model_name" }

if ($args[1] -eq 'video')
{
	$env:Path += ";$PSScriptRoot\ffmpeg-master-latest-win64-gpl\bin"
	$ffmpeg_check = ffmpeg -version
	if ($ffmpeg_check)
	{
		Write-Host 'Converting input to mp4 ...'
		Invoke-Expression "ffmpeg -i '$input' -codec copy .\temp_esrgan_video.mp4"
		Invoke-Expression "python3 -u -W ignore .\inference_realesrgan_video.py --input '.\temp_esrgan_video.mp4' --face_enhance $options"
		#Invoke-Expression "python3 -u -W ignore .\inference_realesrgan_video.py --input '$input' --face_enhance $options"
	}
	else
	{
		Write-Host 'ffmpeg is not installed correctly!'
		pause
		exit
	}
	
}
else
{
	Invoke-Expression "python3 -u -W ignore .\inference_realesrgan.py --input '$input' --face_enhance $options"
}

$table = @()
$table += [pscustomobject]@{'Results Location' = "$PSScriptRoot\Real-ESRGAN\results"}
$table | Format-Table 

Invoke-Item "$PSScriptRoot\Real-ESRGAN\results"
Start-Sleep -Seconds 10
