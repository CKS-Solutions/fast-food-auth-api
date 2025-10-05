# Fast Food Auth API

API de autenticação para sistema de fast food usando AWS Lambda e Cognito.

## Estrutura do Projeto

```
fast-food-auth-api/
├── src/
│   ├── auth/                    # Lambda de autenticação
│   │   ├── index.js            # Handler principal
│   │   └── package.json        # Dependências específicas
├── terraform/                  # Infraestrutura como código
│   ├── main.tf
│   ├── modules/
│   │   ├── api-gateway/
│   │   ├── cognito/
│   │   ├── iam/
│   │   └── lambda/
│   └── envs/                   # Ambientes (dev/prod)
├── workflows/                  # GitHub Actions
└── package.json               # Scripts de build
```

## Lambdas

### Auth Lambda (`src/auth/`)
- **Função**: Autenticação sem senha usando apenas CPF
- **Handler**: `index.handler`
- **Dependências**: 
  - `@aws-sdk/client-cognito-identity-provider`
  - `jsonwebtoken`

### Como Adicionar Nova Lambda

1. Crie um diretório em `src/[nome-da-lambda]/`
2. Adicione `index.js` com o handler
3. Crie `package.json` com dependências específicas
4. Atualize o Terraform para incluir a nova lambda
5. Adicione script de build no `package.json` raiz

## Scripts Disponíveis

```bash
# Build da lambda de auth
npm run build:auth

# Build de todas as lambdas
npm run build:all
```

## Deploy

O deploy é feito via Terraform. Cada lambda é empacotada independentemente com suas próprias dependências.

## Autenticação

A API aceita apenas CPF como entrada e retorna um JWT token válido por 24 horas.

**Requisição:**
```json
{
  "cpf": "12345678901"
}
```

**Resposta:**
```json
{
  "message": "Autenticação bem-sucedida! Token JWT gerado.",
  "username": "user123",
  "cpf": "12345678901",
  "attributes": [...],
  "token": "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9...",
  "expiresIn": "24h"
}
```
