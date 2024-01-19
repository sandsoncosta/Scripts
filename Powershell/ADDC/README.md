 # Script de Criação de Usuários no Active Directory

Este projeto tem como objetivo auxiliar na criação de Unidades Organizacionais e usuários para acelerar o processo de criação seja em laboratório ou no dia a dia para sysadmins.
A principal ideia ao se criar esses scripts, foi apenas para uso em lab para teste de invasão, engenharia de detecção etc. voltado para ambiente de Hunting, Purple Team e Blue Team.

## Pré-requisitos

- Windows PowerShell
- Módulo Active Directory PowerShell

## Instruções

1. Acesse o terminal e navegue até a pasta onde se encontram os arquivos `.ps1`.
2. Execute o script usando o seguinte comando:

```powershell
.\Create-ADUsers.ps1
```

## Como o script funciona

O script `createOU_AD.ps1` é responsável por criar OUs dentro de uma OU principal, no exemplo do script eu usei a OU `Departamentos` como OU principal e dentro dela eu incluí as OUs:
```powershell
$ouNames = @("Administração", "Financeiro", "TI", "Vendas", "Marketing", "Red Team", "Blue Team", "Visitantes", "Estagiários", "Clientes", "Servidores", "Banco de Dados")
```
O script `deleteOU_AD.ps1` é responsável por deletar OUs, simples e objetivo:
```powershell
$ouToDelete = @("Administração", "Financeiro", "TI", "Vendas", "Marketing", "Red Team", "Blue Team", "Visitantes", "Estagiários", "Clientes", "Servidores", "Banco de Dados")
```
O script `create_random_users_AD.ps1` é responsável por criar usuários aleatórios dentro das OUs.
Esse script cria 5 usuários em cada OU e a criação de `nome.sobrenome` é aleatória com base nas informações passadas nas variáveis:.
```powershell
$firstNames = @("João", "José", "Miguel", "Arthur", "Gabriel", "Davi", "Luiz", "Bernardo", "Heitor", "Pedro", "Lucas", "Matheus", "Rafael", "Vicente", "Enzo", "Felipe", "Samuel", "Gael", "Leonardo", "Maria", "Alice", "Helena", "Heloísa", "Laura", "Luiza", "Sophia", "Valentina", "Gabriela", "Manuela", "Ana", "Isabella", "Julia", "Michael", "James", "Robert", "David", "William", "Richard", "Charles", "Emily", "Olivia", "Mia", "Abigail", "Emma", "Charlotte")
$lastNames = @("Silva", "Santos", "Oliveira", "Pereira", "Alves", "Ferreira", "Souza", "Rodrigues", "Lima", "Carvalho", "Gomes", "Costa", "Martins", "Reis", "Nascimento", "Almeida", "Barbosa", "Castro", "Moreira", "Ribeiro", "Nunes", "Fernandes", "Smith", "Johnson", "Williams", "Jones", "Davis", "Miller", "Wilson", "Carter", "Gonzalez", "Hernandez", "Garcia", "Lee", "Rodriguez", "Thomas", "Jackson")
```
A senha também está em uma variável e vai desde bem simples para mais complexas:
```powershell
$passwords = @("MinhaSenha123", "Qwerty123", "password", "admin123", "********", "Kento123!", "Flores123", "S3n#4Th3G14nT123", "JesusSalva", "RockYou2021", "PowerTheShell", "K`$4p9wY8r@2L", "D#6qPx7o*5Fv", "G@2sL9xP3qRw", "T!8zN7k#6p1X", "H%5jF2v*4qLp", "W@3rB6z1&8Xv", "Y*9sM7x2v#4L", "J!6dF4k#8w9P", "U&2hP8l`$5m3Z", "X%7tL1w#9r4K")
```

O script `password_random.ps1` é responsável por autenticar usuários com uma lista pré-definida de senhas.
Ele lê um arquivo `users.txt` que contém uma lista de usuários para realizar a autenticação com sucesso ou não.

O script `password_spray.ps1` também é responsável por autenticar usuários usando um arquivo de texto contendo os nomes de usuário.

## Bug do Milênio!

De vez em quando o erro `New-ADUser : The password does not meet the length, complexity, or history requirement of the domain.` aparece. Indica que a senha não está nos padrões de segurança estabelecidos, como no exemplo da senha `password`... Eu não tenho certeza se ele habilita a senha para o usuário, não testei, mas o usuário é criado e desativado. 
De qualquer forma, não interfere no aprendizado (em prod também, mas não coloco minha mão no fogo viu!).
O mais interessante é que vai ajudar a visualizar usuários desativados, quando em Lab (pelo menos pra mim é legal).

## Saídas das execuções

```
.\createOU_AD.ps1
OUTPUT:
Unidade Organizacional 'Administração' criada com sucesso.

-----------------------
.\deleteOU_AD.ps1
OUTPUT:
Unidade Organizacional 'Administração' removida com sucesso.

-----------------------
.\create_random_users_AD.ps1
OUTPUT:
Usuário 'charlotte.lee' criado com sucesso na OU 'Banco de Dados' com a senha: K$4p9wY8r@2L.

-----------------------
.\create_users_csv.ps1
OUTPUT:
Usuário 'bella.velasques' criado com sucesso na OU 'TI' com a senha: H%5jF2v*4qLp.

-----------------------
.\password_random.ps1
OUTPUT:
Autenticação bem-sucedida para charlotte.alves com a senha: Kento123!
Autenticação falhou para julia.lee com a senha: Kento123!.
```

![Exemplo script](https://i.imgur.com/0IgeTwU.gif)