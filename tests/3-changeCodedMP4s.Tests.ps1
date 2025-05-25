Describe '3-changeCodedMP4s.ps1' {
    BeforeAll {
        $script:answers = @('C:\\src', 'C:\\dest')
        $script:answerIndex = 0
        Mock -CommandName Read-Host -MockWith { $script:answers[$script:answerIndex++] }
        function ForEach-Object {
            param(
                [Parameter(ValueFromPipeline=$true)]$InputObject,
                [scriptblock]$Process,
                [int]$ThrottleLimit,
                [switch]$Parallel
            )
            begin { $items = @() }
            process { $items += $InputObject }
            end { foreach($item in $items){ & $Process.Invoke($item) } }
        }
    }

    Context 'Runs ffmpeg' {
        Mock -CommandName Get-ChildItem -MockWith { [pscustomobject]@{ FullName = 'clip.3gp'; BaseName = 'clip' } }
        Mock -CommandName Invoke-Expression {}
        It 'invokes ffmpeg command' {
            . $PSScriptRoot/../3-changeCodedMP4s.ps1
            Assert-MockCalled -CommandName Invoke-Expression -Times 1 -ParameterFilter { $Command -like '*ffmpeg*' }
        }
    }

    Context 'Handles no files' {
        Mock -CommandName Get-ChildItem -MockWith { @() }
        Mock -CommandName Invoke-Expression {}
        It 'does not call ffmpeg when no files found' {
            . $PSScriptRoot/../3-changeCodedMP4s.ps1
            Assert-MockCalled -CommandName Invoke-Expression -Times 0
        }
    }
}
