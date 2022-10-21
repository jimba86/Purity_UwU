#system table
$cpuname = Get-WmiObject -Class Win32_Processor -ComputerName. | Select-Object -ExpandProperty 'Name'
$cpuram = "$([int]((Get-WmiObject -Class Win32_ComputerSystem -ComputerName. | Select-Object -ExpandProperty 'TotalPhysicalMemory') / 1024 / 1024)) MiB"
$gpuname = (nvidia-smi --format=noheader,csv --query-gpu=name)
$gpuram = (nvidia-smi --format=noheader,csv --query-gpu=memory.total)
$osname = Get-WmiObject -Class Win32_OperatingSystem -ComputerName. | Select-Object -ExpandProperty 'Caption'
$osversion = Get-WmiObject -Class Win32_OperatingSystem -ComputerName. | Select-Object -ExpandProperty 'Version'
$python = python3 --version
$pytorch = "PyTorch $(python3 -c 'import torch;print(torch.__version__)')"

$table = @()
$table += [pscustomobject]@{Name = $cpuname; Description = $cpuram }
$table += [pscustomobject]@{Name = $gpuname; Description = $gpuram}
$table += [pscustomobject]@{Name = $osname; Description = $osversion}
$table += [pscustomobject]@{Name = $python; Description = $pytorch }
$table | Format-Table