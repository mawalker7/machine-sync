# Example environment template. Copy per repo as env-templates/<repo>.env.tpl.
# Non-secret config stays literal; each secret is a 1Password reference that `op inject`
# resolves on `machine-sync in`. Keep it line-for-line key-identical to the repo's .env.example.
NODE_ENV=development
APP_PORT=3000
DATABASE_URL=op://Private/example-project/database_url
API_KEY=op://Private/example-project/api_key
