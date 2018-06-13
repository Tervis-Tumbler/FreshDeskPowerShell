function Set-FreshDeskAPIKey {
    param (
        $APIKey
    )
    $Script:APIKey = $APIKey
    #Set-FreshDeskCredential -Username $APIKey -Password "X"
    Set-FreshDeskCredential -Username $APIKey -Password $APIKey
}

function Get-FreshDeskAPIKey {
    $Script:APIKey
}

function Set-FreshDeskCredential {
    param (
        [Parameter(Mandatory,ParameterSetName="Username")]$Username,
        [Parameter(Mandatory,ParameterSetName="Username")]$Password,
        [Parameter(Mandatory,ParameterSetName="Credential")]$Credential
    )
    if ($Username) {
        $SecureStringPassword = $Password | ConvertTo-SecureString -AsPlainText -Force
        $Credential = New-Object -typename System.Management.Automation.PSCredential -argumentlist $Username, $SecureStringPassword
    }
    $Script:Credential = $Credential
}

function Get-FreshDeskCredential {
    if ($Script:Credential) {
        $Script:Credential
    } else {
        Throw "You need to call either Set-FreshDeskAPIKey or Set-FreshDeskCredential with your freshdesk crednetials"
    }
}

function Set-FreshDeskDomain {
    param (
        $Domain
    )
    $Script:Domain = $Domain
}

function Get-FreshDeskDomain {
    $Script:Domain
}


function Get-FreshDeskURL {
    param (
        $Resource
    )
    $Domain = Get-FreshDeskDomain
    "https://$Domain.freshdesk.com/api/v2/$Resource"
}
function Invoke-FreshDeskAPI {
    param (
        [ValidateSet("tickets")]$Resource,
        $Method
    )
    $URL = Get-FreshDeskURL @PSBoundParameters
    
    $Credential = Get-FreshDeskCredential

    Invoke-RestMethod -ContentType "application/json" -Uri $URL -Method $Method -UseBasicParsing -Headers @{ 
        Authorization = $Credential | ConvertTo-HttpBasicAuthorizationHeaderValue -Type Basic
    }
}

function Get-FreshDeskTicket {
    Invoke-FreshDeskAPI -Resource tickets -Method Get
}