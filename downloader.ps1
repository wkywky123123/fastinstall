# downloader.ps1 - PowerShell Advanced Downloader Script

# --- 接收来自批处理脚本的参数 ---
param(
    [string]$SourceURL,
    [string]$DestinationPath
)

# --- 下载逻辑 ---
try {
    # 创建一个新的 WebClient 对象用于下载
    $webClient = New-Object System.Net.WebClient

    # 初始化用于计算速度的变量
    $startTime = Get-Date
    $lastBytes = 0
    $downloadSpeed = 0

    # 注册一个事件处理器，在下载进度更新时触发
    Register-ObjectEvent -InputObject $webClient -EventName DownloadProgressChanged -Action {
        # 计算下载速度 (Bytes per second)
        $elapsedTime = (Get-Date) - $startTime
        if ($elapsedTime.TotalSeconds -gt 0) {
            # 计算自上次更新以来的速度
            $currentSpeed = ($EventArgs.BytesReceived - $lastBytes) / $elapsedTime.TotalSeconds
            # 平滑速度，避免剧烈波动
            if ($downloadSpeed -eq 0) { $downloadSpeed = $currentSpeed } else { $downloadSpeed = ($downloadSpeed * 0.7) + ($currentSpeed * 0.3) }
            $lastBytes = $EventArgs.BytesReceived
            $startTime = Get-Date
        }

        # 格式化单位以便阅读 (KB/s or MB/s)
        if ($downloadSpeed -gt 1MB) {
            $speedString = "{0:N2} MB/s" -f ($downloadSpeed / 1MB)
        } else {
            $speedString = "{0:N0} KB/s" -f ($downloadSpeed / 1KB)
        }

        # 格式化文件大小
        $receivedSize = "{0:N2} MB" -f ($EventArgs.BytesReceived / 1MB)
        $totalSize = "{0:N2} MB" -f ($EventArgs.TotalBytesToReceive / 1MB)

        # 使用 Write-Progress 在控制台中显示一个美观的进度条
        Write-Progress -Activity "正在下载文件..."-Status "$($speedString)  |  $($receivedSize) / $($totalSize)" -PercentComplete $EventArgs.ProgressPercentage -Id 1 
    }

    # 以异步方式开始下载文件
    # 这允许我们的进度条在下载进行时持续更新
    $webClient.DownloadFileAsync($SourceURL, $DestinationPath)

    # 循环等待，直到下载完成
    while ($webClient.IsBusy) {
        Start-Sleep -Milliseconds 100
    }

    # 下载完成后，确保进度条显示100%并关闭
    Write-Progress -Activity "下载完成！" -Status "文件已成功保存。" -Completed -Id 1
    
    # 释放资源
    $webClient.Dispose()

} catch {
    # 如果发生错误（如网络中断、URL无效），则捕获并显示错误信息
    Write-Host "下载过程中发生错误: $($_.Exception.Message)" -ForegroundColor Red
    # 退出并返回一个错误代码，让批处理脚本知道失败了
    exit 1
}

# 成功完成，返回代码0
exit 0