*** Settings ***
Library    SSHLibrary
Library    Browser
Resource    api.resource

*** Variables ***
${ADMIN_USER}    admin
${ADMIN_PASSWORD}    Nethesis,1234

*** Keywords ***
Retry test
    [Arguments]    ${keyword}
    Wait Until Keyword Succeeds    60 seconds    1 second    ${keyword}

Backend URL is reachable
    ${rc} =    Execute Command    curl -f ${backend_url}/rustfs/console/auth/login
    ...    return_rc=True  return_stdout=False
    Should Be Equal As Integers    ${rc}  0

Login to cluster-admin
    New Page    https://${NODE_ADDR}/cluster-admin/
    Fill Text    text="Username"    ${ADMIN_USER}
    Click    button >> text="Continue"
    Fill Text    text="Password"    ${ADMIN_PASSWORD}
    Click    button >> text="Log in"
    Wait For Elements State    css=#main-content    visible    timeout=10s


*** Test Cases ***
Check if rustfs is installed correctly
    ${output}  ${rc} =    Execute Command    add-module ${IMAGE_URL} 1
    ...    return_rc=True
    Should Be Equal As Integers    ${rc}  0
    &{output} =    Evaluate    ${output}
    Set Suite Variable    ${module_id}    ${output.module_id}

Take screenshots
    [Tags]    ui
    New Browser    chromium    headless=True
    New Context    ignoreHTTPSErrors=True
    Login to cluster-admin
    Go To    https://${NODE_ADDR}/cluster-admin/#/apps/${module_id}
    Wait For Elements State    iframe >>> h2 >> text="Status"    visible    timeout=10s
    Sleep    5s
    Take Screenshot    filename=${OUTPUT DIR}/browser/screenshot/1._Status.png
    Go To    https://${NODE_ADDR}/cluster-admin/#/apps/${module_id}?page=settings
    Wait For Elements State    iframe >>> h2 >> text="Settings"    visible    timeout=10s
    Sleep    5s
    Take Screenshot    filename=${OUTPUT DIR}/browser/screenshot/2._Settings.png
    Close Browser

Check if rustfs can be configured
    ${rc} =    Execute Command    api-cli run module/${module_id}/configure-module --data '{"host_server": "rustfs.nethserver.org","host_console": "console.nethserver.org","lets_encrypt": false,"password": "rustfsadmin", "user": "rustfsadmin"}'
    ...    return_rc=True  return_stdout=False
    Should Be Equal As Integers    ${rc}  0

Get default configuration
    ${response} =  Run task    module/${module_id}/get-configuration
    ...    {}    rc_expected=0

Retrieve rustfs backend URL
    # Assuming the test is running on a single node cluster
    ${response} =    Run task     module/traefik1/get-route    {"instance":"${module_id}-console"}
    Set Suite Variable    ${backend_url}    ${response['url']}

Check if rustfs works as expected
    Retry test    Backend URL is reachable

Verify rustfs frontend title
    ${output} =    Execute Command    curl -s ${backend_url}/rustfs/console/auth/login
    Should Contain    ${output}    <meta name="description" content="RustFS is a distributed file system written in Rust.

Check if rustfs is removed correctly
    ${rc} =    Execute Command    remove-module --no-preserve ${module_id}
    ...    return_rc=True  return_stdout=False
    Should Be Equal As Integers    ${rc}  0
