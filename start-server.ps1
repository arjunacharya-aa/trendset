# Simple HTTP Server using PowerShell
$scriptPath = Split-Path -Parent $MyInvocation.MyCommand.Path
if (-not $scriptPath) {
    $scriptPath = Get-Location
}

$listener = New-Object System.Net.HttpListener
$listener.Prefixes.Add("http://localhost:8000/")

try {
    $listener.Start()
    Write-Host "Server started at http://localhost:8000/" -ForegroundColor Green
    Write-Host "Serving files from: $scriptPath" -ForegroundColor Cyan
    Write-Host "Press Ctrl+C to stop the server" -ForegroundColor Yellow
} catch {
    Write-Host "Error starting server: $_" -ForegroundColor Red
    Write-Host "You may need to run as Administrator or use a different port" -ForegroundColor Yellow
    exit
}

while ($listener.IsListening) {
    try {
        $context = $listener.GetContext()
        $request = $context.Request
        $response = $context.Response
        
        $localPath = $request.Url.LocalPath
        if ($localPath -eq "/" -or $localPath -eq "") {
            $localPath = "/deepseek_html_20251204_aad1d2.html"
        }
        
        $filePath = Join-Path $scriptPath $localPath.TrimStart('/')
    
    if (Test-Path $filePath) {
        $content = [System.IO.File]::ReadAllBytes($filePath)
        $response.ContentLength64 = $content.Length
        
        if ($filePath -like "*.html") {
            $response.ContentType = "text/html; charset=utf-8"
        } elseif ($filePath -like "*.css") {
            $response.ContentType = "text/css"
        } elseif ($filePath -like "*.js") {
            $response.ContentType = "application/javascript"
        } else {
            $response.ContentType = "application/octet-stream"
        }
        
        $response.OutputStream.Write($content, 0, $content.Length)
    } else {
        $response.StatusCode = 404
        $notFound = [System.Text.Encoding]::UTF8.GetBytes("404 - File Not Found")
        $response.ContentLength64 = $notFound.Length
        $response.ContentType = "text/plain"
        $response.OutputStream.Write($notFound, 0, $notFound.Length)
    }
    
        $response.Close()
    } catch {
        Write-Host "Error handling request: $_" -ForegroundColor Red
        try {
            $response.StatusCode = 500
            $response.Close()
        } catch {}
    }
}

$listener.Stop()

