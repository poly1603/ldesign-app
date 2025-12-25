# Icon Migration Script
# This script replaces Material Icons with Lucide Icons

$iconMap = @{
    'Icons.add' = 'LucideIcons.plus'
    'Icons.add_rounded' = 'LucideIcons.plus'
    'Icons.edit' = 'LucideIcons.pencil'
    'Icons.edit_outlined' = 'LucideIcons.pencil'
    'Icons.delete' = 'LucideIcons.trash2'
    'Icons.delete_outline' = 'LucideIcons.trash2'
    'Icons.delete_outline_rounded' = 'LucideIcons.trash2'
    'Icons.save' = 'LucideIcons.save'
    'Icons.refresh' = 'LucideIcons.refreshCw'
    'Icons.refresh_rounded' = 'LucideIcons.refreshCw'
    'Icons.copy' = 'LucideIcons.copy'
    'Icons.copy_rounded' = 'LucideIcons.copy'
    'Icons.download' = 'LucideIcons.download'
    'Icons.upload' = 'LucideIcons.upload'
    'Icons.upload_file' = 'LucideIcons.upload'
    'Icons.arrow_back' = 'LucideIcons.arrowLeft'
    'Icons.arrow_forward' = 'LucideIcons.arrowRight'
    'Icons.close' = 'LucideIcons.x'
    'Icons.menu' = 'LucideIcons.menu'
    'Icons.chevron_right' = 'LucideIcons.chevronRight'
    'Icons.chevron_left' = 'LucideIcons.chevronLeft'
    'Icons.more_vert' = 'LucideIcons.moreVertical'
    'Icons.more_vert_rounded' = 'LucideIcons.moreVertical'
    'Icons.more_horiz' = 'LucideIcons.moreHorizontal'
    'Icons.check' = 'LucideIcons.check'
    'Icons.check_circle' = 'LucideIcons.checkCircle'
    'Icons.check_circle_outline' = 'LucideIcons.checkCircle'
    'Icons.check_circle_outline_rounded' = 'LucideIcons.checkCircle'
    'Icons.error' = 'LucideIcons.alertCircle'
    'Icons.error_outline' = 'LucideIcons.alertCircle'
    'Icons.warning' = 'LucideIcons.alertTriangle'
    'Icons.warning_outlined' = 'LucideIcons.alertTriangle'
    'Icons.info' = 'LucideIcons.info'
    'Icons.info_outline' = 'LucideIcons.info'
    'Icons.folder' = 'LucideIcons.folder'
    'Icons.folder_outlined' = 'LucideIcons.folder'
    'Icons.folder_open' = 'LucideIcons.folderOpen'
    'Icons.description' = 'LucideIcons.fileText'
    'Icons.description_outlined' = 'LucideIcons.fileText'
    'Icons.insert_drive_file' = 'LucideIcons.file'
    'Icons.code' = 'LucideIcons.code'
    'Icons.code_outlined' = 'LucideIcons.code2'
    'Icons.image' = 'LucideIcons.image'
    'Icons.image_outlined' = 'LucideIcons.image'
    'Icons.photo' = 'LucideIcons.image'
    'Icons.collections' = 'LucideIcons.images'
    'Icons.collections_outlined' = 'LucideIcons.images'
    'Icons.palette' = 'LucideIcons.palette'
    'Icons.photo_size_select_large' = 'LucideIcons.maximize2'
    'Icons.format_color_fill' = 'LucideIcons.paintBucket'
    'Icons.view_module' = 'LucideIcons.grid'
    'Icons.terminal' = 'LucideIcons.terminal'
    'Icons.bug_report' = 'LucideIcons.bug'
    'Icons.build' = 'LucideIcons.wrench'
    'Icons.build_circle' = 'LucideIcons.wrench'
    'Icons.settings' = 'LucideIcons.settings'
    'Icons.settings_outlined' = 'LucideIcons.settings'
    'Icons.source' = 'LucideIcons.gitBranch'
    'Icons.source_outlined' = 'LucideIcons.gitBranch'
    'Icons.cloud' = 'LucideIcons.cloud'
    'Icons.cloud_download' = 'LucideIcons.cloudDownload'
    'Icons.cloud_upload' = 'LucideIcons.cloudUpload'
    'Icons.link' = 'LucideIcons.link'
    'Icons.network_check' = 'LucideIcons.wifi'
    'Icons.network_check_rounded' = 'LucideIcons.wifi'
    'Icons.person' = 'LucideIcons.user'
    'Icons.person_rounded' = 'LucideIcons.user'
    'Icons.login' = 'LucideIcons.logIn'
    'Icons.login_rounded' = 'LucideIcons.logIn'
    'Icons.logout' = 'LucideIcons.logOut'
    'Icons.vpn_key' = 'LucideIcons.key'
    'Icons.vpn_key_rounded' = 'LucideIcons.key'
    'Icons.play_arrow' = 'LucideIcons.play'
    'Icons.play_arrow_rounded' = 'LucideIcons.play'
    'Icons.stop' = 'LucideIcons.square'
    'Icons.stop_rounded' = 'LucideIcons.square'
    'Icons.pause' = 'LucideIcons.pause'
    'Icons.search' = 'LucideIcons.search'
    'Icons.filter' = 'LucideIcons.filter'
    'Icons.sort' = 'LucideIcons.arrowUpDown'
    'Icons.clear' = 'LucideIcons.x'
    'Icons.inbox' = 'LucideIcons.inbox'
    'Icons.inbox_outlined' = 'LucideIcons.inbox'
    'Icons.inventory_2' = 'LucideIcons.package'
    'Icons.inventory_2_outlined' = 'LucideIcons.package'
    'Icons.dashboard' = 'LucideIcons.layoutDashboard'
    'Icons.dashboard_outlined' = 'LucideIcons.layoutDashboard'
    'Icons.text_fields' = 'LucideIcons.type'
    'Icons.text_fields_outlined' = 'LucideIcons.type'
    'Icons.add_to_photos' = 'LucideIcons.folderPlus'
    'Icons.storage' = 'LucideIcons.database'
    'Icons.storage_rounded' = 'LucideIcons.database'
    'Icons.memory' = 'LucideIcons.cpu'
    'Icons.memory_rounded' = 'LucideIcons.cpu'
    'Icons.touch_app' = 'LucideIcons.hand'
    'Icons.touch_app_rounded' = 'LucideIcons.hand'
    'Icons.swap_horiz' = 'LucideIcons.repeat'
    'Icons.access_time' = 'LucideIcons.clock'
    'Icons.label' = 'LucideIcons.tag'
    'Icons.public' = 'LucideIcons.globe'
    'Icons.public_rounded' = 'LucideIcons.globe'
    'Icons.computer' = 'LucideIcons.monitor'
    'Icons.computer_rounded' = 'LucideIcons.monitor'
}

# Get all Dart files
$files = Get-ChildItem -Path "lib" -Filter "*.dart" -Recurse

foreach ($file in $files) {
    Write-Host "Processing: $($file.FullName)"
    
    $content = Get-Content $file.FullName -Raw
    $modified = $false
    
    # Check if file needs lucide_icons import
    $needsImport = $false
    
    foreach ($key in $iconMap.Keys) {
        if ($content -match [regex]::Escape($key)) {
            $content = $content -replace [regex]::Escape($key), $iconMap[$key]
            $modified = $true
            $needsImport = $true
        }
    }
    
    # Add import if needed and not already present
    if ($needsImport -and $content -notmatch "import 'package:lucide_icons/lucide_icons.dart';") {
        # Find the last import statement
        $lines = $content -split "`n"
        $lastImportIndex = -1
        
        for ($i = 0; $i < $lines.Count; $i++) {
            if ($lines[$i] -match "^import ") {
                $lastImportIndex = $i
            }
        }
        
        if ($lastImportIndex -ge 0) {
            $lines = $lines[0..$lastImportIndex] + "import 'package:lucide_icons/lucide_icons.dart';" + $lines[($lastImportIndex + 1)..($lines.Count - 1)]
            $content = $lines -join "`n"
        }
    }
    
    if ($modified) {
        Set-Content $file.FullName -Value $content -NoNewline
        Write-Host "  Updated!" -ForegroundColor Green
    }
}

Write-Host "`nMigration complete!" -ForegroundColor Green
Write-Host "Run 'flutter analyze' to check for any issues."
