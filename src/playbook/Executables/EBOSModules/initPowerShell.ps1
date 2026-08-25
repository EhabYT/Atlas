$windir = [Environment]::GetFolderPath('Windows')

# Add EBOS' PowerShell modules
$env:PSModulePath += ";$windir\EBOSModules\Scripts\Modules"