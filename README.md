# Windows Large File Finder

> **Testing note:** This was tested by me to be working. User experience may vary.

Included script: `Find-WindowsLargeFiles.ps1`

```powershell
.\Find-WindowsLargeFiles.ps1
.\Find-WindowsLargeFiles.ps1 -ScanPath 'D:\' -MinimumSizeMB 1000 -Top 100
```

The script performs a read-only recursive scan and creates CSV and HTML reports for large files, matching folder totals and access errors.

Reports: `C:\Users\Public\Documents\LargeFileReports`

Exit codes: `0` success, `1` fatal error.

Large scans can take time and require access to the selected folders. Use at your own risk.

MIT License.
