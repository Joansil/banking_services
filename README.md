# Banking Transaction Service

![Elixir](https://img.shields.io/badge/Elixir-%236f4e99.svg?style=for-the-badge&logo=elixir&logoColor=white)
![Phoenix](https://img.shields.io/badge/Phoenix-%23FF6600.svg?style=for-the-badge&logo=phoenix&logoColor=white)

O **Banking Transaction Service** é um sistema bancário construído em Elixir que utiliza o modelo de atores (Actor Model) para lidar com transações concorrentes de forma eficiente e confiável.

## Funcionalidades

- Criar contas bancárias.
- Realizar transferências entre contas.

---

## Requisitos

- Elixir >= 1.14
- Phoenix >= 1.7
- PostgreSQL >= 13.0

---

## Configuração

1. Clone este repositório:
   ```bash
   git clone https://github.com/seuusuario/banking_services.git
   cd banking_services
2. Instale as dependências:

mix deps.get

3. Configure o banco de dados no arquivo config/dev.exs:

config :banking_service, BankingService.Repo,
  username: "postgres",
  password: "postgres",
  hostname: "localhost",
  database: "banking_service_dev",
  stacktrace: true,
  show_sensitive_data_on_connection_error: true,
  pool_size: 10

4. Crie e migre o banco de dados:

  mix ecto.create
  mix ecto.migrate

5. Inicie o servidor:

    mix phx.server

A aplicação estará disponível em:

    http://localhost:4000

_________________________________________________________________________________________________________________________________________________________________________________________________________________________________

Endpoints
1. Accounts
POST /api/accounts

Corpo da Requisição:

	{
	  "account": {
	    "email": "user@example.com",
	    "name": "John Dooeee",
	    "balance": 50000.00
	  }
	}

Resposta:

	{
	  "id": "68730fdb-3d1f-41a9-ab7d-39dbcda55a95",
	  "name": "John Dooeee",
	  "email": "user_john@example.com",
	  "balance": "50000",
	  "inserted_at": "2025-01-30T14:40:32Z",
	  "updated_at": "2025-01-30T14:40:32Z"
	}

Alguns possiveis erros:

	{
	  "error": [
	    {
	      "field": "email",
	      "messages": "This email is already registered."
	    }
	  ]
	}

	{
	  "error": [
	    {
	      "field": "name",
	      "messages": "This field is required."
	    }
	  ]
	}

GET /api/accounts/:id

Corpo da Requisição:
GET http://localhost:4000/api/accounts/:account_id

Resposta:

	{
	  "balance": "255.50",
	  "email": "concert@example.com",
	  "id": "073fce47-bab5-427f-8fec-6c1628013413",
	  "name": "Show de Bola"
	}


________________________________________________________________________________________________________________________________________________________________________________________________________________________________

2. Transactions
POST /api/transactions

Corpo da Requisição:

	{
	  "transaction": {
	    "account_from_id": "aea8a1fb-1180-47bc-bc83-559754809102",
	    "account_to_id": "073fce47-bab5-427f-8fec-6c1628013413",
	    "amount": "5.50",
	    "status": "pending"
	  }
	}


Resposta:

	{
	  "message": "Transaction completed successfully",
	  "transaction": {
	    "id": "8008ce64-071a-4da9-b76c-9e3345bd9149",
	    "amount": "5.50",
	    "status": "completed",
	    "account_from_id": "aea8a1fb-1180-47bc-bc83-559754809102",
	    "account_to_id": "073fce47-bab5-427f-8fec-6c1628013413",
	    "inserted_at": "2025-01-30T13:51:35Z",
	    "updated_at": "2025-01-30T13:51:35Z"
	  }
	}		


________________________________________________________________________________________________________________________________________________________________________________________________________________________________

Testes

Execute os testes com:

mix test


Contribuição

    Faça um fork do repositório.

    Crie um branch para sua feature/bugfix:

	git checkout -b minha-feature

    Envie suas alterações:

	git push origin minha-feature
    
    Abra um Pull Request.
________________________________________________________________________________________________________________________________________________________________________________________________________________________________

Exemplo de chamada com cURL
Criar uma conta bancária:

	curl -X POST http://localhost:4000/api/accounts \
	  -H "Content-Type: application/json" \
	  -d '{
	    "account": {
	      "email": "user@example.com",
	      "name": "John Dooeee",
	      "balance": 50000.00
	    }
	  }'		

Consultar conta bancária:

	curl -X GET http://localhost:4000/api/accounts/68730fdb-3d1f-41a9-ab7d-39dbcda55a95

Criar uma transação:

	curl -X POST http://localhost:4000/api/transactions \
	  -H "Content-Type: application/json" \
	  -d '{
	    "transaction": {
	      "account_from_id": "aea8a1fb-1180-47bc-bc83-559754809102",
	      "account_to_id": "073fce47-bab5-427f-8fec-6c1628013413",
	      "amount": "5.50",
	      "status": "pending"
	    }
	  }'
________________________________________________________________________________________________________________________________________________________________________________________________________________________________

Licença

Este projeto está licenciado sob a MIT License.





