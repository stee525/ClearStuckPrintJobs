# Configuration
$LogFile = "C:\Scripts\PrintQueueCleanup.log"  # Log file for successful actions
$ErrorLogFile = "C:\Scripts\PrintQueueErrors.log"  # Log file for errors
$StuckThresholdMinutes = 3  # Threshold in minutes to identify stuck print jobs
$RetryWaitMinutes = 1  # Wait time in minutes before rechecking for stuck print jobs

# Function: Logs successful actions, overwrites the file on each run
function Log {
    param ([string]$Message, [string]$Type = "INFO")
    $Timestamp = Get-Date -Format "yyyy-MM-dd HH:mm:ss"
    "$Timestamp [$Type] - $Message" | Set-Content -Path $LogFile
}

# Function: Logs errors, overwrites the file on each run
function LogError {
    param ([string]$Message)
    $Timestamp = Get-Date -Format "yyyy-MM-dd HH:mm:ss"
    "$Timestamp [ERROR] - $Message" | Set-Content -Path $ErrorLogFile
}

# Function: Deletes a print job for a specific printer
function Remove-PrintJobWMI {
    param (
        [string]$PrinterName,
        [uint32]$JobId
    )
    try {
        # Attempt to delete the print job
        Remove-PrintJob -PrinterName $PrinterName -ID $JobId -ErrorAction Stop
        Log "Deleted print job ID=$JobId on printer ${PrinterName} successfully."
    } catch {
        # Log any errors encountered while deleting the print job
        LogError "Failed to delete print job ID=$JobId on printer ${PrinterName}: $_"
    }
}

# Function: Checks and clears stuck print jobs
function CheckAndClearPrintJobs {
    param ([int]$ThresholdMinutes)

    # Retrieve all printers that are online
    $Printers = Get-Printer | Where-Object { $_.PrinterStatus -ne "Offline" }
    $FoundStuckJobs = $false

    foreach ($Printer in $Printers) {
        $PrinterName = $Printer.Name
        Log "Checking printer: ${PrinterName}"

        # Retrieve all print jobs for the printer
        $PrintJobs = Get-PrintJob -PrinterName $PrinterName -ErrorAction SilentlyContinue

        if ($PrintJobs) {
            foreach ($Job in $PrintJobs) {
                # Calculate the age of the print job in minutes
                $JobAgeMinutes = ((Get-Date) - $Job.SubmittedTime).TotalMinutes

                if ($JobAgeMinutes -ge $ThresholdMinutes) {
                    Log "Found stuck print job: ID=$($Job.JobId), Age=$([math]::Round($JobAgeMinutes, 2)) minutes, Printer=${PrinterName}"
                    $FoundStuckJobs = $true

                    # Attempt to delete the stuck print job
                    Remove-PrintJobWMI -PrinterName $PrinterName -JobId $Job.JobId
                }
            }
        } else {
            # Log if no print jobs are found for the printer
            Log "No print jobs found for printer ${PrinterName}."
        }
    }

    return $FoundStuckJobs
}

# Main script logic
Log "Starting print queue monitoring..."
$StuckJobsFound = CheckAndClearPrintJobs -ThresholdMinutes $StuckThresholdMinutes

# If stuck print jobs are found, wait and recheck
if ($StuckJobsFound) {
    Log "Waiting $RetryWaitMinutes minutes and rechecking."
    Start-Sleep -Seconds ($RetryWaitMinutes * 60)

    $StuckJobsFoundAfterRetry = CheckAndClearPrintJobs -ThresholdMinutes $StuckThresholdMinutes

    # Restart the spooler service if stuck jobs still exist after rechecking
    if ($StuckJobsFoundAfterRetry) {
        Log "Stuck print jobs could not be cleared. Restarting the spooler service."

        try {
            Stop-Service -Name Spooler -Force -ErrorAction Stop
            Log "Spooler service stopped."
        } catch {
            LogError "Failed to stop the spooler service: $_"
        }

        Start-Sleep -Seconds 5

        try {
            Start-Service -Name Spooler -ErrorAction Stop
            Log "Spooler service restarted."
        } catch {
            LogError "Failed to restart the spooler service: $_"
        }
    } else {
        Log "All stuck print jobs successfully cleared."
    }
} else {
    # Log if no stuck jobs are found and no spooler restart is needed
    Log "No stuck print jobs found. Spooler service restart not required."
}

Log "Print queue monitoring completed."
