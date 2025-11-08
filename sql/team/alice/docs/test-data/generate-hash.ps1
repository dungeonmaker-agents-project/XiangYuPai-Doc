# Generate BCrypt hash for Test@123456

Write-Host "Generating BCrypt hash for Test@123456..." -ForegroundColor Cyan

$securityOAuthPath = "..\security-oauth"
Set-Location $securityOAuthPath

Write-Host "Compiling Java class..." -ForegroundColor Yellow
mvn test-compile -DskipTests 2>&1 | Out-Null

if ($LASTEXITCODE -eq 0) {
    Write-Host "Compilation successful!" -ForegroundColor Green
    Write-Host "Running password generator..." -ForegroundColor Yellow
    Write-Host ""
    
    mvn exec:java "-Dexec.mainClass=com.xypai.auth.GeneratePassword" "-Dexec.classpathScope=test"
} else {
    Write-Host "Compilation failed!" -ForegroundColor Red
}

Set-Location ..\test-data
Write-Host ""
Write-Host "Done!" -ForegroundColor Cyan

