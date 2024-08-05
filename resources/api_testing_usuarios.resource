*** Settings ***
Library    RequestsLibrary
Library    String
Library    JSONLibrary
Library    Collections

*** Keywords ***
Criar um usuario novo
    ${palavra_aleatoria}    Generate Random String    length=4    chars=[LETTERS]
    ${palavra_aleatoria}    Convert To Lower Case     ${palavra_aleatoria} 
    Set Test Variable        ${EMAIL_TEST}     ${palavra_aleatoria}@mailteste.com
    Log    ${EMAIL_TEST} 

Cadastrar um usuario criado na ServerRest
        [Arguments]    ${EMAIL}    ${status_code_desejado}
        ${body}    Create Dictionary
        ...        nome=Fulano da Silva
        ...        email=${EMAIL_TEST}
        ...        password=1234
        ...        administrador=true
        Log    ${body} 
        Criar Sessao na ServerRest
        [Documentation]     Adicionei abaixo o load from file da JSONLibrary
         ...                para carregar tambem por data.
         ...     
        # ${json}=          Load Json From File
        # ...               file_name=${CURDIR}${/}services${/}json${/}user.json
        #Log                ${json}    

        ${response}    POST On Session
        ...            alias=ServeRest
        ...            url=/usuarios
        ...            json=${body}
        ...            expected_status=${status_code_desejado}
        Log            ${response.json()}

        IF    ${response.status_code} == 201
            Set Test Variable    ${ID_USUARIO}    ${response.json()["_id"]}  
        END
            Set Test Variable    ${RESPOSTA}      ${response.json()}
        

Criar Sessao na ServerRest
     ${headers}       Create Dictionary
        ...           accept=application/json
        ...           Content-Type=application/json
    Create Session    alias=ServeRest    url=https://serverest.dev    headers=${headers} 

Validar se o usuario foi cadastrado com sucesso
    Log    ${RESPOSTA}        
    Should Be Equal    ${RESPOSTA['message']}                 Cadastro realizado com sucesso
    Dictionary Should Contain Item   ${RESPOSTA}   message    Cadastro realizado com sucesso
    Dictionary Should Contain Key    ${RESPOSTA}   _id  

Repetir cadastrado de usuario repetido
    Cadastrar um usuario criado na ServerRest    email=${EMAIL_TEST}      status_code_desejado=400
Verificar se a API nao permitiu o cadastro repetido
    Log    ${RESPOSTA}
    Should Be Equal                 ${RESPOSTA['message']}                 Este email já está sendo usado
    Dictionary Should Contain Item   ${RESPOSTA}   message                Este email já está sendo usado

Consultar os dados do novo usuario
    ${resposta_consulta}    GET On Session   alias=ServeRest
    ...    url=https://serverest.dev/usuarios/${ID_USUARIO}
    ...    expected_status=200
    Log    ${resposta_consulta.headers}
    Log    ${resposta_consulta.status_code}
    Log    ${resposta_consulta.elapsed}
    Log    ${resposta_consulta.reason}
    Log    ${resposta_consulta.json()}

    Set Test Variable    ${RESP_CONSULTA}    ${resposta_consulta.json()}
Validar os dados retornados do usuario
    
    Dictionary Should Contain Item    ${RESP_CONSULTA}        nome              Fulano da Silva
    Dictionary Should Contain Item    ${RESP_CONSULTA}        email             ${EMAIL_TEST}
    Dictionary Should Contain Item    ${RESP_CONSULTA}        password          1234
    Dictionary Should Contain Item    ${RESP_CONSULTA}        administrador     true
    Dictionary Should Contain Item    ${RESP_CONSULTA}        _id               ${ID_USUARIO}
    Log    ${RESP_CONSULTA}