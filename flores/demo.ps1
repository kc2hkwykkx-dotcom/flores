param(
    [switch]$NoBuild
)

$ErrorActionPreference = "Stop"
$root = Split-Path -Parent $MyInvocation.MyCommand.Path
$jar = "$root\build\libs\flores-0.0.1-SNAPSHOT.jar"
$log = "$root\demo-app.log"
$hostname = "http://localhost:8080"
$pass = 0; $fail = 0

# Auto-detect JDK 17+
$java = $null
$candidates = @(
    "C:\Program Files\Microsoft\jdk-17*\bin\java.exe",
    "C:\Program Files\Java\jdk-17*\bin\java.exe",
    "C:\Program Files\Eclipse Adoptium\jdk-17*\bin\java.exe",
    "C:\Program Files\Amazon Corretto\jdk-17*\bin\java.exe",
    "$env:JAVA_HOME\bin\java.exe"
)
foreach ($pattern in $candidates) {
    $matches = Get-ChildItem $pattern -ErrorAction SilentlyContinue
    if ($matches) { $java = $matches[0].FullName; break }
}
if (-not $java) {
    Write-Host "ERROR: JDK 17+ not found. Install JDK 17 or set JAVA_HOME." -ForegroundColor Red
    exit 1
}

function Write-Result($method, $url, $ok, $detail) {
    $icon = if ($ok) { "PASS" } else { "FAIL" }
    $color = if ($ok) { "Green" } else { "Red" }
    Write-Host ("  [{0}] {1,-7} {2}" -f $icon, $method, $url) -ForegroundColor $color
    if ($detail -and $detail.Trim() -ne "") {
        Write-Host ("       -> {0}" -f $detail) -ForegroundColor Gray
    }
}

function Test-One($method, $url, $body, $label) {
    Write-Host "`n--- Press ENTER to $label ---" -ForegroundColor DarkYellow
    $null = $Host.UI.RawUI.ReadKey("NoEcho,IncludeKeyDown")
    try {
        $params = @{ Uri = $url; Method = $method; TimeoutSec = 10; UseBasicParsing = $true }
        if ($body) { $params.Body = $body; $params.ContentType = "application/json" }
        $r = Invoke-RestMethod @params -ErrorAction Stop
        $detail = ($r | ConvertTo-Json -Depth 3 -Compress)
        if ($detail.Length -gt 200) { $detail = $detail.Substring(0, 197) + "..." }
        Write-Result $method $url $true $detail
        $script:pass++
    } catch {
        try { $msg = ($_.ErrorDetails.Message | ConvertFrom-Json).message } catch { $msg = $_.Exception.Message }
        Write-Result $method $url $false $msg
        $script:fail++
    }
}

Clear-Host
Write-Host "========================================" -ForegroundColor Magenta
Write-Host "   Flores - Flower Shop API Demo" -ForegroundColor Magenta
Write-Host "   Press ENTER after each step" -ForegroundColor Magenta
Write-Host "========================================" -ForegroundColor Magenta

if (-not $NoBuild) {
    Write-Host "`n[Step 1/5] Build project..." -ForegroundColor Yellow
    $env:JAVA_HOME = (Get-Item $java).Directory.Parent.FullName
    $env:PATH = "$(Get-Item $java).Directory;$env:PATH"
    Set-Location $root
    $origPref = $ErrorActionPreference
    $ErrorActionPreference = "Continue"
    $buildOut = & .\gradlew.bat clean build --no-daemon 2>&1
    $ErrorActionPreference = $origPref
    if ($LASTEXITCODE -ne 0) {
        Write-Host "BUILD FAILED (exit: $LASTEXITCODE)" -ForegroundColor Red
        $buildOut | Select-String -Pattern "FAILURE|ERROR|error:|Could not|BUILD" | Write-Host -ForegroundColor Red
        exit 1
    }
    Write-Host "  Build OK" -ForegroundColor Green
} else {
    Write-Host "`n[Step 1/5] Build project... SKIPPED (-NoBuild)" -ForegroundColor DarkGray
}

Write-Host "`n[Step 2/5] Starting application..." -ForegroundColor Yellow
Get-Process -Name "java" -ErrorAction SilentlyContinue | Stop-Process -Force
Start-Sleep -Seconds 2
Remove-Item $log -Force -ErrorAction SilentlyContinue
Remove-Item "$log.err" -Force -ErrorAction SilentlyContinue
$appProcess = Start-Process -FilePath $java -ArgumentList "-jar `"$jar`"" -WorkingDirectory $root -WindowStyle Hidden -RedirectStandardOutput $log -RedirectStandardError "$log.err" -PassThru
$null = $appProcess

Write-Host "  Waiting for startup" -NoNewline
$started = $false
for ($i = 0; $i -lt 40; $i++) {
    Start-Sleep -Seconds 1
    Write-Host "." -NoNewline
    try {
        $null = Invoke-WebRequest -Uri "$hostname/flowers" -TimeoutSec 2 -ErrorAction Stop -UseBasicParsing
        $started = $true
        break
    } catch {}
}
if (-not $started) { Write-Host "`n  TIMEOUT - app didn't start" -ForegroundColor Red; exit 1 }
Write-Host " READY!" -ForegroundColor Green

Write-Host "`n[Step 3/5] Testing public endpoints..." -ForegroundColor Yellow

Test-One GET  "$hostname/flowers"        $null            "list all flowers"
Test-One POST "$hostname/flowers"        '{"name":"Orchid","description":"Purple orchid","price":120,"quantity":30}' "add a new flower"
Test-One GET  "$hostname/users"          $null            "list all users"

Write-Host "`n[Step 4/5] Testing stubs + order..." -ForegroundColor Yellow

Test-One POST "$hostname/auth/register"  '{"username":"demo","email":"demo@test.com","password":"1234"}' "register a user"
Test-One POST "$hostname/auth/login"     '{"username":"demo","password":"1234"}' "login a user"
Test-One POST "$hostname/orders/create"  '{"flowerName":"Rose","quantity":2}' "create an order"

Write-Host "`n[Step 5/5] Testing admin endpoints..." -ForegroundColor Yellow

Test-One GET  "$hostname/admin/orders"   $null            "list all orders"
Test-One GET  "$hostname/admin/users"    $null            "list all users"
Test-One POST "$hostname/admin/flowers/create" '{"name":"Peony","description":"Pink peony","price":80,"quantity":50}' "create flower (admin)"
Test-One PUT  "$hostname/admin/flowers/update/1" '{"name":"Rose","description":"Red rose updated","price":55,"quantity":90}' "update flower"
Test-One PATCH "$hostname/admin/flowers/update/2?price=25" $null "update flower price"
Test-One PATCH "$hostname/admin/orders/1?status=PROCESSING" $null "update order status"
Test-One PATCH "$hostname/admin/flowers/hide/2" $null "hide a flower"
Test-One DELETE "$hostname/admin/flowers/delete/3" $null "delete a flower"

Write-Host "`n========================================" -ForegroundColor Magenta
Write-Host "   DEMO COMPLETE" -ForegroundColor Magenta
Write-Host "   Passed: $pass   Failed: $fail" -ForegroundColor $(if ($fail -eq 0) { "Green" } else { "Red" })
Write-Host "========================================" -ForegroundColor Magenta
Write-Host "`nApp running at: $hostname" -ForegroundColor Cyan
Write-Host "H2 Console: $hostname/h2-console" -ForegroundColor Cyan
Write-Host "Swagger UI: $hostname/swagger-ui/index.html" -ForegroundColor Cyan
Write-Host "`n--- Press ENTER to stop the application and exit ---" -ForegroundColor DarkYellow
$null = $Host.UI.RawUI.ReadKey("NoEcho,IncludeKeyDown")

Get-Process -Name "java" -ErrorAction SilentlyContinue | Stop-Process -Force
Remove-Item $log -Force -ErrorAction SilentlyContinue
Remove-Item "$log.err" -Force -ErrorAction SilentlyContinue
Write-Host "Application stopped. Bye!" -ForegroundColor Green
