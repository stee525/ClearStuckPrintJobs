PrintQueue Monitor and Cleaner
A robust PowerShell script designed to monitor and clean print queues on Windows systems. It identifies print jobs stuck for over 3 minutes, clears them, and conditionally restarts the print spooler service if jobs cannot be cleared. The script ensures efficient handling of print queues and maintains concise logs.

Features
Monitors all printers for jobs stuck in the queue for more than 3 minutes.
Attempts to clean stuck print jobs.
Restarts the print spooler service only when necessary, ensuring minimal disruption.
Two log files:
PrintQueueCleanup.log: Logs successful actions.
PrintQueueErrors.log: Logs errors (e.g., permission issues or failed deletions).
Logs are replaced on each execution to keep the files lightweight.
Requirements
Windows 10 / Windows Server with:
PowerShell 5.1 or later.
Administrator privileges to manage the print spooler service.
Access to the print spooler service and permissions to delete print jobs.

Installation
1. Download the Script
Save the script as:
C:\Scripts\ClearStuckPrintJobs.ps1

2. Create the Directory
Ensure the directory C:\Scripts\ exists to store the script and logs.

Usage
Run the Script Manually
To execute the script manually, use the following command:
PowerShell -ExecutionPolicy Bypass -File "C:\Scripts\ClearStuckPrintJobs.ps1"

Automate with Task Scheduler
1. Create a New Task
Open the Task Scheduler.
Click Create Task.
2. Set Up the Trigger
Go to the Triggers tab and create a new trigger.
Choose Daily and set:
Repeat task every 10 minutes (or your desired interval).
3. Set Up the Action
a. Go to the Actions tab and create a new action.
b. In Program/script, enter:
powershell.exe
c. In Add arguments (optional), enter:
-ExecutionPolicy Bypass -File "C:\Scripts\ClearStuckPrintJobs.ps1"
d. Finalize and Test
Save the task.
Manually run it from the Task Scheduler to confirm functionality.


PrintQueue Monitor and Cleaner
A robust PowerShell script designed to monitor and clean print queues on Windows systems. It identifies print jobs stuck for over 3 minutes, clears them, and conditionally restarts the print spooler service if jobs cannot be cleared. The script ensures efficient handling of print queues and maintains concise logs.

Features
Monitors all printers for jobs stuck in the queue for more than 3 minutes.
Attempts to clean stuck print jobs.
Restarts the print spooler service only when necessary, ensuring minimal disruption.
Two log files:
PrintQueueCleanup.log: Logs successful actions.
PrintQueueErrors.log: Logs errors (e.g., permission issues or failed deletions).
Logs are replaced on each execution to keep the files lightweight.
Requirements
Windows 10 / Windows Server with:
PowerShell 5.1 or later.
Administrator privileges to manage the print spooler service.
Access to the print spooler service and permissions to delete print jobs.

Installation
1. Download the Script
Save the script as:
C:\Scripts\ClearStuckPrintJobs.ps1

2. Create the Directory
Ensure the directory C:\Scripts\ exists to store the script and logs.

Configuration
Adjust these variables in the script as needed:

Variable	Description	Default Value
$StuckThresholdMinutes	Threshold in minutes to detect stuck print jobs.	3 minutes
$RetryWaitMinutes	Wait time before rechecking for stuck print jobs.	1 minute
$LogFile	Path to the log file for successful actions.	C:\Scripts\PrintQueueCleanup.log
$ErrorLogFile	Path to the log file for errors.	C:\Scripts\PrintQueueErrors.log
Usage
Run the Script Manually
To execute the script manually, use the following command:
PowerShell -ExecutionPolicy Bypass -File "C:\Scripts\ClearStuckPrintJobs.ps1"

Automate with Task Scheduler
1. Create a New Task
Open the Task Scheduler.
Click Create Task.

2. Set Up the Trigger
Go to the Triggers tab and create a new trigger.
Choose Daily and set:
Repeat task every 10 minutes (or your desired interval).

3. Set Up the Action
Go to the Actions tab and create a new action.
In Program/script, enter:
powershell.exe
In Add arguments (optional), enter:
-ExecutionPolicy Bypass -File "C:\Scripts\ClearStuckPrintJobs.ps1"

4. Finalize and Test
Save the task.
Manually run it from the Task Scheduler to confirm functionality.
Logs

1. Successful Actions (PrintQueueCleanup.log)
Logs all successful actions, including identified and cleared print jobs.

Example:
2025-01-10 12:00:00 [INFO] - Starting print queue monitoring...
2025-01-10 12:00:01 [INFO] - Checking printer: PRINTER01
2025-01-10 12:00:02 [INFO] - No print jobs found for printer PRINTER01.
2025-01-10 12:00:03 [INFO] - Print queue monitoring completed.

2. Errors (PrintQueueErrors.log)
Logs all errors, including permission issues or failed attempts to clear print jobs.

Example:
2025-01-10 12:05:00 [ERROR] - Failed to delete print job ID=123 on printer PRINTER02: Access Denied
How It Works
Initial Check:

Monitors all printers for print jobs that have been in the queue for more than 3 minutes.
Cleaning Stuck Print Jobs:

Identifies and attempts to delete stuck print jobs.
Logs successful deletions in PrintQueueCleanup.log.
Recheck After 1 Minute:

Waits 1 minute and checks the queues again for remaining stuck jobs.
Conditional Spooler Restart:

If stuck jobs remain after both checks, the script restarts the print spooler service and logs the action.
Log Management:

Overwrites logs during each run to avoid excessive file size.
