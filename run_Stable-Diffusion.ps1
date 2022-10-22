cd $PSScriptRoot

if ($args[0])
{
	Write-Host '+===================================+'
	Write-Host '| Stable-Diffusion (Image-To-Image) |'
	Write-Host '+===================================+'
}
else
{
	Write-Host '+===============================================+'
	Write-Host '| Stable-Diffusion (Prompt-Only, Text-To-Image) |'
	Write-Host '+===============================================+'
}

cd .\stable-diffusion\

 
# table
$table = @()
$table += [pscustomobject]@{Option = 'prompt'; Description = 'the prompt to render'}
$table += [pscustomobject]@{Option = 'strength'; Description = "strength for noising/unnoising. 1.0 corresponds to full destruction of information in init image"}
$table += [pscustomobject]@{Option = 'ddim_steps'; Description = 'number of ddim sampling steps'}
$table += [pscustomobject]@{Option = 'ddim_eta'; Description = 'ddim eta (eta=0.0 corresponds to deterministic sampling)'}
$table += [pscustomobject]@{Option = 'H'; Description = 'image height, in pixel space'}
$table += [pscustomobject]@{Option = 'W'; Description = "image width, in pixel space"}
$table += [pscustomobject]@{Option = 'C'; Description = 'latent channels'}
$table += [pscustomobject]@{Option = 'n_iter'; Description = "sample this often"}
$table += [pscustomobject]@{Option = 'n_samples'; Description = "how many samples to produce for each given prompt. A.k.a. batch size"}
$table += [pscustomobject]@{Option = 'f'; Description = "downsampling factor"}
$table += [pscustomobject]@{Option = 'scale'; Description = "unconditional guidance scale: eps = eps(x, empty) + scale * (eps(x, cond) - eps(x, empty))"}
$table += [pscustomobject]@{Option = 'seed'; Description = "the seed (for reproducible sampling)"}
$table | Format-Table

# table
$table = @()
$table += [pscustomobject]@{model_name = 'default'; Description = 'Default Stable-Diffusion model'}
$table += [pscustomobject]@{model_name = 'arcane_style'; Description = 'Fine-tuned Stable Diffusion model trained on images from the TV Show Arcane'}
$table += [pscustomobject]@{model_name = 'spider-verse_style'; Description = 'Fine-tuned Stable Diffusion model trained on movie stills from Sony Into the Spider-Verse'}
$table += [pscustomobject]@{model_name = 'elden-ring_style'; Description = 'Fine-tuned Stable Diffusion model trained on the game art from Elden Ring'}
$table += [pscustomobject]@{model_name = 'archer_style'; Description = 'Fine-tuned Stable Diffusion model trained on screenshots from the TV-show Archer'}
$table | Format-Table

Write-Host 'Enter options value (leave empty for default)'
$model_name = Read-Host -Prompt 'model_name (default=default)'
$prompt = Read-Host -Prompt 'prompt (mandatory)'
$ddim_steps = Read-Host -Prompt 'ddim_steps (default=50)'
$ddim_eta = Read-Host -Prompt 'ddim_eta (default=2)'
$H = Read-Host -Prompt 'H (default=512)'
$W = Read-Host -Prompt 'W (default=512)'
$C = Read-Host -Prompt 'C (default=4)'
$n_iter = Read-Host -Prompt 'n_iter (default=2)'
$n_samples = Read-Host -Prompt 'n_samples (default=3)'
$f = Read-Host -Prompt 'f (default=8)'
$scale = Read-Host -Prompt 'scale (default=7.5)'
$seed = Read-Host -Prompt 'seed (default=42)'
Write-Host ""

if ($model_name -eq 'arcane_style') 
{
	New-Item '.\models\ldm\nitrosocke' -ItemType Directory -ea 0
	python3 -c "import sys; from basicsr.utils.download_util import load_file_from_url; load_file_from_url(url='https://artificigenix.com/others/arcane-diffusion-v2.ckpt', model_dir=r'.\models\ldm\nitrosocke', progress=True, file_name='arcane-diffusion-v2.ckpt')"
	$ckpt = 'models\ldm\nitrosocke\arcane-diffusion-v2.ckpt'
	Write-Host "Using $model_name model"	
}
elseif ($model_name -eq 'spider-verse_style') 
{
	
	New-Item '.\models\ldm\nitrosocke' -ItemType Directory -ea 0
	python3 -c "import sys; from basicsr.utils.download_util import load_file_from_url; load_file_from_url(url='https://artificigenix.com/others/spiderverse-v1-pruned.ckpt', model_dir=r'.\models\ldm\nitrosocke', progress=True, file_name='spiderverse-v1-pruned.ckpt')"
	$ckpt = 'models\ldm\nitrosocke\spiderverse-v1-pruned.ckpt'
	Write-Host "Using $model_name model"	
}
elseif ($model_name -eq 'archer_style') 
{
	New-Item '.\models\ldm\nitrosocke' -ItemType Directory -ea 0
	python3 -c "import sys; from basicsr.utils.download_util import load_file_from_url; load_file_from_url(url='https://artificigenix.com/others/archer-v1.ckpt', model_dir=r'.\models\ldm\nitrosocke', progress=True, file_name='archer-v1.ckpt')"
	$ckpt = 'models\ldm\nitrosocke\archer-v1.ckpt'
	Write-Host "Using $model_name model"
}
elseif ($model_name -eq 'elden-ring_style') 
{
	New-Item '.\models\ldm\nitrosocke' -ItemType Directory -ea 0
	python3 -c "import sys; from basicsr.utils.download_util import load_file_from_url; load_file_from_url(url='https://artificigenix.com/others/eldenring-v1-pruned.ckpt', model_dir=r'.\models\ldm\nitrosocke', progress=True, file_name='eldenring-v1-pruned.ckpt')"
	$ckpt = 'models\ldm\nitrosocke\eldenring-v1-pruned.ckpt'
	Write-Host "Using $model_name model"
}
else
{
	New-Item '.\models\ldm\stable-diffusion-v1' -ItemType Directory -ea 0
	python3 -c "import sys; from basicsr.utils.download_util import load_file_from_url; load_file_from_url(url='https://artificigenix.com/others/sd-v1-4.ckpt', model_dir=r'.\models\ldm\stable-diffusion-v1', progress=True, file_name='model.ckpt')"
	Write-Host 'Using default model'
}

if ($ddim_steps){ $options += " --ddim_steps $ddim_steps" }
if ($ddim_eta){ $options += " --ddim_eta $ddim_eta" }
if ($H){ $options += " --H $H" }
if ($W){ $options += " --W $W" }
if ($C){ $options += " --C $C" }
if ($n_iter){ $options += " --n_iter $n_iter" }
if ($n_samples){ $options += " --n_samples $n_samples" }
if ($f){ $options += " --f $f" }
if ($scale){ $options += " --scale $scale" }
if ($seed){ $options += " --seed $seed" }

if ($ckpt)
{
	$options += " --prompt '$prompt' --ckpt '$ckpt'"
}
else
{
	$options += " --prompt '$prompt'"
}

if ($args[0])
{
	$input_image = $args[0]
	$options += " --init-img $input_image"
	[pscustomobject]@{'init-img' = $input_image} | Format-Table
	$strength = Read-Host -Prompt 'strength (default=0.75)'
	if ($seed){ $options += " --strength $strength" }
	Invoke-Expression "python3 -W ignore scripts/img2img.py $options"
	[pscustomobject]@{'Results Location' = "$PSScriptRoot\stable-diffusion\outputs\img2img-samples"} | Format-Table 
	Invoke-Item "$PSScriptRoot\stable-diffusion\outputs\img2img-samples"
}
else {
	Invoke-Expression "python3 -W ignore scripts/txt2img_nsfw.py $options"
	[pscustomobject]@{'Results Location' = "$PSScriptRoot\stable-diffusion\outputs\txt2img-samples"} | Format-Table 
	Invoke-Item "$PSScriptRoot\stable-diffusion\outputs\txt2img-samples"
}

Start-Sleep -Seconds 10

