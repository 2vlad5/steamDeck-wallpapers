# SetWallpaper.ps1
# Ñêðèïò äëÿ àâòîìàòè÷åñêîé ñìåíû îáîåâ ïî äàòàì

$ScriptDir = $PSScriptRoot
$BackgroundFile = "$ScriptDir\background.jpg"
$RegKey = "HKCU:\Control Panel\Desktop"
$WallpaperValue = "Wallpaper"

# Ñïèñîê äèàïàçîíîâ äàò è ñîîòâåòñòâóþùèõ îáîåâ
$DateRanges = @(
    @{
        Start = [DateTime]"2025-12-25"
        End   = [DateTime]"2026-01-08"
        File  = "$ScriptDir\christmas.jpg"
    },
    @{
        Start = [DateTime]"2026-02-14"
        End   = [DateTime]"2026-02-15"
        File  = "$ScriptDir\valentines.jpg"
    }
    # Äîáàâüòå äðóãèå äèàïàçîíû ïî àíàëîãèè
)

# Ïîëó÷àåì òåêóùóþ äàòó
$Today = Get-Date

# Ïîëó÷àåì òåêóùèé ïóòü ê îáîèíàì èç ðååñòðà
$CurrentWallpaper = Get-ItemProperty -Path $RegKey -Name $WallpaperValue -ErrorAction SilentlyContinue | Select-Object -ExpandProperty $WallpaperValue

# Ôóíêöèÿ: óñòàíîâèòü îáîè
function Set-Wallpaper($Path) {
    if (Test-Path $Path) {
        Set-ItemProperty -Path $RegKey -Name $WallpaperValue -Value $Path
        rundll32.exe user32.dll, UpdatePerUserSystemParameters
        Write-Host "Îáîè óñòàíîâëåíû: $Path"
    } else {
        Write-Host "Ôàéë îáîåâ íå íàéäåí: $Path"
    }
}

# Ïðîâåðÿåì, ïîïàäàåò ëè ñåãîäíÿøíÿÿ äàòà â êàêîé-ëèáî äèàïàçîí
$TargetWallpaper = $null
foreach ($range in $DateRanges) {
    if ($Today -ge $range.Start -and $Today -le $range.End) {
        $TargetWallpaper = $range.File
        break
    }
}

# Åñëè äàòà íå ïîïàëà íè â îäèí äèàïàçîí — èñïîëüçóåì background.jpg
if (-not $TargetWallpaper) {
    $TargetWallpaper = $BackgroundFile
}

# Ïðîâåðÿåì, óñòàíîâëåíû ëè ñåé÷àñ íóæíûå îáîè
if ($CurrentWallpaper -eq $TargetWallpaper) {
    Write-Host "Îáîè óæå óñòàíîâëåíû êîððåêòíî. Íè÷åãî íå äåëàåì."
    exit
}

# Åñëè òåêóùèå îáîè íå â ñïèñêå ðàçðåø¸ííûõ — óäàëÿåì ñêðèïò è îáîè
$AllowedFiles = $DateRanges | ForEach-Object { $_.File }
$AllowedFiles += $BackgroundFile

if ($CurrentWallpaper -and $CurrentWallpaper -notin $AllowedFiles) {
    Write-Host "Òåêóùèå îáîè íå ðàçðåøåíû. Óäàëÿåì ñêðèïò è îáîè..."

    # Óäàëÿåì âñå jpg/jpeg â ïàïêå ñêðèïòà
    Get-ChildItem $ScriptDir -Filter *.jpg -Recurse | Remove-Item -Force
    Get-ChildItem $ScriptDir -Filter *.jpeg -Recurse | Remove-Item -Force

    # Óäàëÿåì ñàì ñêðèïò
    Remove-Item "$ScriptDir\SetWallpaper.ps1" -Force

    exit
}

# Óñòàíàâëèâàåì íîâûå îáîè
Set-Wallpaper $TargetWallpaper
