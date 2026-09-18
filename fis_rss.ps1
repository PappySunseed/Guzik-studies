$inputPath = "feed.xml"   # Change this if your file has a different name
$outputPath = "feed_fixed.xml"

[xml]$xml = Get-Content -Path $inputPath -Encoding UTF8

# Ensure namespace declarations are preserved or added correctly
$rss = $xml.rss
if (-not $rss.GetAttribute("xmlns:itunes")) {
    $rss.SetAttribute("xmlns:itunes", "http://www.itunes.com/dtds/podcast-1.0.dtd")
}

$counter = 1
foreach ($item in $xml.rss.channel.item) {
    # 1. Clean title special characters & ensure description exists
    if (-not $item.description) {
        $elem = $xml.CreateElement("description")
        $elem.InnerText = $item.title
        $item.AppendChild($elem)
    }

    # 2. Fix GUID to be robust and valid
    if ($item.guid) {
        # Keep text clean or make it a stable ID string
        $item.guid.InnerText = "episode-$counter"
        $item.guid.SetAttribute("isPermaLink", "false")
    }

    # 3. Add a fallback pubDate if missing (spaced 1 day apart so apps sort them)
    if (-not $item.pubDate) {
        $dateElem = $xml.CreateElement("pubDate")
        $dateElem.InnerText = (Get-Date).AddDays(-27 + $counter).ToString("r")
        $item.AppendChild($dateElem)
    }

    $counter++
}

# Save the properly formatted and escaped XML
$xml.Save("$PSScriptRoot\$outputPath")
Write-Host "Success! Created fixed file at $outputPath" -ForegroundColor Green