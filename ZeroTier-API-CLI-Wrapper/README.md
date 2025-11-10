# zt-cli

Um script Bash simples para gerenciar redes ZeroTier via linha de comando, porque o pessoal do Zerotier não fez isso antes?

Este script é um wrapper direto para a [API v1 do ZeroTier Central](https://docs.zerotier.com/api/central/v1/), permitindo o gerenciamento completo da sua conta sem a necessidade de instalar clientes pesados.

-----

## Recursos

  * Gerenciamento completo de Redes (criar, listar, atualizar, deletar).
  * Gerenciamento completo de Membros (autorizar, nomear, deletar).
  * Gerenciamento de Usuário (tokens de API) e Organização (convites).
  * Feito em Bash puro, sem dependências complexas.
  * Cobre 100% dos endpoints da API v1.

-----

## Requisitos

Você só precisa de três coisas (a maioria já vem instalada no Linux):

1.  `bash`
2.  `curl`
3.  `jq` (para formatar a saída JSON)

No Ubuntu/Debian, instale o `jq` com:

```bash
sudo apt install jq curl
```

-----

## Instalação

1.  Clone este repositório:
    ```bash
    git clone https://github.com/nocerainfosec/zt-cli.git
    ```
2.  Entre no diretório:
    ```bash
    cd zt-cli
    ```
3.  Dê permissão de execução ao script:
    ```bash
    chmod +x zt-cli
    ```

-----

## Configuração

Antes de usar, você precisa definir seu token da API do [ZeroTier Central](https://my.zerotier.com/account).

Exporte-o como uma variável de ambiente no seu terminal:

```bash
export ZEROTIER_TOKEN="seu_token_secreto_aqui"
```

-----

## Uso

O script é simples. Para ver todos os comandos e o banner, execute sem argumentos:

```bash
./zt-cli
```

### Exemplos de Comandos

```bash
# Ver o status da sua conta
./zt-cli status

# Listar todas as suas redes
./zt-cli list-networks

# Criar uma nova rede chamada "Minha Rede Teste"
./zt-cli create-network '{"name": "Minha Rede Teste"}'

# Autorizar e nomear um novo membro
# ./zt-cli update-member <network-id> <member-id> <json-data>
./zt-cli update-member 1234abcd5678 90abefgh12 '{"name": "meu-servidor", "config": {"authorized": true}}'

# Listar membros de uma organização
./zt-cli list-org-members <org-id>
```

-----

## Fontes e Créditos

  * **Autor:** Guilherme Nocera ([nocerainfosec](https://github.com/nocerainfosec))
  * **Fonte da API:** Este script é baseado inteiramente na documentação oficial da API v1 do ZeroTier Central.
      * **Docs:** `https://docs.zerotier.com/api/central/v1/`
      * **OpenAPI:** `https://docs.zerotier.com/openapi/centralv1.json`

-----

## Licença

Este projeto é distribuído sob a **Licença MIT**.
