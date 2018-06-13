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
        $Resource,
        $Include,
        $Page,
        $Per_Page
    )
    $Domain = Get-FreshDeskDomain
    $PSBoundParameters.Remove("Resource") | Out-Null
    $QueryStringParameters = $PSBoundParameters | ConvertTo-URLEncodedQueryStringParameterString

    "https://$Domain.freshdesk.com/api/v2/$Resource$(if($QueryStringParameters){"?$QueryStringParameters"})"
}
function Invoke-FreshDeskAPI {
    param (
        [ValidateSet("tickets","contacts")]$Resource,
        $Method,
        $Include,
        $Body
    )
    $URL = Get-FreshDeskURL @PSBoundParameters
    
    $Credential = Get-FreshDeskCredential
    $BodyParameter = @{
        Body = if ($Body) {$Body | ConvertFrom-PSBoundParameters | ConvertTo-Json}
    }

    Invoke-RestMethod -ContentType "application/json" -Uri $URL -Method $Method -UseBasicParsing -Headers @{ 
        Authorization = $Credential | ConvertTo-HttpBasicAuthorizationHeaderValue -Type Basic
    } @BodyParameter
}

function Get-FreshDeskTicket {
    Invoke-FreshDeskAPI -Resource tickets -Method Get
}

function New-FreshDeskTicket {
    param (
        $name,
        $requester_id,
        $email,
        $facebook_id,
        $phone,
        $twitter_id,
        $unique_external_id,
        $subject,
        $type,
        $status,
        $priority,
        $description,
        $responder_id,
        $attachments,
        $cc_emails,
        $custom_fields,
        $due_by,
        $email_config_id,
        $fr_due_by,
        $group_id,
        $product_id,
        $source,
        $tags,
        $company_id
    )    
    Invoke-FreshDeskAPI -Body $PSBoundParameters -Resource tickets -Method Post
}

function Get-FreshDeskContact {

}

function New-FreshDeskContact {
    param (
        [boolean]$active,
        [string]$address,
        [object]$avatar,
        [number]$company_id,
        [boolean]$view_all_tickets,
        [dictionary]$custom_fields,
        [boolean]$deleted,
        [string]$description,
        [string]$email,
        [number]$id,
        [string]$job_title,
        [string]$language,
        [number]$mobile,
        [string]$name,
        [String[]]$other_emails,
        [string]$phone,
        [String[]]$tags,
        [string]$time_zone,
        [string]$twitter_id,
        [array]$other_companies,
        [datetime]$created_at,
        [datetime]$updated_at
    )
    Invoke-FreshDeskAPI -Body $PSBoundParameters -Resource tickets -Method Post
}