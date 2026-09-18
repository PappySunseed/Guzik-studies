$inputPath = "feed.xml"
$outputPath = "feed_fixed.xml"

# Added -Raw so it reads the file as a single text block
[xml]$xml = Get-Content -Path $inputPath -Raw -Encoding UTF8

$rss = $xml.rss
if (-not $rss.GetAttribute("xmlns:itunes")) {
    $rss.SetAttribute("xmlns:itunes", "http://www.itunes.com/dtds/podcast-1.0.dtd")
}

$counter = 1
foreach ($item in $xml.rss.channel.item) {
    if (-not $item.description) {
        $elem = $xml.CreateElement("description")
        $elem.InnerText = $item.title
        $item.AppendChild($elem)
    }

    if ($item.guid) {
        $item.guid.InnerText = "episode-$counter"
        $item.guid.SetAttribute("isPermaLink", "false")
    }

    if (-not $item.pubDate) {
        $dateElem = $xml.CreateElement("pubDate")
        $dateElem.InnerText = (Get-Date).AddDays(-27 + $counter).ToString("r")
        $item.AppendChild($dateElem)
    }

    $counter++
}

$xml.Save("$PSScriptRoot\$outputPath")
Write-Host "Success! Created fixed file at $outputPath" -ForegroundColor Green