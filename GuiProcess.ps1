# Simple GUI wrapper for the processing scripts
Add-Type -AssemblyName System.Windows.Forms
Add-Type -AssemblyName System.Drawing

$form = New-Object System.Windows.Forms.Form
$form.Text = 'Google Takeout Processor'
$form.Size = New-Object System.Drawing.Size(400,180)
$form.StartPosition = 'CenterScreen'

$label = New-Object System.Windows.Forms.Label
$label.Text = 'Select Google Takeout folder:'
$label.AutoSize = $true
$label.Location = New-Object System.Drawing.Point(10,20)
$form.Controls.Add($label)

$textBox = New-Object System.Windows.Forms.TextBox
$textBox.Location = New-Object System.Drawing.Point(10,40)
$textBox.Width = 280
$form.Controls.Add($textBox)

$browse = New-Object System.Windows.Forms.Button
$browse.Text = 'Browse...'
$browse.Location = New-Object System.Drawing.Point(300,38)
$form.Controls.Add($browse)

$run = New-Object System.Windows.Forms.Button
$run.Text = 'Run'
$run.Location = New-Object System.Drawing.Point(10,80)
$form.Controls.Add($run)

$progressBar = New-Object System.Windows.Forms.ProgressBar
$progressBar.Style = 'Marquee'
$progressBar.Location = New-Object System.Drawing.Point(10,120)
$progressBar.Width = 360
$progressBar.Visible = $false
$form.Controls.Add($progressBar)

$folderDialog = New-Object System.Windows.Forms.FolderBrowserDialog

$browse.add_Click({
    if ($folderDialog.ShowDialog() -eq [System.Windows.Forms.DialogResult]::OK) {
        $textBox.Text = $folderDialog.SelectedPath
    }
})

$run.add_Click({
    $folder = $textBox.Text
    if (-not (Test-Path $folder)) {
        [System.Windows.Forms.MessageBox]::Show('Please select a valid folder.')
        return
    }
    $progressBar.Visible = $true
    $run.Enabled = $false
    $browse.Enabled = $false

    $job = Start-Job -ArgumentList $folder -ScriptBlock {
        param($dir)
        & "$PSScriptRoot\1-correctDatesParallelA.ps1" -TargetDirectory $dir -NoPause
    }

    $timer = New-Object System.Windows.Forms.Timer
    $timer.Interval = 1000
    $timer.add_Tick({
        if ($job.State -eq 'Completed') {
            $timer.Stop()
            $progressBar.Visible = $false
            $run.Enabled = $true
            $browse.Enabled = $true
            [System.Windows.Forms.MessageBox]::Show('Processing complete.')
        }
    })
    $timer.Start()
})

[System.Windows.Forms.Application]::Run($form)
