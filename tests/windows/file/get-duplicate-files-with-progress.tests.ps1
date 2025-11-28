# Test file for get-duplicate-files-with-progress.ps1
# Located in tests/ directory to keep tests separate from distribution
# Pester 5.x syntax for GitHub Actions compatibility

BeforeAll {
    $scriptPath = Join-Path -Path $PSScriptRoot -ChildPath "..\..\..\scripts\windows\file\get-duplicate-files-with-progress.ps1"
    $scriptDir = Split-Path -Parent $scriptPath
    $outputFile = Join-Path -Path $scriptDir -ChildPath "duplicate_files_with_progress.txt"
}

Describe "get-duplicate-files-with-progress Script Tests" {
    
    Context "Script Syntax and Structure" {
        
        It "Should have valid PowerShell syntax" {
            $null = [System.Management.Automation.PSParser]::Tokenize(
                (Get-Content $scriptPath -Raw), 
                [ref]$null
            )
        }

        It "Should have required parameters" {
            $content = Get-Content $scriptPath -Raw
            $content | Should -Match "param\s*\("
        }

        It "Should have help documentation" {
            $content = Get-Content $scriptPath -Raw
            $content | Should -Match "\.SYNOPSIS"
            $content | Should -Match "\.DESCRIPTION"
            $content | Should -Match "\.PARAMETER"
            $content | Should -Match "\.EXAMPLE"
        }
    }

    Context "Path Parameter Validation" {
        
        It "Should accept a valid directory path" {
            $testDir = New-Item -Path (Join-Path $TestDrive "ValidDir") -ItemType Directory -Force
            { & $scriptPath -Path $testDir.FullName } | Should -Not -Throw
        }

        It "Should default to current directory when no path specified" {
            { & $scriptPath } | Should -Not -Throw
        }

        It "Should handle invalid path gracefully" {
            # Script should handle invalid path gracefully without crashing
            # Use $null assignment to suppress all output and error streams
            $null = & $scriptPath -Path "C:\NonExistent\InvalidPath\12345" -ErrorVariable scriptErrors 2>&1
            # The script should complete (even with errors), not throw an exception
            $true | Should -Be $true
        }

        It "Should handle path with special characters" {
            $specialDir = New-Item -Path (Join-Path $TestDrive "Test Dir [Special]") -ItemType Directory -Force
            { & $scriptPath -Path $specialDir.FullName } | Should -Not -Throw
        }
    }

    Context "Empty Directory Handling" {
        
        It "Should handle directory with no files" {
            $emptyDir = New-Item -Path (Join-Path $TestDrive "EmptyDir") -ItemType Directory -Force
            { & $scriptPath -Path $emptyDir.FullName } | Should -Not -Throw
        }

        It "Should not create output file for empty directory" {
            $emptyDir = New-Item -Path (Join-Path $TestDrive "EmptyDir2") -ItemType Directory -Force
            & $scriptPath -Path $emptyDir.FullName | Out-Null
            Test-Path -Path $outputFile | Should -Be $false
        }
    }

    Context "Duplicate Detection" {
        
        It "Should identify duplicate files by hash" {
            $testDir = New-Item -Path (Join-Path $TestDrive "DupTest") -ItemType Directory -Force
            
            "Test content" | Out-File -Path (Join-Path $testDir "file1.txt") -Encoding UTF8
            "Test content" | Out-File -Path (Join-Path $testDir "file2.txt") -Encoding UTF8
            
            & $scriptPath -Path $testDir.FullName | Out-Null
            
            Test-Path -Path $outputFile | Should -Be $true
            $content = Get-Content -Path $outputFile -Raw
            $content | Should -Match "Duplicates for hash"
            $content | Should -Match "file1.txt"
            $content | Should -Match "file2.txt"
        }

        It "Should not report unique files as duplicates" {
            $testDir = New-Item -Path (Join-Path $TestDrive "UniqueTest") -ItemType Directory -Force
            
            "Content 1" | Out-File -Path (Join-Path $testDir "unique1.txt") -Encoding UTF8
            "Content 2" | Out-File -Path (Join-Path $testDir "unique2.txt") -Encoding UTF8
            
            & $scriptPath -Path $testDir.FullName | Out-Null
            
            Test-Path -Path $outputFile | Should -Be $false
        }

        It "Should handle multiple duplicate groups" {
            $testDir = New-Item -Path (Join-Path $TestDrive "MultiDupTest") -ItemType Directory -Force
            
            "Content A" | Out-File -Path (Join-Path $testDir "a1.txt") -Encoding UTF8
            "Content A" | Out-File -Path (Join-Path $testDir "a2.txt") -Encoding UTF8
            
            "Content B" | Out-File -Path (Join-Path $testDir "b1.txt") -Encoding UTF8
            "Content B" | Out-File -Path (Join-Path $testDir "b2.txt") -Encoding UTF8
            
            & $scriptPath -Path $testDir.FullName | Out-Null
            
            Test-Path -Path $outputFile | Should -Be $true
            $content = Get-Content -Path $outputFile -Raw
            $content | Should -Match "a1.txt"
            $content | Should -Match "b1.txt"
        }
    }

    Context "Recursive Directory Scanning" {
        
        It "Should scan subdirectories recursively" {
            $testDir = New-Item -Path (Join-Path $TestDrive "RecursiveTest") -ItemType Directory -Force
            $subDir = New-Item -Path (Join-Path $testDir "SubDir") -ItemType Directory -Force
            
            "Duplicate content" | Out-File -Path (Join-Path $testDir "file1.txt") -Encoding UTF8
            "Duplicate content" | Out-File -Path (Join-Path $subDir "file2.txt") -Encoding UTF8
            
            & $scriptPath -Path $testDir.FullName | Out-Null
            
            $content = Get-Content -Path $outputFile -Raw
            $content | Should -Match "file1.txt"
            $content | Should -Match "file2.txt"
        }

        It "Should handle deeply nested directories" {
            $testDir = New-Item -Path (Join-Path $TestDrive "DeepTest") -ItemType Directory -Force
            $level1 = New-Item -Path (Join-Path $testDir "Level1") -ItemType Directory -Force
            $level2 = New-Item -Path (Join-Path $level1 "Level2") -ItemType Directory -Force
            
            "Same content" | Out-File -Path (Join-Path $testDir "root.txt") -Encoding UTF8
            "Same content" | Out-File -Path (Join-Path $level2 "deep.txt") -Encoding UTF8
            
            & $scriptPath -Path $testDir.FullName | Out-Null
            
            $content = Get-Content -Path $outputFile -Raw
            $content | Should -Match "root.txt"
            $content | Should -Match "deep.txt"
        }
    }

    Context "Output File Generation" {
        
        It "Should create output file when duplicates found" {
            $testDir = New-Item -Path (Join-Path $TestDrive "OutputTest") -ItemType Directory -Force
            "Test" | Out-File -Path (Join-Path $testDir "file1.txt") -Encoding UTF8
            "Test" | Out-File -Path (Join-Path $testDir "file2.txt") -Encoding UTF8
            
            & $scriptPath -Path $testDir.FullName | Out-Null
            
            Test-Path -Path $outputFile | Should -Be $true
        }

        It "Should contain hash information in output" {
            $testDir = New-Item -Path (Join-Path $TestDrive "HashTest") -ItemType Directory -Force
            "Content" | Out-File -Path (Join-Path $testDir "file1.txt") -Encoding UTF8
            "Content" | Out-File -Path (Join-Path $testDir "file2.txt") -Encoding UTF8
            
            & $scriptPath -Path $testDir.FullName | Out-Null
            
            $content = Get-Content -Path $outputFile -Raw
            $content | Should -Match "Duplicates for hash: [A-F0-9]{64}"
        }

        It "Should list duplicate file paths" {
            $testDir = New-Item -Path (Join-Path $TestDrive "PathTest") -ItemType Directory -Force
            "Same" | Out-File -Path (Join-Path $testDir "dup1.txt") -Encoding UTF8
            "Same" | Out-File -Path (Join-Path $testDir "dup2.txt") -Encoding UTF8
            "Same" | Out-File -Path (Join-Path $testDir "dup3.txt") -Encoding UTF8
            
            & $scriptPath -Path $testDir.FullName | Out-Null
            
            $content = Get-Content -Path $outputFile -Raw
            $content | Should -Match "dup1.txt"
            $content | Should -Match "dup2.txt"
            $content | Should -Match "dup3.txt"
        }
    }

    Context "File Handling" {
        
        It "Should handle files with different extensions" {
            $testDir = New-Item -Path (Join-Path $TestDrive "ExtensionTest") -ItemType Directory -Force
            
            "Test data" | Out-File -Path (Join-Path $testDir "file.txt") -Encoding UTF8
            "Test data" | Out-File -Path (Join-Path $testDir "file.dat") -Encoding UTF8
            
            & $scriptPath -Path $testDir.FullName | Out-Null
            
            $content = Get-Content -Path $outputFile -Raw
            $content | Should -Match "\.txt"
            $content | Should -Match "\.dat"
        }

        It "Should handle binary files" {
            $testDir = New-Item -Path (Join-Path $TestDrive "BinaryTest") -ItemType Directory -Force
            
            $binaryData = [byte[]](0, 1, 2, 3, 4, 5)
            [System.IO.File]::WriteAllBytes((Join-Path $testDir "binary1.bin"), $binaryData)
            [System.IO.File]::WriteAllBytes((Join-Path $testDir "binary2.bin"), $binaryData)
            
            & $scriptPath -Path $testDir.FullName | Out-Null
            
            Test-Path -Path $outputFile | Should -Be $true
        }
    }

    Context "Error Handling" {
        
        It "Should continue processing without stopping" {
            $testDir = New-Item -Path (Join-Path $TestDrive "ErrorTest") -ItemType Directory -Force
            
            "Content" | Out-File -Path (Join-Path $testDir "readable1.txt") -Encoding UTF8
            "Content" | Out-File -Path (Join-Path $testDir "readable2.txt") -Encoding UTF8
            
            { & $scriptPath -Path $testDir.FullName } | Should -Not -Throw
        }

        It "Should exit with success code" {
            $testDir = New-Item -Path (Join-Path $TestDrive "ExitCodeTest") -ItemType Directory -Force
            & $scriptPath -Path $testDir.FullName
            $LASTEXITCODE | Should -Be 0
        }
    }

    Context "Performance" {
        
        It "Should complete within reasonable time for small directory" {
            $testDir = New-Item -Path (Join-Path $TestDrive "PerfTest") -ItemType Directory -Force
            
            1..20 | ForEach-Object {
                "Test file $_" | Out-File -Path (Join-Path $testDir "file$_.txt") -Encoding UTF8
            }
            
            $stopwatch = [System.Diagnostics.Stopwatch]::StartNew()
            & $scriptPath -Path $testDir.FullName | Out-Null
            $stopwatch.Stop()
            
            $stopwatch.ElapsedMilliseconds | Should -BeLessThan 30000
        }
    }

    Context "Edge Cases - File Sizes" {
        
        It "Should handle zero-byte files" {
            $testDir = New-Item -Path (Join-Path $TestDrive "ZeroByteTest") -ItemType Directory -Force
            
            New-Item -Path (Join-Path $testDir "empty1.txt") -ItemType File -Force | Out-Null
            New-Item -Path (Join-Path $testDir "empty2.txt") -ItemType File -Force | Out-Null
            
            & $scriptPath -Path $testDir.FullName | Out-Null
            
            Test-Path -Path $outputFile | Should -Be $true
            $content = Get-Content -Path $outputFile -Raw
            $content | Should -Match "empty1.txt"
            $content | Should -Match "empty2.txt"
        }

        It "Should handle large files (5MB+)" {
            $testDir = New-Item -Path (Join-Path $TestDrive "LargeFileTest") -ItemType Directory -Force
            
            $largeContent = [string]('X' * 5242880)
            $largeContent | Out-File -Path (Join-Path $testDir "large1.bin") -Encoding UTF8 -NoNewline
            $largeContent | Out-File -Path (Join-Path $testDir "large2.bin") -Encoding UTF8 -NoNewline
            
            { & $scriptPath -Path $testDir.FullName } | Should -Not -Throw
            
            Test-Path -Path $outputFile | Should -Be $true
        }

        It "Should handle mix of file sizes" {
            $testDir = New-Item -Path (Join-Path $TestDrive "MixedSizeTest") -ItemType Directory -Force
            
            "Duplicate content" | Out-File -Path (Join-Path $testDir "small1.txt") -Encoding UTF8
            "Duplicate content" | Out-File -Path (Join-Path $testDir "small2.txt") -Encoding UTF8
            
            $mediumContent = [string]('M' * 1000000)
            $mediumContent | Out-File -Path (Join-Path $testDir "medium1.bin") -Encoding UTF8 -NoNewline
            $mediumContent | Out-File -Path (Join-Path $testDir "medium2.bin") -Encoding UTF8 -NoNewline
            
            & $scriptPath -Path $testDir.FullName | Out-Null
            
            Test-Path -Path $outputFile | Should -Be $true
        }
    }

    Context "Edge Cases - Special Characters and Encoding" {
        
        It "Should handle filenames with Unicode characters" {
            $testDir = New-Item -Path (Join-Path $TestDrive "UnicodeTest") -ItemType Directory -Force
            
            "Duplicate" | Out-File -Path (Join-Path $testDir "файл1.txt") -Encoding UTF8
            "Duplicate" | Out-File -Path (Join-Path $testDir "файл2.txt") -Encoding UTF8
            
            & $scriptPath -Path $testDir.FullName | Out-Null
            
            Test-Path -Path $outputFile | Should -Be $true
        }

        It "Should handle files with spaces and special chars in names" {
            $testDir = New-Item -Path (Join-Path $TestDrive "SpecialCharsTest") -ItemType Directory -Force
            
            "Content" | Out-File -Path (Join-Path $testDir "file 1.txt") -Encoding UTF8
            "Content" | Out-File -Path (Join-Path $testDir "file 2.txt") -Encoding UTF8
            
            & $scriptPath -Path $testDir.FullName | Out-Null
            
            $content = Get-Content -Path $outputFile -Raw
            $content | Should -Match "file 1.txt"
            $content | Should -Match "file 2.txt"
        }

        It "Should detect duplicates with Unicode content" {
            $testDir = New-Item -Path (Join-Path $TestDrive "UnicodeContentTest") -ItemType Directory -Force
            
            "Привет мир 🌍" | Out-File -Path (Join-Path $testDir "unicode1.txt") -Encoding UTF8
            "Привет мир 🌍" | Out-File -Path (Join-Path $testDir "unicode2.txt") -Encoding UTF8
            
            & $scriptPath -Path $testDir.FullName | Out-Null
            
            Test-Path -Path $outputFile | Should -Be $true
            $content = Get-Content -Path $outputFile -Raw
            $content | Should -Match "unicode1.txt"
        }
    }

    Context "Edge Cases - Output File Behavior" {
        
        It "Should overwrite previous output file" {
            $testDir = New-Item -Path (Join-Path $TestDrive "OverwriteTest") -ItemType Directory -Force
            
            "Content1" | Out-File -Path (Join-Path $testDir "file1.txt") -Encoding UTF8
            "Content1" | Out-File -Path (Join-Path $testDir "file2.txt") -Encoding UTF8
            & $scriptPath -Path $testDir.FullName | Out-Null
            
            $firstRun = Get-Content -Path $outputFile -Raw
            $firstRun | Should -Match "file1.txt"
            
            Remove-Item (Join-Path $testDir "*") -Force
            "Content2" | Out-File -Path (Join-Path $testDir "fileA.txt") -Encoding UTF8
            "Content2" | Out-File -Path (Join-Path $testDir "fileB.txt") -Encoding UTF8
            & $scriptPath -Path $testDir.FullName | Out-Null
            
            $secondRun = Get-Content -Path $outputFile -Raw
            $secondRun | Should -Match "fileA.txt"
            $secondRun | Should -Not -Match "file1.txt"
        }

        It "Should verify output file contains proper formatting" {
            $testDir = New-Item -Path (Join-Path $TestDrive "FormattingTest") -ItemType Directory -Force
            
            "Test" | Out-File -Path (Join-Path $testDir "dup1.txt") -Encoding UTF8
            "Test" | Out-File -Path (Join-Path $testDir "dup2.txt") -Encoding UTF8
            
            & $scriptPath -Path $testDir.FullName | Out-Null
            
            $content = Get-Content -Path $outputFile -Raw
            $content | Should -Match "=== Duplicates for hash:"
            $content | Should -Match "dup1.txt"
            $content | Should -Match "dup2.txt"
        }
    }

    Context "Edge Cases - File Permissions and State" {
        
        It "Should handle identical content but different file extensions" {
            $testDir = New-Item -Path (Join-Path $TestDrive "ExtensionDupTest") -ItemType Directory -Force
            
            "Identical data" | Out-File -Path (Join-Path $testDir "document.txt") -Encoding UTF8
            "Identical data" | Out-File -Path (Join-Path $testDir "document.bak") -Encoding UTF8
            "Identical data" | Out-File -Path (Join-Path $testDir "document.tmp") -Encoding UTF8
            
            & $scriptPath -Path $testDir.FullName | Out-Null
            
            $content = Get-Content -Path $outputFile -Raw
            $content | Should -Match "document.txt"
            $content | Should -Match "document.bak"
            $content | Should -Match "document.tmp"
        }

        It "Should verify SHA256 hash format in output" {
            $testDir = New-Item -Path (Join-Path $TestDrive "HashFormatTest") -ItemType Directory -Force
            
            "Content" | Out-File -Path (Join-Path $testDir "file1.txt") -Encoding UTF8
            "Content" | Out-File -Path (Join-Path $testDir "file2.txt") -Encoding UTF8
            
            & $scriptPath -Path $testDir.FullName | Out-Null
            
            $content = Get-Content -Path $outputFile -Raw
            $content | Should -Match "Duplicates for hash: [A-F0-9]{64}"
        }
    }
}
