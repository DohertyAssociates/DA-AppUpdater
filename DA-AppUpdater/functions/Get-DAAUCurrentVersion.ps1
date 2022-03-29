function Get-DAAUCurrentVersion{
    #Get current installed version
    [xml]$About = Get-Content "$WorkingDir\config\about.xml" -Encoding UTF8 -ErrorAction SilentlyContinue
    $Script:DAAUCurrentVersion = $About.app.version
}