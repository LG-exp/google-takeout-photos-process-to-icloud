Describe '2-moveAlready.ps1' {
    BeforeAll {
        $script:answers = @('', 'C:\\list.txt', 'C:\\src', 'C:\\dest', 'C:\\log.txt', '')
        $script:answerIndex = 0
        Mock -CommandName Read-Host -MockWith { $script:answers[$script:answerIndex++] }
        Mock -CommandName Get-Content -MockWith { 'file1.jpg' }
    }

    Context 'Moves existing file' {
        $call = 0
        Mock -CommandName Test-Path -MockWith { param($path) if ($call -eq 0) { $call++; return $true } else { return $true } }
        Mock -CommandName Move-Item {}
        Mock -CommandName Out-File {}
        It 'calls Move-Item when file exists' {
            . $PSScriptRoot/../2-moveAlready.ps1
            Assert-MockCalled -CommandName Move-Item -Times 1
        }
    }

    Context 'Logs missing file' {
        $call = 0
        Mock -CommandName Test-Path -MockWith { param($path) if ($call -eq 0) { $call++; return $true } else { return $false } }
        Mock -CommandName Move-Item {}
        Mock -CommandName Out-File {}
        It 'writes to log when file missing' {
            . $PSScriptRoot/../2-moveAlready.ps1
            Assert-MockCalled -CommandName Move-Item -Times 0
            Assert-MockCalled -CommandName Out-File -Times 1
        }
    }
}
