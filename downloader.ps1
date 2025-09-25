# downloader.ps1 - PowerShell Advanced Downloader Script

# --- ��������������ű��Ĳ��� ---
param(
    [string]$SourceURL,
    [string]$DestinationPath
)

# --- �����߼� ---
try {
    # ����һ���µ� WebClient ������������
    $webClient = New-Object System.Net.WebClient

    # ��ʼ�����ڼ����ٶȵı���
    $startTime = Get-Date
    $lastBytes = 0
    $downloadSpeed = 0

    # ע��һ���¼��������������ؽ��ȸ���ʱ����
    Register-ObjectEvent -InputObject $webClient -EventName DownloadProgressChanged -Action {
        # ���������ٶ� (Bytes per second)
        $elapsedTime = (Get-Date) - $startTime
        if ($elapsedTime.TotalSeconds -gt 0) {
            # �������ϴθ����������ٶ�
            $currentSpeed = ($EventArgs.BytesReceived - $lastBytes) / $elapsedTime.TotalSeconds
            # ƽ���ٶȣ�������Ҳ���
            if ($downloadSpeed -eq 0) { $downloadSpeed = $currentSpeed } else { $downloadSpeed = ($downloadSpeed * 0.7) + ($currentSpeed * 0.3) }
            $lastBytes = $EventArgs.BytesReceived
            $startTime = Get-Date
        }

        # ��ʽ����λ�Ա��Ķ� (KB/s or MB/s)
        if ($downloadSpeed -gt 1MB) {
            $speedString = "{0:N2} MB/s" -f ($downloadSpeed / 1MB)
        } else {
            $speedString = "{0:N0} KB/s" -f ($downloadSpeed / 1KB)
        }

        # ��ʽ���ļ���С
        $receivedSize = "{0:N2} MB" -f ($EventArgs.BytesReceived / 1MB)
        $totalSize = "{0:N2} MB" -f ($EventArgs.TotalBytesToReceive / 1MB)

        # ʹ�� Write-Progress �ڿ���̨����ʾһ�����۵Ľ�����
        Write-Progress -Activity "���������ļ�..."-Status "$($speedString)  |  $($receivedSize) / $($totalSize)" -PercentComplete $EventArgs.ProgressPercentage -Id 1 
    }

    # ���첽��ʽ��ʼ�����ļ�
    # ���������ǵĽ����������ؽ���ʱ��������
    $webClient.DownloadFileAsync($SourceURL, $DestinationPath)

    # ѭ���ȴ���ֱ���������
    while ($webClient.IsBusy) {
        Start-Sleep -Milliseconds 100
    }

    # ������ɺ�ȷ����������ʾ100%���ر�
    Write-Progress -Activity "������ɣ�" -Status "�ļ��ѳɹ����档" -Completed -Id 1
    
    # �ͷ���Դ
    $webClient.Dispose()

} catch {
    # ������������������жϡ�URL��Ч�����򲶻���ʾ������Ϣ
    Write-Host "���ع����з�������: $($_.Exception.Message)" -ForegroundColor Red
    # �˳�������һ��������룬��������ű�֪��ʧ����
    exit 1
}

# �ɹ���ɣ����ش���0
exit 0