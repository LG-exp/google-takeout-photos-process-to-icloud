Describe '1-correctDatesParallelA.ps1' {
    BeforeAll {
        $script:answers = @('', 'C:\\input', '')
        $script:answerIndex = 0
        Mock -CommandName Read-Host -MockWith { $script:answers[$script:answerIndex++] }
        Mock -CommandName Get-ChildItem -MockWith { [pscustomobject]@{ FullName = 'file1.jpg'; Name = 'file1.jpg'; LastWriteTime = Get-Date; CreationTime = Get-Date } }
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

    Context 'ExifTool invocation' {
        Mock -CommandName exiftool -MockWith { '2020:01:01 00:00:00' }
        It 'calls exiftool to read and write metadata' {
            . $PSScriptRoot/../1-correctDatesParallelA.ps1
            Assert-MockCalled -CommandName exiftool -Times 2
        }
    }

    Context 'Handles missing metadata' {
        Mock -CommandName exiftool -MockWith { '' }
        It 'does not throw when metadata is missing' {
            { . $PSScriptRoot/../1-correctDatesParallelA.ps1 } | Should -Not -Throw
        }
    }
}
