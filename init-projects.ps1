$ErrorActionPreference = "Stop"

function Download-Project {
    param ([string]$Url, [string]$Name)
    Write-Host "Downloading $Name..."
    $ZipFile = "$Name.zip"
    Invoke-WebRequest -Uri $Url -OutFile $ZipFile
    Write-Host "Extracting $Name..."
    Expand-Archive -Path $ZipFile -DestinationPath "backend" -Force
    Remove-Item $ZipFile
    Write-Host "$Name Ready."
}

if (-not (Test-Path "backend")) { New-Item -ItemType Directory -Path "backend" }

# URLs with %20 for spaces and explicit parameters
$DiscoveryUrl = "https://start.spring.io/starter.zip?type=maven-project&language=java&bootVersion=3.2.1&baseDir=discovery-service&groupId=com.cvscreener&artifactId=discovery-service&name=discovery-service&description=Service%20Registry&packageName=com.cvscreener.discovery&packaging=jar&javaVersion=17&dependencies=cloud-eureka-server"
Download-Project -Url $DiscoveryUrl -Name "discovery-service"

$GatewayUrl = "https://start.spring.io/starter.zip?type=maven-project&language=java&bootVersion=3.2.1&baseDir=api-gateway&groupId=com.cvscreener&artifactId=api-gateway&name=api-gateway&description=API%20Gateway&packageName=com.cvscreener.gateway&packaging=jar&javaVersion=17&dependencies=cloud-eureka,cloud-gateway"
Download-Project -Url $GatewayUrl -Name "api-gateway"

$CvUrl = "https://start.spring.io/starter.zip?type=maven-project&language=java&bootVersion=3.2.1&baseDir=cv-ingestion-service&groupId=com.cvscreener&artifactId=cv-ingestion-service&name=cv-ingestion-service&description=CV%20Ingestion&packageName=com.cvscreener.ingestion&packaging=jar&javaVersion=17&dependencies=web,data-jpa,h2,kafka,cloud-eureka,lombok"
Download-Project -Url $CvUrl -Name "cv-ingestion-service"

$AiUrl = "https://start.spring.io/starter.zip?type=maven-project&language=java&bootVersion=3.2.1&baseDir=ai-scoring-service&groupId=com.cvscreener&artifactId=ai-scoring-service&name=ai-scoring-service&description=AI%20Scoring&packageName=com.cvscreener.scoring&packaging=jar&javaVersion=17&dependencies=web,data-jpa,h2,kafka,cloud-eureka,lombok,spring-ai-ollama,spring-ai-bedrock"
Download-Project -Url $AiUrl -Name "ai-scoring-service"
