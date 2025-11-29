# Change Logs - 2025-11-29

## 2025-11-29

- [`a67f4a0`](https://github.com/poslogica/generalscripts/commit/a67f4a0e1b87ff3291d082c14510abcc56867904) **Fix PowerShell 5.1 foreach/continue producing null entries - In PS 5.1, 'continue' inside foreach expression outputs null to result array - This caused empty package objects to appear in toUpgrade list - Fix: Add Where-Object filter to remove null/empty entries after foreach - Also improved table parser to skip spinner chars and short lines - Affects both table parsing validation and package filtering**
  *by poslogica*
- [`38e0080`](https://github.com/poslogica/generalscripts/commit/38e0080a5530f5087892cabd038ee1a7e55f91ee) **chore: update change logs [skip ci]**
  *by github-actions[bot]*
- [`b79017c`](https://github.com/poslogica/generalscripts/commit/b79017cf4b2d8ef1fe05bdc25a7268d446898dd4) **Fix Split-Path parameter compatibility for PowerShell 7 - Change Split-Path -LiteralPath to -Path when used with -Parent - PowerShell 7 has stricter parameter set validation - Affects ScriptDir resolution and log directory creation**
  *by poslogica*
- [`6a5b308`](https://github.com/poslogica/generalscripts/commit/6a5b30871c4b5b19390973421d753915b38e5707) **chore: update change logs [skip ci]**
  *by github-actions[bot]*
- [`8307cc6`](https://github.com/poslogica/generalscripts/commit/8307cc66041bc8351d45ef550b64f95d24ffc4bf) **Fix JSON output detection for winget versions - Change version check from v1.4+ to v1.6+ (--output flag added later) - Add runtime detection for 'Argument name was not recognized' error - Properly fall back to table parsing when JSON flag is not supported - Fixes issue where winget v1.12 doesn't support --output json on upgrade command**
  *by poslogica*
- [`9209a82`](https://github.com/poslogica/generalscripts/commit/9209a82e2c027a7cdabc270f8857614477c21b80) **chore: update change logs [skip ci]**
  *by github-actions[bot]*
- [`1f06268`](https://github.com/poslogica/generalscripts/commit/1f06268824e079bc27ed77f5024abe97275c7dcc) **Improve table parser to filter out invalid/garbage lines - Add pattern to stop at 'N upgrades available' summary line - Require package ID to be at least 2 chars and contain alphanumeric - Require package name to be at least 2 chars - Require available version to exist (upgrade candidates must have a target version) - Prevents garbage like empty entries or summary text fragments from being queued**
  *by poslogica*
- [`f6d9382`](https://github.com/poslogica/generalscripts/commit/f6d938218a62c369cc6c00c9ea84fd22f1a45b0e) **chore: update change logs [skip ci]**
  *by github-actions[bot]*
- [`543e5e1`](https://github.com/poslogica/generalscripts/commit/543e5e1a317eab03249d96be3d8ad74d0f10dd83) **Fix Write-Log function name to Write-LogMessage - Fixed 7 instances where Write-Log was used instead of Write-LogMessage - The function is defined as Write-LogMessage but was incorrectly called as Write-Log - Affected upgrade loop: WhatIf, Upgrading, Retry, and Success/Failed messages**
  *by poslogica*
- [`3463446`](https://github.com/poslogica/generalscripts/commit/34634461a5eec72d08915dc800abffb87da0bd35) **Update documentation with new log file location - INSTALL.md: Document logs stored in C:\ProgramData\WingetUpdater\logs - Separate scripts/config path from log files path in documentation - Update troubleshooting section with correct log path**
  *by poslogica*
- [`7c462a3`](https://github.com/poslogica/generalscripts/commit/7c462a3da6df4575e533a7ddd4300a7067d14de5) **chore: update change logs [skip ci]**
  *by github-actions[bot]*
- [`05c2dc3`](https://github.com/poslogica/generalscripts/commit/05c2dc3bfcea9eb9c89e23abcf7e8bbcfb8d656f) **Change log location to user-writable ProgramData directory - Update update-winget-packages.ps1 to write logs to C:\ProgramData\WingetUpdater\logs - Previous location (Program Files) required admin permissions for log writes - ProgramData is writable by all users by default - Update documentation to reflect new log path**
  *by poslogica*
- [`1d68c0a`](https://github.com/poslogica/generalscripts/commit/1d68c0aa40fc5e6bdb7ea1f1341d8e2746afb17b) **chore: update change logs [skip ci]**
  *by github-actions[bot]*
- [`057b1d2`](https://github.com/poslogica/generalscripts/commit/057b1d22e950dcb87cdbd0aa0ae379f7a94b6099) **fix: add missing LogPath parameter to update-third-party-with-winget.ps1 - Add -LogPath parameter to accept log file path from wrapper script - Initialize script-level \ variable - Update Write-LogMessage to write to both console and log file - Create log directory if it doesn't exist Fixes: 'A parameter cannot be found that matches parameter name LogPath'**
  *by poslogica*
- [`d39f0f2`](https://github.com/poslogica/generalscripts/commit/d39f0f297d2b73ff88f22809c53c1404ebf83ee4) **chore: update change logs [skip ci]**
  *by github-actions[bot]*
- [`b725d1d`](https://github.com/poslogica/generalscripts/commit/b725d1d35b3b3047da75dfa3a83a780e21dcb241) **fix: correct case-sensitive script references - Change 'Update-ThirdPartyWithWinget.ps1' to 'update-third-party-with-winget.ps1' - Change 'Update-WingetPackages.ps1' to 'update-winget-packages.ps1' Windows file system is case-insensitive but the installer copies files with their original lowercase names. The references must match exactly for the scripts to find each other after installation. Fixes: 'cannot find main script at C:\Program Files\WingetUpdater\Update-ThirdPartyWithWinget.ps1'**
  *by poslogica*
- [`df8f854`](https://github.com/poslogica/generalscripts/commit/df8f85428cdfcdfaebdb037c2c7766665a79ca07) **chore: update change logs [skip ci]**
  *by github-actions[bot]*
- [`f591d0c`](https://github.com/poslogica/generalscripts/commit/f591d0cbf27c736cd79d794c723bda6a39964e5a) **fix: improve winget output parsing for older versions - Check winget version before attempting JSON output (requires v1.4+) - Skip JSON parsing attempts on older winget versions (like v1.12.x) - Add proper handling for 'no packages available' message - Improve error messages with suggestion to use -Diagnostics - Return empty array instead of throwing when no upgrades found Fixes error: 'Failed to parse winget output (JSON and table fallback)'**
  *by poslogica*
- [`7736fa3`](https://github.com/poslogica/generalscripts/commit/7736fa3c3fb366b193fb0371b922a7b6d038546e) **chore: update change logs [skip ci]**
  *by github-actions[bot]*
- [`8d45aff`](https://github.com/poslogica/generalscripts/commit/8d45aff2140282b6f0260ae4aa52262b33c6147b) **fix: update test to match new help documentation format The update-winget-packages.ps1 script was updated to use proper .SYNOPSIS format instead of informal 'Purpose:' comment. Updated test to match.**
  *by poslogica*
- [`431d3f4`](https://github.com/poslogica/generalscripts/commit/431d3f443f73a441594bb6b12616e43509271432) **feat: add PinToTaskbar parameter to installer - Add -PinToTaskbar parameter (defaults to false, opt-in) - Use Shell.Application verb method for pinning (primary) - Fallback to copying shortcut to TaskBar folder - Add test for new parameter - Update INSTALL.md documentation Note: Windows 10 1809+ and Windows 11 may restrict programmatic pinning**
  *by poslogica*
- [`72338a5`](https://github.com/poslogica/generalscripts/commit/72338a53c36dcd5fe87c758076d7f60f94698c4d) **fix: add missing update-third-party-with-winget.ps1 to installer package - Add to install-winget-updater.ps1 file copy list - Add to create-installer-package.ps1 script files list This script is required by update-winget-packages.ps1 which calls it as the main update engine. Users were getting errors about missing thirdparty scripts.**
  *by poslogica*
- [`d4d2aae`](https://github.com/poslogica/generalscripts/commit/d4d2aae4634fd97e2e3ee3d5d5cf74c052e9dfbe) **docs: standardize PowerShell comment-based help format across scripts - Fix update-winget-packages.ps1: Convert informal comments to proper .SYNOPSIS/.DESCRIPTION/.PARAMETER/.EXAMPLE/.NOTES/.LINK format - Fix update-third-party-with-winget.ps1: Change 'Notes:' to proper .NOTES section, add .LINK - Fix update-winget-packages-create-start-menu-shortcut.ps1: Update .NOTES with correct requirements, add .LINK - Clarify PowerShell 5.1+ requirement for patching scripts (not pwsh-specific)**
  *by poslogica*
- [`c381a23`](https://github.com/poslogica/generalscripts/commit/c381a23f5ff7ad77d981b605158ce058362607ab) **docs: clarify PowerShell 7 (pwsh) requirement for installer - Update install-winget-updater.bat to check for pwsh and show error with download link if missing - Change batch file to use pwsh.exe instead of powershell.exe - Update .NOTES in install-winget-updater.ps1 to specify pwsh requirement - Update installer/README.md and INSTALL.md with clear warnings about pwsh - Update main README.md requirements section Fixes issue where end users ran installer with Windows PowerShell 5.1 instead of PowerShell 7**
  *by poslogica*


## 2025-11-28

- [`442f3c1`](https://github.com/poslogica/generalscripts/commit/442f3c1964dcb6c185a16d3b6e761112ea66e289) **chore: update change logs [skip ci]**
  *by github-actions[bot]*
- [`203a707`](https://github.com/poslogica/generalscripts/commit/203a7074bf91ee2e2e7a3035b997c2ff167d7b53) **test: Add comprehensive tests for installer scripts New test files (104 tests total): - install-winget-updater.tests.ps1 (35 tests) - uninstall-winget-updater.tests.ps1 (35 tests) - create-installer-package.tests.ps1 (34 tests) Tests cover: - Script file validation and syntax - Parameter definitions and validation - Script structure and required functionality - Output and error handling Also: - Update run-tests.ps1 to include installer scripts in coverage - Update README.md with new test counts (254 total)**
  *by poslogica*
- [`3a66cf6`](https://github.com/poslogica/generalscripts/commit/3a66cf6b61ec74f57810aeb0ac032f26ded4004b) **docs: Fix markdown files for accuracy and consistency README.md: - Remove broken link to deleted patch-software-windows.ps1 - Standardize test count to 150 across all references VERSION-MANAGEMENT.md: - Update to reflect GitHub tag-based versioning (no longer VERSION file) - Add instructions for manual version bumps via releases - Update troubleshooting for new versioning approach GITHUB-ACTIONS-INSTALLER.md: - Update workflow triggers (now uses workflow_run, not push) - Add uninstall-winget-updater.ps1 to ZIP contents - Update release naming to semantic versioning format - Fix artifact naming pattern installer/README.md: - Update uninstall feature description - Update version and date scripts/windows/patching/README.md: - Fix shortcut script test count (46, not 48)**
  *by poslogica*
- [`ac0d2b8`](https://github.com/poslogica/generalscripts/commit/ac0d2b83ff188d42b8a18a0d6be5380976cef598) **Merge branch 'main' of https://github.com/poslogica/generalscripts**
  *by poslogica*
- [`a4472c4`](https://github.com/poslogica/generalscripts/commit/a4472c42ab162831266876cccb7541b635e30e14) **refactor: Move uninstall script to installer folder - Move uninstall-winget-updater.ps1 to installer/ directory - Fix installer to look for files in same directory (extracted ZIP) - Update package builder to copy uninstall from installer folder**
  *by poslogica*
- [`15314e3`](https://github.com/poslogica/generalscripts/commit/15314e359201f4e511e7a47db43e7cb6d0887f61) **feat: Add uninstall script for Winget Updater - Create uninstall-winget-updater.ps1 with full cleanup capabilities - Removes scheduled task, Start Menu shortcut, and installation directory - Optional backup of logs and config with -KeepLogs/-KeepConfig flags - Support for custom backup path and silent uninstall (-Force) - Update installer to copy uninstall script to install location - Update package builder to include uninstall script - Update INSTALL.md with correct file names and uninstall examples**
  *by poslogica*
- [`ef853f9`](https://github.com/poslogica/generalscripts/commit/ef853f9c0d13366534c48f287031e05195bc0ea4) **chore: update change logs [skip ci]**
  *by github-actions[bot]*
- [`3f325f1`](https://github.com/poslogica/generalscripts/commit/3f325f172a0e95523d77195854eb19f2978604ea) **docs: Add system requirements notes to Update-ThirdPartyWithWinget - Windows 10/11 or Windows Server 2019+ - Winget must be installed - PowerShell 5.1+ required**
  *by poslogica*
- [`08e86a0`](https://github.com/poslogica/generalscripts/commit/08e86a01405014cd89e2af7a0610cb21a37d17fb) **ci: Rename version step to reflect GitHub Releases as primary source**
  *by poslogica*
- [`3031fe3`](https://github.com/poslogica/generalscripts/commit/3031fe3302a44368dd1d386f346dba712c95c642) **ci: Switch to native GitHub tag-based versioning - Version now derived from latest GitHub release tag - Uses gh release list API for single source of truth - Automatically increments patch version - Starts at v0.0.1 if no releases exist - VERSION file updated for reference only (not used for versioning) - Eliminates race conditions from VERSION file commits**
  *by poslogica*
- [`9b3ec90`](https://github.com/poslogica/generalscripts/commit/9b3ec9048cf9510e96891232668d9eb342d43363) **fix: Fetch remote tags before checking, gracefully handle existing tags/releases**
  *by poslogica*
- [`4cf5339`](https://github.com/poslogica/generalscripts/commit/4cf533992616d43e423a598ca0be796095180972) **chore: update change logs [skip ci]**
  *by github-actions[bot]*
- [`d2cdc49`](https://github.com/poslogica/generalscripts/commit/d2cdc495356d1d079c0a1820fa5449a870045ec6) **docs: Add Windows and Winget requirements to update-winget-packages.ps1 notes**
  *by poslogica*
- [`c7356fa`](https://github.com/poslogica/generalscripts/commit/c7356fa564c9dd395e903503e11d955ad4166270) **chore: Bump version to 1.0.1 for next release**
  *by github-actions[bot]*
- [`597d95b`](https://github.com/poslogica/generalscripts/commit/597d95b31382d617e3157f35ad3f929cfeacc72a) **fix: Replace PowerShell here-string with concatenation to fix YAML syntax error**
  *by poslogica*
- [`0f3c926`](https://github.com/poslogica/generalscripts/commit/0f3c9263744d543db6a3f050cd855f2e6fdc7d9f) **ci: Add git tagging and restructure workflow - create tag/release before version bump**
  *by poslogica*
- [`acd64eb`](https://github.com/poslogica/generalscripts/commit/acd64ebf5cf28b5d1bfeb8f7bf64aa82ed9b7815) **ci: Fix GitHub Release step - remove invalid condition and improve release notes**
  *by poslogica*
- [`5b82177`](https://github.com/poslogica/generalscripts/commit/5b82177ce6ca165d454d86faee084b69f7c9505f) **chore: update change logs [skip ci]**
  *by github-actions[bot]*
- [`0682485`](https://github.com/poslogica/generalscripts/commit/06824859404ab117b2cb7fa7f6f353a8ce41d335) **testing workflow**
  *by poslogica*
- [`2348b1b`](https://github.com/poslogica/generalscripts/commit/2348b1bd56e742bb1d52f8d9d13bba4b2fbe8972) **fix: Use inline regex with (?m) multiline flag instead of invalid Select-String parameter**
  *by poslogica*
- [`50c206e`](https://github.com/poslogica/generalscripts/commit/50c206e12be984f8981a0b7753d955f98c630782) **chore: update change logs [skip ci]**
  *by github-actions[bot]*
- [`a9e77ee`](https://github.com/poslogica/generalscripts/commit/a9e77ee4b521910db1fcf98005a0cb11cd27f9d2) **fix: Correct inaccurate parameter examples in update-third-party-with-winget-examples.ps1**
  *by poslogica*
- [`f2b8215`](https://github.com/poslogica/generalscripts/commit/f2b82156d8506c747c333b122b57c1e3a26780b4) **fix: Improve version increment step with better regex, file verification, and conflict resolution**
  *by poslogica*
- [`536d296`](https://github.com/poslogica/generalscripts/commit/536d296e447f0cacc67c84a92c1adb65cd787410) **chore: update change logs [skip ci]**
  *by github-actions[bot]*
- [`6bcb4ea`](https://github.com/poslogica/generalscripts/commit/6bcb4ea86cf66f12e9466f07533a0109bf458b67) **docs: Add comprehensive comments to update-winget-packages-create-start-menu-shortcut.ps1**
  *by poslogica*
- [`694e413`](https://github.com/poslogica/generalscripts/commit/694e41321d00cbb73587788a674cffacb268a86b) **fix: Add write permissions and use GITHUB_TOKEN for version increment push**
  *by poslogica*
- [`b786348`](https://github.com/poslogica/generalscripts/commit/b7863486c4edd48167b1938bd6a4a368c89b151c) **chore: update change logs [skip ci]**
  *by github-actions[bot]*
- [`3511670`](https://github.com/poslogica/generalscripts/commit/3511670e4c44727549e24e6e9f34d74af16bf490) **docs: Add comprehensive comments to get-duplicate-files-with-progress.tests.ps1**
  *by poslogica*
- [`492d093`](https://github.com/poslogica/generalscripts/commit/492d09338f4d669d2d4b860845bbd3f5cd300355) **chore: update change logs [skip ci]**
  *by github-actions[bot]*
- [`a181e11`](https://github.com/poslogica/generalscripts/commit/a181e11578692d5942a2e128d66bfb2ef23c945f) **ci: Add automatic version increment step to publish-installer workflow**
  *by poslogica*
- [`e9b2409`](https://github.com/poslogica/generalscripts/commit/e9b240926b82c85af42af36f8e517f14c63b3c4f) **chore: update change logs [skip ci]**
  *by github-actions[bot]*
- [`18e1251`](https://github.com/poslogica/generalscripts/commit/18e1251b892375f83fa0c08d8b11c2bde2c9e8c8) **docs: Add comprehensive comments to update-winget-packages.tests.ps1**
  *by poslogica*
- [`ec9efb7`](https://github.com/poslogica/generalscripts/commit/ec9efb7d62ca468a989e27e1ee8486a59cc278bb) **docs: Add comprehensive comments to update-winget-packages-create-start-menu-shortcut.tests.ps1**
  *by poslogica*
- [`50c1b36`](https://github.com/poslogica/generalscripts/commit/50c1b3694bbd0dcef000fe6f49d4754ebb0b2134) **chore: update change logs [skip ci]**
  *by github-actions[bot]*
- [`cdf97a2`](https://github.com/poslogica/generalscripts/commit/cdf97a279c37ccad13052fd968b2b54a65cfd61e) **docs: Add comprehensive comments to update-third-party-with-winget.tests.ps1**
  *by poslogica*
- [`358a063`](https://github.com/poslogica/generalscripts/commit/358a063676f012dd4c6790e2ffc2a37602c3ce5d) **docs: Update markdown files for accuracy - remove obsolete patch-software-windows references, fix test counts, correct script name typo**
  *by poslogica*
- [`8a6b5aa`](https://github.com/poslogica/generalscripts/commit/8a6b5aaaad4ab587a0209b9f929d9c07276d0b18) **docs: Add Documentation section to README with links to GitHub Actions and Version Management guides**
  *by poslogica*
- [`86c4018`](https://github.com/poslogica/generalscripts/commit/86c4018f355930edc511e06cadb33353df963777) **docs: Document GitHub Actions workflow orchestration chain**
  *by poslogica*
- [`e9ea34c`](https://github.com/poslogica/generalscripts/commit/e9ea34ce0b8dac0f5ceefc25a9edc70f27c878ff) **Merge branch 'main' of https://github.com/poslogica/generalscripts**
  *by poslogica*
- [`d1dadcf`](https://github.com/poslogica/generalscripts/commit/d1dadcf9d95154de4717d972551e310c2001512f) **ci: Make Build and Publish Winget Updater workflow trigger after PowerShell Script Validation succeeds**
  *by poslogica*
- [`acdbda6`](https://github.com/poslogica/generalscripts/commit/acdbda68446cad32691c86ff8d02a854bd03a9f1) **chore: update change logs [skip ci]**
  *by github-actions[bot]*
- [`081f91e`](https://github.com/poslogica/generalscripts/commit/081f91eef4efa209a9c02cef8ea06c936d173f4a) **docs: Add note about administrator privileges requirement to Update-WingetPackages.ps1**
  *by poslogica*
- [`3669464`](https://github.com/poslogica/generalscripts/commit/366946403f7afc942f6c295a9d3917aefb3feed6) **chore: update change logs [skip ci]**
  *by github-actions[bot]*
- [`3e47afd`](https://github.com/poslogica/generalscripts/commit/3e47afd595d1a87072a291f16cfa0a2a9cf9357c) **fix: Only create output file when duplicates are found**
  *by poslogica*
- [`53ddafd`](https://github.com/poslogica/generalscripts/commit/53ddafd8f7e7d05940385ba1c7ba3096ac45b386) **chore: Remove obsolete patch-software-windows tests and fix duplicate file script output format**
  *by poslogica*
- [`69befab`](https://github.com/poslogica/generalscripts/commit/69befab5e8a08f070cf9e56cd38c8da664725848) **only trigger on push**
  *by poslogica*
- [`4031c3b`](https://github.com/poslogica/generalscripts/commit/4031c3b09c59036b57f64201d55db855dbaa9ee8) **docs: Add usage examples to Update-WingetPackages.ps1 comment block**
  *by poslogica*
- [`c0f6264`](https://github.com/poslogica/generalscripts/commit/c0f6264d30f7e7bc95ab2d3941f0a40c89a87e7b) **fix: Improve workflow_run condition check in Generate Change Logs workflow**
  *by poslogica*
- [`3345673`](https://github.com/poslogica/generalscripts/commit/334567351a706d480eb8afd79106b1f983e46a27) **chore: Remove obsolete patch-software-windows script and documentation - replaced by Update-WingetPackages scripts**
  *by poslogica*
- [`8532941`](https://github.com/poslogica/generalscripts/commit/8532941876df5bfec088b82fd57f3e79465c0248) **docs: Update patch-software-windows.md for accuracy - fix filename reference and winget implementation details**
  *by poslogica*
- [`2a1612c`](https://github.com/poslogica/generalscripts/commit/2a1612cc6599901e249987bb0f886eb5b304f9f4) **refactor: Improve duplicate file detection script with better reporting ## Improvements - Fix double spaces in -LiteralPath parameters - Store file size data for each hash entry - Sort duplicate groups by file size (largest first) - Calculate total wasted space from duplicates - Add comprehensive report header with statistics - Include file sizes in output (KB/MB) - Show wasted space per duplicate group - Sort files within each group alphabetically - Use Write-Host with color output for better UX - Add formatted report footer with totals - Display summary statistics in console - Report shows: total files scanned, duplicate groups, wasted space**
  *by poslogica*
- [`4ebc260`](https://github.com/poslogica/generalscripts/commit/4ebc260d12ccb704d4a45dc9dfcc77f349cec780) **docs: Add Changelog section to README with reference to changelog.md - Add Changelog entry to table of contents - Create new Changelog section explaining auto-generated changelog - Reference changelog.md file with direct link - Link to commit history for detailed version control history - Explains changelog is generated by GitHub Actions**
  *by poslogica*
- [`0b3e350`](https://github.com/poslogica/generalscripts/commit/0b3e350576282f3fe51ca9fa5856109cb6ba1c65) **chore: update change logs [skip ci]**
  *by github-actions[bot]*
- [`3ea4df5`](https://github.com/poslogica/generalscripts/commit/3ea4df5b4ce9af39cf1779d299750ef80e88c009) **fix: Add explicit permissions and improve git authentication in changelog workflow - Add permissions block: contents:write, pull-requests:write - Update checkout action to v4 with token parameter - Use git credential helper for authentication - Store credentials in ~/.git-credentials file - Use standard 'origin main' push target - Resolves workflow_run permission restrictions issue**
  *by poslogica*
- [`4198e93`](https://github.com/poslogica/generalscripts/commit/4198e9304d43736120be4aab5b4dfd39821c8e17) **fix: Use GitHub token for authenticated git push in changelog workflow - Add GITHUB_TOKEN to environment for authentication - Use token-based URL for git push instead of HTTPS - Resolves "Write access to repository not granted" error (403) - Allows workflow to push changelog updates to main branch**
  *by poslogica*
- [`26e72de`](https://github.com/poslogica/generalscripts/commit/26e72de09a875978af2c74734016a8b218b93ba7) **docs: Fix markdown formatting issues across all documentation files - Add blank lines around code fences (MD031) - Add language specifiers to code blocks (MD040) - Add trailing newlines to all markdown files (MD047) - Fix list spacing around headings (MD032, MD022) - Improve readability of numbered lists with blank line separation - All 9 markdown files now pass linting checks**
  *by poslogica*
- [`405bc3d`](https://github.com/poslogica/generalscripts/commit/405bc3d07057299fe1f69425af4ed6c3b4238db2) **feat: Add automated changelog generation via GitHub Actions ## Overview Implement fully automated changelog generation system that creates both text and Markdown formatted changelogs from GitHub commit history. Changelogs are generated after successful PowerShell validation and published as artifacts. ## Changes ### New Files - .github/workflows/generate_change_logs.yml * Triggered after successful PowerShell Script Validation workflow * Supports manual triggering via workflow_dispatch * Automatically commits generated changelogs to repository * Retains 90-day artifact history - .github/src/generate_change_logs.py * ChangeLogsGenerator class for fetching and formatting commits * Supports GitHub API pagination (100 commits per page) * Generates changelog.txt (plain text format) * Generates changelog.md (Markdown format with clickable commit links) * Comprehensive logging and error handling * Self-contained logger using Python's logging module - .github/src/requirements.txt * Single dependency: requests>=2.28.0 * Installed by workflow during build process ### Implementation Details - Commits grouped by date (YYYY-MM-DD) in reverse chronological order - Markdown format includes clickable commit SHA links to GitHub commits - Author attribution for each commit - Proper Markdown formatting (MD022/MD032 compliant) - Multi-line commit messages normalized to single line - All string constants centralized (UNKNOWN_DATE, UNKNOWN_MESSAGE, UNKNOWN_AUTHOR) - Type hints on all methods - Zero lint errors ## Workflow Integration - Triggered: After PowerShell Script Validation workflow completes successfully - Manual trigger: Available via GitHub UI (workflow_dispatch) - Commits: Generated files auto-committed with [skip ci] flag - Artifacts: Published with 90-day retention - Rebase handling: Prevents conflicts with concurrent commits**
  *by poslogica*
- [`2f0f7b3`](https://github.com/poslogica/generalscripts/commit/2f0f7b342f0e0e6a2ec4450c47844fb9dafe26d2) **Update module docstring to reference correct class and filenames**
  *by poslogica*
- [`5c7b5ed`](https://github.com/poslogica/generalscripts/commit/5c7b5ed59a619b5e173a92e24cca5f27a4dde7ee) **Add constants for error messages (UNKNOWN_MESSAGE, UNKNOWN_AUTHOR)**
  *by poslogica*
- [`ad0cf70`](https://github.com/poslogica/generalscripts/commit/ad0cf70dc4efbf099d708a90eda538d42de39295) **Add requirements.txt and update workflow to use it**
  *by poslogica*
- [`7eccd52`](https://github.com/poslogica/generalscripts/commit/7eccd52d878ea0367fb81cfdf4ec1b6dc1880719) **Remove log_instance dependency and use built-in logging**
  *by poslogica*
- [`243c985`](https://github.com/poslogica/generalscripts/commit/243c985a65ebb443afde1240b36f6b957fadbbb5) **Add comprehensive version management documentation**
  *by poslogica*
- [`0040c44`](https://github.com/poslogica/generalscripts/commit/0040c4462e0236672cb875cbe8772541e3892cd5) **Add version management to installer builds - Created installer/VERSION file (semantic versioning: 1.0.0) - Updated create-installer-package.ps1: * New -Version parameter for custom versions * Reads version from VERSION file by default * Generates ZIP filename: winget-updater-setup-v{version}.zip * Displays version in build output - Updated GitHub Actions workflow: * Extracts version from VERSION file * Includes version in artifact name * Tags releases with version (v1.0.0 format) * Release notes include version number - Benefits: * Users can identify installer version at a glance * Multiple versions coexist in releases * Easy version bumping by editing VERSION file * Semantic versioning for clear compatibility tracking**
  *by poslogica*
- [`0eabe88`](https://github.com/poslogica/generalscripts/commit/0eabe88599d123a91aefa6600292a39290ff980e) **Add note about automated installer builds in main README - Added reference to Releases page for pre-built installer - Linked to GITHUB-ACTIONS-INSTALLER.md documentation - Notes that installers are automatically published by CI/CD**
  *by poslogica*
- [`93206fc`](https://github.com/poslogica/generalscripts/commit/93206fcc39aa5d3b3258767a9b88e09cd3e67a60) **Add documentation for GitHub Actions installer workflow - Created docs/GITHUB-ACTIONS-INSTALLER.md - Documents automatic build and publishing process - Includes: * How the workflow is triggered * What gets built and where artifacts are stored * How users download the installer * Build information included in releases * Workflow structure and configuration * Developer guide for manual builds * Troubleshooting section * Security considerations * Future enhancement ideas - All markdown standards compliant**
  *by poslogica*
- [`5e74c41`](https://github.com/poslogica/generalscripts/commit/5e74c413caccb9e0490023f4c964157b17a61e13) **Add GitHub Actions workflow to build and publish Winget Updater installer - New workflow: .github/workflows/publish-installer.yml - Triggers on: push to main/develop branches, changes to installer or patching scripts - Build process: * Runs on Windows latest runner * Executes create-installer-package.ps1 * Verifies ZIP package creation - Publishing: * Uploads artifact (winget-updater-setup.zip) to GitHub with 90-day retention * Creates GitHub Release (main branch only) with build info * Release tagged with build number (installer-{run_number}) - Benefits: * Users can download ready-to-use installer from Releases page * Automatic builds on code changes * Can be triggered manually via workflow_dispatch * Release notes include quick start instructions and feature list**
  *by poslogica*
- [`28196e7`](https://github.com/poslogica/generalscripts/commit/28196e709358e0d0a375107d2b61aa7cd557f4cf) **Add Winget Updater installation documentation to main README - Added Quick Start section with three installation options - Option 1: Automated installation via ZIP (recommended) - Option 2: PowerShell direct installation - Option 3: Clone repository for manual use - Improved markdown compliance for heading levels - Users can now easily get started with automated updates**
  *by poslogica*
- [`32dbfd7`](https://github.com/poslogica/generalscripts/commit/32dbfd7aa3df987ebf46bbdc74b3976e3c418969) **Refactor installer scripts for clean architecture and code quality - Simplified install-winget-updater.ps1 with direct implementation (no nested functions) - Cleaned create-installer-package.ps1 with minimal dependencies - All critical PSScriptAnalyzer warnings resolved - Write-Host retained for interactive UI (acceptable for installer/tool scripts) - Removed unused parameters, variables, and BOM encoding issues - Both scripts ready for production use - Full functionality maintained: admin checks, task scheduling, shortcut creation, uninstall**
  *by poslogica*
- [`9dfd26d`](https://github.com/poslogica/generalscripts/commit/9dfd26dc097b47d0817731ce21d66af0c06b74a1) **Add README for installer directory with usage instructions**
  *by poslogica*
- [`0842828`](https://github.com/poslogica/generalscripts/commit/0842828f7500655332725751aada27a6673c2d98) **Add installer package for Winget Updater suite - Create install-winget-updater.ps1 PowerShell installer with full features - Add install-winget-updater.bat wrapper for easy execution - Create INSTALL.md comprehensive installation guide (GitHub markdown compliant) - Create create-installer-package.ps1 to build distribution ZIP files - Installer features: * Admin privilege checks * Winget availability validation * Configurable installation path (default: C:\Program Files\WingetUpdater) * Scheduled task creation (Daily/Weekly/Monthly options) * Start Menu shortcut generation * Uninstall script generation * Comprehensive logging support * Installation documentation generation**
  *by poslogica*
- [`a9faed6`](https://github.com/poslogica/generalscripts/commit/a9faed63a2ae0e4617ede84524127c6adc5d8372) **Fix regex pattern in shortcut test - match TargetPath assignment correctly**
  *by poslogica*
- [`caf04e5`](https://github.com/poslogica/generalscripts/commit/caf04e5ef74d43dbd2d0464cb48a24fd286e542b) **docs: update all markdown files to follow GitHub standards - Updated main README with comprehensive documentation - Added Testing section with test results and coverage information - Added CI/CD Integration section - Updated Contributing section with code quality requirements - Reorganized Prerequisites section for Windows-focused content - Updated Patching directory README with active/legacy script status - Added deprecation notice and migration path for legacy patch script - Fixed markdown lint issues: trailing punctuation, code block spacing, newlines - All markdown files now follow GitHub markdown standards**
  *by poslogica*
- [`7b53e14`](https://github.com/poslogica/generalscripts/commit/7b53e1415b96d0777edc9090e58ab63eec038809) **refactor: exclude duplicate_files_with_progress.txt from git tracking**
  *by poslogica*
- [`7e05246`](https://github.com/poslogica/generalscripts/commit/7e05246f17b331f505fa7e4c43e79b7fa0a48a2a) **feat: add code coverage reporting to test runner - Integrated Pester code coverage analysis with JaCoCo XML output - Displays overall coverage percentage and per-file breakdown - Coverage color-coded: Green (>=80%), Yellow (>=60%), Red (<60%) - Added -CoverageReport parameter to enable/disable coverage (default: enabled) - Generates CodeCoverage.xml report for CI/CD integration - All 149 tests pass with coverage analysis enabled**
  *by poslogica*
- [`c569212`](https://github.com/poslogica/generalscripts/commit/c569212bfc39f9e6b04b8b29e974ebd119f68eaf) **test: add comprehensive test suite for patch-software-windows.ps1 - Added 45 tests covering 11 context areas - Tests validate script syntax, structure, and key functionality - Coverage includes: log configuration, execution policy, winget integration, error handling, transcript management, and robustness - All 149 tests pass (104 existing + 45 new)**
  *by poslogica*
- [`0fde841`](https://github.com/poslogica/generalscripts/commit/0fde84119a3daa716967260611bfa5c27a898fb4) **fix: update run-tests.ps1 path resolution for tests/windows directory**
  *by poslogica*
- [`2c02241`](https://github.com/poslogica/generalscripts/commit/2c02241923ec1a6ad677b50068ef1f2356fe9ef9) **refactor: move run-tests.ps1 to tests/windows directory**
  *by poslogica*
- [`625faf3`](https://github.com/poslogica/generalscripts/commit/625faf374d07ffedf3bd0661a6e6183d3dea59dd) **ci: update GitHub Actions to use latest versions (actions/checkout@v4, actions/upload-artifact@v4)**
  *by poslogica*
- [`9abc4dd`](https://github.com/poslogica/generalscripts/commit/9abc4ddad5064c7f59500ca5d973cb7cd2a43355) **ci: add artifact upload for test results to GitHub Actions**
  *by poslogica*
- [`98da549`](https://github.com/poslogica/generalscripts/commit/98da549bd9bfeaa6f7c3ad8e0ea996b97387b262) **refactor: add pattern to gitignore all test result XML files**
  *by poslogica*
- [`1a54b18`](https://github.com/poslogica/generalscripts/commit/1a54b18473456ff9df9c72e92891562c3755b2f1) **fix: change Scope parameter tests to static validation instead of execution - Tests were failing on GitHub Actions due to Start-Process elevation requirements - Machine scope attempts to re-elevate which fails in CI environment where pwsh is used - Changed tests to validate parameter definitions statically instead of executing the script - Tests now verify ValidateSet and default values directly from script content - All 104 tests now pass consistently on both local and GitHub Actions**
  *by poslogica*
- [`4783be7`](https://github.com/poslogica/generalscripts/commit/4783be7c7b2365957533fb590bf9cc869644a332) **refactor: add TestResults.xml to gitignore**
  *by poslogica*
- [`d8fee05`](https://github.com/poslogica/generalscripts/commit/d8fee05128fb1eba2701c692953326e45dafa772) **fix: update run-tests.ps1 to work correctly from tests directory**
  *by poslogica*
- [`b50e19c`](https://github.com/poslogica/generalscripts/commit/b50e19c9af5eba199bddca03fbd240163d9f70b1) **refactor: move run-tests.ps1 to tests directory**
  *by poslogica*
- [`3f8d10f`](https://github.com/poslogica/generalscripts/commit/3f8d10f9f5dcace28ddf421fd0fdc0c17b934afb) **feat: add run-tests.ps1 script to execute all Pester tests locally**
  *by poslogica*
- [`d66cdb2`](https://github.com/poslogica/generalscripts/commit/d66cdb2c36c105be2b407847742cadacdcb2870e) **refactor: remove unused scriptDir and mainScript variables**
  *by poslogica*
- [`6c966f1`](https://github.com/poslogica/generalscripts/commit/6c966f1605d45d23aeb99821cf98387ca52b670d) **fix: resolve GitHub Actions test failures - use pwsh.exe for isolated process and handle machine scope elevation**
  *by poslogica*
- [`08822d8`](https://github.com/poslogica/generalscripts/commit/08822d87c1c2b2fd8594c291ea5357d6875bcf42) **fix: run invalid path test in isolated process for consistency - Remove conditional skip for GitHub Actions - Run test in separate powershell.exe process to isolate error streams - Validates exit code (1) for graceful error handling - Ensures 100% consistency between local and GitHub Actions environments - All 104 tests now pass in both environments (no skips)**
  *by poslogica*
- [`592450e`](https://github.com/poslogica/generalscripts/commit/592450eb87f84fca2a2539011fe6034adeddb92a) **test: add comprehensive test suite for update-third-party-with-winget.ps1 - 42 tests covering script structure, parameters, and utility functions - Validates configuration handling and winget integration - Tests JSON/table output parsing, error handling, and filtering - Verifies robustness features: noisy output handling, PS 5.1 compatibility - All tests passing locally (697ms)**
  *by poslogica*
- [`8c96f43`](https://github.com/poslogica/generalscripts/commit/8c96f4332ce111edd140fd75f5c647d8547488f6) **test: add comprehensive test suite for update-winget-packages.ps1 - 30 tests covering script syntax, parameters, structure, and logic - Validates parameter validation and default values - Verifies admin elevation handling and log directory creation - Tests edge cases: WhatIf flag, argument forwarding, PSBoundParameters - All tests passing locally (619ms)**
  *by poslogica*
- [`0e5868f`](https://github.com/poslogica/generalscripts/commit/0e5868f101c529d22b1057672607f6e8bcc18174) **test: conditionally skip invalid path test on GitHub Actions Skip test on GitHub Actions due to stricter error stream detection in CI/CD environment. Test runs locally (32/32 passing) and skips on GitHub Actions (31/31 + 1 skipped) to prevent false failures.**
  *by poslogica*
- [`fc8f024`](https://github.com/poslogica/generalscripts/commit/fc8f024f486e5e8b2b22d06ad71c02dbd10dbfd3) **fix: use null assignment to suppress script errors completely**
  *by poslogica*
- [`651d945`](https://github.com/poslogica/generalscripts/commit/651d94539ca79c16232abc89a3122f2419905565) **fix: redirect all output streams in invalid path test for full compatibility**
  *by poslogica*
- [`edbb7ef`](https://github.com/poslogica/generalscripts/commit/edbb7ef34757b2a793ddaf25c66e3a1053e0f239) **fix: simplify invalid path test to use -ErrorAction Continue for cross-platform compatibility**
  *by poslogica*
- [`abf8e9e`](https://github.com/poslogica/generalscripts/commit/abf8e9ee11b62db1c6b011224d5c660397e70fbd) **fix: update invalid path test to properly handle error exceptions**
  *by poslogica*
- [`bf1405f`](https://github.com/poslogica/generalscripts/commit/bf1405f07cfecb6379396f5577cf1cac3b426247) **fix: update invalid path test to check exit code instead of catching exceptions**
  *by poslogica*
- [`d180321`](https://github.com/poslogica/generalscripts/commit/d1803212c223ca58aca5cf4f0511903ef1c80f10) **fix: suppress error stream in invalid path test to prevent false failures**
  *by poslogica*
- [`0788070`](https://github.com/poslogica/generalscripts/commit/0788070116b07d0d5685cbfa182c945da5145fd7) **fix: update GitHub Actions to use modern Pester 5.x configuration to eliminate legacy parameter set warning**
  *by poslogica*
- [`9ff7cde`](https://github.com/poslogica/generalscripts/commit/9ff7cde25b03de0be1434a09ee31513b1820dd3e) **fix: wrap invalid path test in error suppression to properly handle Write-Error**
  *by poslogica*
- [`f46b380`](https://github.com/poslogica/generalscripts/commit/f46b3806186a0041f10faed636a0c7289b58f80c) **fix: convert test file to Pester 5.x syntax for GitHub Actions - Update BeforeAll block for Pester 5.x variable scoping - Use hyphenated assertions (Should -Be, Should -Match, Should -Not -Throw) - All 32 tests pass with Pester 5.7.1 (matches GitHub Actions version) - Tests also work with legacy parameter set in older environments - Fixes CI/CD pipeline test execution**
  *by poslogica*
- [`d573b46`](https://github.com/poslogica/generalscripts/commit/d573b46c49a7fb0d73e023caaf2789916524a6fc) **fix: update test file for Pester 3.4.0 compatibility - Convert all test assertions to Pester 3.4.0 syntax (compatible with older versions) - Use 'Should Match' instead of 'Should -Match' - Use 'Should Be' instead of 'Should -Be' - Use 'Should Not Throw' instead of 'Should -Not -Throw' - Use 'Should BeLessThan' instead of 'Should -BeLessThan' - All 32 tests pass locally with Pester 3.4.0 - Tests will also work with Pester 5.x on GitHub Actions (legacy parameter set)**
  *by poslogica*
- [`3f422f8`](https://github.com/poslogica/generalscripts/commit/3f422f89e07a7b8bcc9911e18c81c7ee901dfdb2) **build: exclude generated script output files from git tracking - Add duplicate_files_with_progress.txt to .gitignore - Exclude all *_results.txt and *_output.txt files - These are generated artifacts from test/script execution, not source files**
  *by poslogica*
- [`45d4649`](https://github.com/poslogica/generalscripts/commit/45d4649142afe3746a9a7fdc7a3cc8e8f82e3c39) **test: add 10 edge case tests for improved coverage New test contexts added: - Edge Cases - File Sizes: zero-byte files, large files (5MB+), mixed sizes - Edge Cases - Special Characters and Encoding: Unicode filenames, Unicode content - Edge Cases - Output File Behavior: overwriting, proper formatting verification - Edge Cases - File Permissions and State: identical content different extensions, SHA256 format Test count: 22 -> 32 tests (45% coverage increase) All tests pass with Pester v3.4.0 Covers edge cases: large files, Unicode, special characters, output formatting, hash validation**
  *by poslogica*
- [`2df2167`](https://github.com/poslogica/generalscripts/commit/2df2167933b6041db03872a44a0b77b6499fdcf2) **refactor: move test files to separate tests directory - Move get-duplicate-files-with-progress.tests.ps1 from scripts/windows/file/ to tests/windows/file/ - Keep tests separate from distribution package - Update workflow to discover tests in new location - Simplifies release packaging - only ship scripts/ directory - Tests remain accessible for development and CI/CD**
  *by poslogica*
- [`4044762`](https://github.com/poslogica/generalscripts/commit/4044762e372299eb99a49d79d88b61505a5e442b) **test: fix output file path reference in test file - Update output file path to use scripts directory instead of test directory - Ensures test file can be located anywhere without affecting functionality - All 22 tests pass with corrected paths**
  *by poslogica*
- [`7eae0ed`](https://github.com/poslogica/generalscripts/commit/7eae0ed8948315bd0f2829ccd33a3082ad41c0f8) **ci: add pester test execution to github actions workflow - Install and run Pester tests in CI pipeline - Exclude *.tests.ps1 files from PSScriptAnalyzer validation - Generate NUnit XML output for test reporting - Tests will run automatically on push/PR to main or develop branches**
  *by poslogica*
- [`4376fcb`](https://github.com/poslogica/generalscripts/commit/4376fcbae7f22c423e72430c35919f9055b8cdae) **test: add comprehensive pester test suite for get-duplicate-files-with-progress script - Create 22 test cases covering script functionality - Test contexts: syntax validation, parameter handling, duplicate detection, recursive scanning, output generation, file handling, error handling, and performance - All tests pass with Pester v3.4.0 syntax compatibility - Tests validate core functionality: hash-based duplicate detection, multi-group handling, recursive directory scanning, and proper error handling - Output file generation and formatting verified - Performance validated for standard use cases (20+ files in under 30 seconds)**
  *by poslogica*
- [`6696d15`](https://github.com/poslogica/generalscripts/commit/6696d15f68f16d453849228599f75b4fc1b8d30e) **refactor: standardize naming conventions and fix code quality issues - Rename all PowerShell scripts to kebab-case for consistency - get-duplicate-files-with-progress.ps1 - patch-software-windows.ps1 - update-third-party-with-winget.ps1 - update-third-party-with-winget-examples.ps1 - update-winget-packages.ps1 - update-winget-packages-create-start-menu-shortcut.ps1 - update-winget-packages.bat - Rename documentation files to kebab-case - patch-software-windows.md - update-third-party-with-winget.md - Add comprehensive docstrings to PowerShell scripts with examples - Fix all PSScriptAnalyzer warnings: - Replace Write-Host with Write-Output/Write-LogMessage - Remove unused variables (\, \) - Add proper error handling in catch blocks - Rename \ to \ (avoid automatic variable overwrite) - Rename Write-Log function to Write-LogMessage (avoid cmdlet override) - Remove unused \ parameter - Use approved PowerShell verbs in function names - Add UTF-8 BOM encoding to files with non-ASCII characters - Rename functions to use singular nouns - Update README.md: - Change clone URL from Bitbucket to GitHub - Reorganize and expand Scripts Overview section - Add complete documentation for all patching scripts - Add Best Practices section - Add CI/CD & Automation section - Add GitHub Actions workflow for PowerShell script validation - Automatic syntax checking - PSScriptAnalyzer analysis - Runs on push and pull requests - All scripts now pass PSScriptAnalyzer analysis with 0 warnings**
  *by poslogica*
- [`bcd3f65`](https://github.com/poslogica/generalscripts/commit/bcd3f65070783cfd3c6818d1e2f60131f4b7999a) **update docs add action**
  *by poslogica*
- [`f3b26ea`](https://github.com/poslogica/generalscripts/commit/f3b26ea4ca141be0c4eee9e0b7422271d290adab) **Merged in development (pull request #10) update exclusions**
  *by poslogic*
- [`6218c1c`](https://github.com/poslogica/generalscripts/commit/6218c1c137424d20bddb174d2e348b1c2882ff53) **update exclusions**
  *by poslogica*


## 2025-08-29

- [`b910799`](https://github.com/poslogica/generalscripts/commit/b91079931d84dd71034dff641257fcdb8ec6447d) **Merged in development (pull request #9) Add index readme to windows patching script folder**
  *by poslogic*
- [`aa5800c`](https://github.com/poslogica/generalscripts/commit/aa5800c756293418e442f1b75979a0b394ee0885) **Add index readme to windows patching script folder**
  *by poslogica*
- [`bc8198c`](https://github.com/poslogica/generalscripts/commit/bc8198c98d10976d7551a02bcb660f4f03fd647e) **Merged in development (pull request #8) Add improved 3rd party update script**
  *by poslogic*
- [`e2b89e4`](https://github.com/poslogica/generalscripts/commit/e2b89e4217df76d52203e9881035a30c2d243ba1) **improve the wrapper script**
  *by poslogica*
- [`02bb4f4`](https://github.com/poslogica/generalscripts/commit/02bb4f436362f7b4bff2c62e348cade7af933953) **refactored improve winget upgrade powershell script**
  *by poslogica*
- [`a90f649`](https://github.com/poslogica/generalscripts/commit/a90f649fb021f1b6541ca1a583cc1d5b7876215d) **refactor patch script**
  *by poslogica*
- [`4a22186`](https://github.com/poslogica/generalscripts/commit/4a2218650a25c7e619b4bdfa28bc9ca138317295) **update patching script**
  *by poslogica*


## 2025-07-05

- [`0d53750`](https://github.com/poslogica/generalscripts/commit/0d53750fb9da9add865911ecc9c431f30e6bacd6) **Merged in development (pull request #7) update readme**
  *by poslogic*
- [`4db889d`](https://github.com/poslogica/generalscripts/commit/4db889de4c6efb895702f18816d02c6aab02ff0c) **update readme add ps script that scans for duplicate files and log the results to a log file**
  *by poslogica*


## 2024-11-15

- [`b8debb0`](https://github.com/poslogica/generalscripts/commit/b8debb03da5697ae0525678221f6f959991cf80b) **Merged in development (pull request #6) Development**
  *by Fuad Bagus*
- [`8760db6`](https://github.com/poslogica/generalscripts/commit/8760db68b40cfe24e852527d21ef51645e5dbacd) **update doc**
  *by fuadbagus*
- [`48624cd`](https://github.com/poslogica/generalscripts/commit/48624cde5ba6154f0557f6400f57d98bef0ab897) **Merged in Fuad-Bagus/resourcemd-edited-online-with-bitbucket-1731631382666 (pull request #5) resource.md edited online with Bitbucket**
  *by Fuad Bagus*
- [`cff7b63`](https://github.com/poslogica/generalscripts/commit/cff7b63493ee77e5f2ac83d15e520e1a2c6932be) **resource.md edited online with Bitbucket**
  *by Fuad Bagus*
- [`71b8b31`](https://github.com/poslogica/generalscripts/commit/71b8b31fd53236a5ade701d93e1f4091422447df) **Merged in development (pull request #4) Merged main into development**
  *by Fuad Bagus*
- [`6a1e27b`](https://github.com/poslogica/generalscripts/commit/6a1e27b6d45d8c0f45d4374b2c192454c15aecac) **Merged main into development**
  *by Fuad Bagus*
- [`252e3f2`](https://github.com/poslogica/generalscripts/commit/252e3f232f841893bfda2dc51eaf324ff2c764ec) **Merged in development (pull request #3) add podman md**
  *by Fuad Bagus*
- [`237d727`](https://github.com/poslogica/generalscripts/commit/237d727f9c7a3355354fb3519d001a62f3b1d638) **add podman md**
  *by fuadbagus*


## 2024-11-09

- [`5edf7dd`](https://github.com/poslogica/generalscripts/commit/5edf7ddc9d99fde080d83b93190713bae0429bf2) **Merged in development (pull request #2) Development**
  *by Fuad Bagus*
- [`0d5d321`](https://github.com/poslogica/generalscripts/commit/0d5d321673d1af6ba9c6410b28c928662c6bb7e7) **workaround for now. path of winget changed**
  *by fuadbagus*
- [`86d66e1`](https://github.com/poslogica/generalscripts/commit/86d66e123b667e39f5f6acb44056877d4ba0da63) **temp work around**
  *by fuadbagus*
- [`e8c37f4`](https://github.com/poslogica/generalscripts/commit/e8c37f4c85c15e9acb12e1886557f57c76f3bf5d) **update version info**
  *by fuadbagus*


## 2024-10-18

- [`d0161a1`](https://github.com/poslogica/generalscripts/commit/d0161a10946985c7a2ce53f4221d2df1b65582ed) **Merged in development (pull request #1) update readme**
  *by Fuad Bagus*
- [`d629160`](https://github.com/poslogica/generalscripts/commit/d62916012a7a36b7e80bf1c08b8c01b73f70abfb) **update readme**
  *by fuadbagus*
- [`5278ca7`](https://github.com/poslogica/generalscripts/commit/5278ca74a97eda5c88037e9de71e1a3e044323b6) **restructure script folder improve patching script add base README**
  *by fuadbagus*
- [`9104497`](https://github.com/poslogica/generalscripts/commit/91044971429255c7d366c1c50b59161a62a3db6f) **update readme**
  *by fuadbagus*
- [`1020d0c`](https://github.com/poslogica/generalscripts/commit/1020d0c95c067c32a542a39b0aaa0597c7c20fa6) **init add**
  *by fuadbagus*
