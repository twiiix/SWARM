##Miner Path Information
if($nvidia.'z-enemy'.path3){$Path = "$($nvidia.'z-enemy'.path3)"}
else{$Path = "None"}
if($nvidia.'z-enemy'.uri){$Uri = "$($nvidia.'z-enemy'.uri)"}
else{$Uri = "None"}
if($nvidia.'z-enemy'.MinerName){$MinerName = "$($nvidia.'z-enemy'.MinerName)"}
else{$MinerName = "None"}
if($Platform -eq "linux"){$Build = "Tar"}
elseif($Platform -eq "windows"){$Build = "Zip"}

$ConfigType = "NVIDIA3"

##Parse -GPUDevices
if($NVIDIADevices3 -ne ''){$Devices = $NVIDIADevices3}

##Get Configuration File
$GetConfig = "$dir\config\miners\z-enemy.json"
try{$Config = Get-Content $GetConfig | ConvertFrom-Json}
catch{Write-Warning "Warning: No config found at $GetConfig"}

##Export would be /path/to/[SWARMVERSION]/build/export##
$ExportDir = Join-Path $dir "build\export"

##Prestart actions before miner launch
$BE = "/usr/lib/x86_64-linux-gnu/libcurl-compat.so.3.0.0"
$Prestart = @()
if(Test-Path $BE){$Prestart += "export LD_PRELOAD=libcurl-compat.so.3.0.0"}
$PreStart += "export LD_LIBRARY_PATH=$ExportDir"
$Config.$ConfigType.prestart | foreach {$Prestart += "$($_)"}

##Build Miner Settings
if($CoinAlgo -eq $null)
{
  $Config.$ConfigType.commands | Get-Member -MemberType NoteProperty | Select-Object -ExpandProperty Name | ForEach-Object {
  $MinerAlgo = $_
  $AlgoPools | Where Symbol -eq $MinerAlgo | foreach {
  if($Algorithm -eq "$($_.Algorithm)")
  {
    if($Config.$ConfigType.difficulty.$($_.Algorithm)){$Diff=",d=$($Config.$ConfigType.difficulty.$($_.Algorithm))"}else{$Diff=""}
  [PSCustomObject]@{
    Delay = $Config.$ConfigType.delay
    Symbol = "$($_.Algorithm)"
  MinerName = $MinerName
  Prestart = $PreStart
  Type = $ConfigType
  Path = $Path
  Devices = $Devices
  DeviceCall = "ccminer"
  Arguments = "-a $($Config.$ConfigType.naming.$($_.Algorithm)) --no-nvml -o stratum+tcp://$($_.Host):$($_.Port) -b 0.0.0.0:4071 -u $($_.User3) -p $($_.Pass3)$($Diff) $($Config.$ConfigType.commands.$($_.Algorithm))"
  HashRates = [PSCustomObject]@{$($_.Algorithm) = $($Stats."$($Name)_$($_.Algorithm)_hashrate".Day)}
  Quote = if($($Stats."$($Name)_$($_.Algorithm)_hashrate".Day)){$($Stats."$($Name)_$($_.Algorithm)_hashrate".Day)*($_.Price)}else{0}
  PowerX = [PSCustomObject]@{$($_.Algorithm) = if($Watts.$($_.Algorithm)."$($ConfigType)_Watts"){$Watts.$($_.Algorithm)."$($ConfigType)_Watts"}elseif($Watts.default."$($ConfigType)_Watts"){$Watts.default."$($ConfigType)_Watts"}else{0}}
  ocpower = if($Config.$ConfigType.oc.$($_.Algorithm).power){$Config.$ConfigType.oc.$($_.Algorithm).power}else{$OC."default_$($ConfigType)".Power}
  occore = if($Config.$ConfigType.oc.$($_.Algorithm).core){$Config.$ConfigType.oc.$($_.Algorithm).core}else{$OC."default_$($ConfigType)".core}
  ocmem = if($Config.$ConfigType.oc.$($_.Algorithm).memory){$Config.$ConfigType.oc.$($_.Algorithm).memory}else{$OC."default_$($ConfigType)".memory}
  MinerPool = "$($_.Name)"
  FullName = "$($_.Mining)"
  Port = 4071
  API = "Ccminer"
  Wrap = $false
  URI = $Uri
  BUILD = $Build
  Algo = "$($_.Algorithm)"
  NewAlgo = ''
    }
   }
  }
 }
}