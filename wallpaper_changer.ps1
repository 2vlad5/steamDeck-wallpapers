# SetWallpaper.ps1
# Скрипт для автоматической смены обоев по датам

$ScriptDir = $PSScriptRoot
$BackgroundFile = "$ScriptDir\background.jpg"
$RegKey = "HKCU:\Control Panel\Desktop"
$WallpaperValue = "Wallpaper"

# Список диапазонов дат и соответствующих обоев
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
    # Добавьте другие диапазоны по аналогии
)

# Получаем текущую дату
$Today = Get-Date

# Получаем текущий путь к обоинам из реестра
$CurrentWallpaper = Get-ItemProperty -Path $RegKey -Name $WallpaperValue -ErrorAction SilentlyContinue | Select-Object -ExpandProperty $WallpaperValue

# Функция: установить обои
function Set-Wallpaper($Path) {
    if (Test-Path $Path) {
        Set-ItemProperty -Path $RegKey -Name $WallpaperValue -Value $Path
        rundll32.exe user32.dll, UpdatePerUserSystemParameters
        Write-Host "Обои установлены: $Path"
    } else {
        Write-Host "Файл обоев не найден: $Path"
    }
}

# Проверяем, попадает ли сегодняшняя дата в какой-либо диапазон
$TargetWallpaper = $null
foreach ($range in $DateRanges) {
    if ($Today -ge $range.Start -and $Today -le $range.End) {
        $TargetWallpaper = $range.File
        break
    }
}

# Если дата не попала ни в один диапазон — используем background.jpg
if (-not $TargetWallpaper) {
    $TargetWallpaper = $BackgroundFile
}

# Проверяем, установлены ли сейчас нужные обои
if ($CurrentWallpaper -eq $TargetWallpaper) {
    Write-Host "Обои уже установлены корректно. Ничего не делаем."
    exit
}

# Если текущие обои не в списке разрешённых — удаляем скрипт и обои
$AllowedFiles = $DateRanges | ForEach-Object { $_.File }
$AllowedFiles += $BackgroundFile

if ($CurrentWallpaper -and $CurrentWallpaper -notin $AllowedFiles) {
    Write-Host "Текущие обои не разрешены. Удаляем скрипт и обои..."

    # Удаляем все jpg/jpeg в папке скрипта
    Get-ChildItem $ScriptDir -Filter *.jpg -Recurse | Remove-Item -Force
    Get-ChildItem $ScriptDir -Filter *.jpeg -Recurse | Remove-Item -Force

    # Удаляем сам скрипт
    Remove-Item "$ScriptDir\SetWallpaper.ps1" -Force

    exit
}

# Устанавливаем новые обои
Set-Wallpaper $TargetWallpaper
