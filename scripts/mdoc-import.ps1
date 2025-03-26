function Write-XmlToScreen ([xml]$xml)
{
    $StringWriter = New-Object System.IO.StringWriter;
    $XmlWriter = New-Object System.Xml.XmlTextWriter $StringWriter;
    $XmlWriter.Formatting = "indented";
    $xml.WriteTo($XmlWriter);
    $XmlWriter.Flush();
    $StringWriter.Flush();
    Write-Output $StringWriter.ToString();
}

# Get the current frameworks file.
$fileName = (Resolve-Path "frameworks.xml")
Write-Host $fileName

$data = Get-Content -Path $fileName
$xmlData = [xml]$data

foreach ($framework in $xmlData.Frameworks.Framework)
{
    $prefix = $framework.attributes['Source'].value
    Write-Host $prefix
    $documentationFiles = (Get-ChildItem -Path $prefix -Filter *.xml -Recurse -ErrorAction SilentlyContinue -Force)
    foreach($docXml in $documentationFiles)
    {
        $targetImport = $docXml
        $importElement = $xmlData.CreateElement("import")
        $importElement.InnerText = $targetImport
        $framework.AppendChild($importElement)
    }
}

# Write-XmlToScreen $xmlData

$xmlData.Save($fileName)
