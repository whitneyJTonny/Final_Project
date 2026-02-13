# Fix image references in onboarding screen
$onboardingPath = "lib\screens\onboarding_screen.dart"
$loginPath = "lib\screens\auth\login_screen.dart"

# Read and fix onboarding screen
$content = Get-Content $onboardingPath -Raw
$content = $content -replace "image: 'assets/images/solar_panel.png',", "image: '', // TODO: Add solar_panel.png"
$content = $content -replace "image: 'assets/images/solar_dashboard.png',", "image: '', // TODO: Add solar_dashboard.png"
$content = $content -replace "image: 'assets/images/solar_savings.png',", "image: '', // TODO: Add solar_savings.png"
Set-Content $onboardingPath $content

# Read and fix login screen
$content = Get-Content $loginPath -Raw
$content = $content -replace "image: const DecorationImage\(\s*image: AssetImage\(\s*'assets/images/logo1.jpeg',\s*\),", "// image: const DecorationImage(image: AssetImage('assets/images/logo1.jpeg',"
Set-Content $loginPath $content

Write-Host "Image references fixed!"
