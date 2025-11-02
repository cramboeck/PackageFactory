<#
.SYNOPSIS
    Pester tests for PackageFactory module
.DESCRIPTION
    Unit and integration tests for PackageFactory
#>

BeforeAll {
    # Import module
    $modulePath = Join-Path $PSScriptRoot '..\src\PackageFactory.psd1'
    Import-Module $modulePath -Force

    # Setup test environment
    $script:testRoot = Join-Path $TestDrive 'PackageFactoryTests'
    $script:testOutput = Join-Path $script:testRoot 'Output'
    $script:testConfig = Join-Path $script:testRoot 'Config'
    $script:testTemplates = Join-Path $script:testRoot 'Generator\Templates\Autopilot-PSADT-4x'

    # Create test directories
    New-Item -Path $script:testOutput -ItemType Directory -Force | Out-Null
    New-Item -Path $script:testConfig -ItemType Directory -Force | Out-Null
    New-Item -Path $script:testTemplates -ItemType Directory -Force | Out-Null

    # Create minimal template files
    $templateContent = @'
# Template for {{APP_NAME}}
Vendor: {{APP_VENDOR}}
Version: {{APP_VERSION}}
Architecture: {{APP_ARCH}}
Language: {{APP_LANG}}
'@
    Set-Content -Path (Join-Path $script:testTemplates 'Invoke-AppDeployToolkit.ps1.template') -Value $templateContent
    Set-Content -Path (Join-Path $script:testTemplates 'Detect-Application.ps1.template') -Value "# Detect {{APP_NAME}}"

    # Create test config
    $testConfigContent = @{
        CompanyPrefix   = 'TEST'
        DefaultArch     = 'x64'
        DefaultLang     = 'EN'
        IncludePSADT    = $false
        AutoOpenBrowser = $false
        OutputPath      = $script:testOutput
    } | ConvertTo-Json

    Set-Content -Path (Join-Path $script:testConfig 'settings.json') -Value $testConfigContent
}

Describe 'PackageFactory Module' {
    Context 'Module Import' {
        It 'Should import module successfully' {
            Get-Module PackageFactory | Should -Not -BeNullOrEmpty
        }

        It 'Should export New-AutopilotPackage function' {
            Get-Command New-AutopilotPackage -Module PackageFactory | Should -Not -BeNullOrEmpty
        }

        It 'Should export Start-PackageFactoryServer function' {
            Get-Command Start-PackageFactoryServer -Module PackageFactory | Should -Not -BeNullOrEmpty
        }

        It 'Should export Get-PackageFactoryPackage function' {
            Get-Command Get-PackageFactoryPackage -Module PackageFactory | Should -Not -BeNullOrEmpty
        }

        It 'Should export Remove-PackageFactoryPackage function' {
            Get-Command Remove-PackageFactoryPackage -Module PackageFactory | Should -Not -BeNullOrEmpty
        }
    }

    Context 'Module Manifest' {
        BeforeAll {
            $script:manifest = Test-ModuleManifest -Path (Join-Path $PSScriptRoot '..\src\PackageFactory.psd1')
        }

        It 'Should have valid manifest' {
            $script:manifest | Should -Not -BeNullOrEmpty
        }

        It 'Should have correct version' {
            $script:manifest.Version | Should -Match '^\d+\.\d+\.\d+$'
        }

        It 'Should have author' {
            $script:manifest.Author | Should -Be 'Christoph Ramböck'
        }

        It 'Should have description' {
            $script:manifest.Description | Should -Not -BeNullOrEmpty
        }

        It 'Should require PowerShell 5.1 or higher' {
            $script:manifest.PowerShellVersion | Should -BeGreaterOrEqual ([version]'5.1')
        }
    }
}

Describe 'Get-PackageFactoryPackage' {
    Context 'Empty output directory' {
        It 'Should return empty array when no packages exist' {
            $result = Get-PackageFactoryPackage -OutputPath $script:testOutput
            $result | Should -BeNullOrEmpty
        }
    }

    Context 'With packages' {
        BeforeAll {
            # Create test package directories
            $pkg1 = Join-Path $script:testOutput 'TEST_Adobe_Reader_24.1.0_x64'
            $pkg2 = Join-Path $script:testOutput 'TEST_7Zip_23.01_x64'
            New-Item -Path $pkg1 -ItemType Directory -Force | Out-Null
            New-Item -Path $pkg2 -ItemType Directory -Force | Out-Null
            Set-Content -Path (Join-Path $pkg1 'README.md') -Value '# Test Package 1'
            Set-Content -Path (Join-Path $pkg2 'Invoke-AppDeployToolkit.ps1') -Value '# Deploy script'
        }

        It 'Should return all packages' {
            $result = Get-PackageFactoryPackage -OutputPath $script:testOutput
            $result.Count | Should -Be 2
        }

        It 'Should have correct properties' {
            $result = Get-PackageFactoryPackage -OutputPath $script:testOutput | Select-Object -First 1
            $result.Name | Should -Not -BeNullOrEmpty
            $result.Path | Should -Not -BeNullOrEmpty
            $result.Created | Should -BeOfType [DateTime]
        }

        It 'Should detect README existence' {
            $result = Get-PackageFactoryPackage -OutputPath $script:testOutput | Where-Object { $_.Name -eq 'TEST_Adobe_Reader_24.1.0_x64' }
            $result.HasReadme | Should -Be $true
        }

        It 'Should detect deploy script existence' {
            $result = Get-PackageFactoryPackage -OutputPath $script:testOutput | Where-Object { $_.Name -eq 'TEST_7Zip_23.01_x64' }
            $result.HasDeployScript | Should -Be $true
        }
    }
}

Describe 'Private Functions' {
    Context 'Expand-PackageFactoryTemplate' {
        It 'Should replace placeholders correctly' {
            $content = "Hello {{NAME}}, version {{VERSION}}"
            $replacements = @{
                '{{NAME}}'    = 'TestApp'
                '{{VERSION}}' = '1.0.0'
            }
            $result = Expand-PackageFactoryTemplate -Content $content -Replacements $replacements
            $result | Should -Be 'Hello TestApp, version 1.0.0'
        }

        It 'Should handle multiple occurrences of same placeholder' {
            $content = "{{NAME}} is {{NAME}}"
            $replacements = @{
                '{{NAME}}' = 'Test'
            }
            $result = Expand-PackageFactoryTemplate -Content $content -Replacements $replacements
            $result | Should -Be 'Test is Test'
        }
    }
}

AfterAll {
    # Cleanup
    Remove-Module PackageFactory -Force -ErrorAction SilentlyContinue
}
