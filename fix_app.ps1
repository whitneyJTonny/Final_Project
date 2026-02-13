$projectDir = "c:\Users\USER\Desktop\final year proj\flutter_application_3"
cd $projectDir

# Fix onboarding_screen.dart
$onboardingFile = "lib\screens\onboarding_screen.dart"
$content = Get-Content $onboardingFile -Raw

# Replace buildPage calls to not pass empty image or don't show Image.asset with empty path
$content = $content -replace "Image\.asset\(image, height: 300\),", "// Image.asset(image, height: 300), // TODO: Add image"

Set-Content $onboardingFile $content
Write-Host "Fixed onboarding_screen.dart"

# Fix login_screen.dart - comment out the logo image
$loginFile = "lib\screens\auth\login_screen.dart"
$content = Get-Content $loginFile -Raw

# Find and comment out the image decoration
$content = $content -replace "image: const DecorationImage\(\s*image: AssetImage\(\s*'assets/images/logo1\.jpeg',\s*\),\s*\),\s*fit: BoxFit\.cover,", "// image: const DecorationImage(image: AssetImage('assets/images/logo1.jpeg'), fit: BoxFit.cover),"

Set-Content $loginFile $content
Write-Host "Fixed login_screen.dart"

Write-Host "All fixes applied!"
