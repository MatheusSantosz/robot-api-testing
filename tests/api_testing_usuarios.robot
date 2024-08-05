*** Settings ***
Resource    ../resources/api_testing_usuarios.resource


*** Variables ***

*** Test Cases ***
Cenario 01: Cadastrar um novo usuario com sucesso ServerRest
    Criar um usuario novo
    Cadastrar um usuario criado na ServerRest    email=${EMAIL_TEST}    status_code_desejado=201  
    Validar se o usuario foi cadastrado com sucesso

Cenario 02: Cadastrar um usuario já existente
    Criar um usuario novo
    Cadastrar um usuario criado na ServerRest    email=${EMAIL_TEST}      status_code_desejado=201
    Repetir cadastrado de usuario repetido         
    Verificar se a API nao permitiu o cadastro repetido

Cenario 03: Consultar os dados de um novo usuario
    Criar um usuario novo
    Cadastrar um usuario criado na ServerRest    email=${EMAIL_TEST}      status_code_desejado=201
    Consultar os dados do novo usuario
    Validar os dados retornados do usuario
    