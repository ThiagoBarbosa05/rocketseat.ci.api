FROM node:18 AS build

RUN npm i -g yarn

FROM node:18-alpine AS base

RUN npm i -g pnpm

# Definir o diretório de trabalho

FROM base AS dependencies

WORKDIR /app

COPY package*.json pnpm-lock.yaml ./

RUN pnpm install

FROM base AS build

WORKDIR /app

# Copiar o restante do código da aplicação
COPY . .
COPY --from=dependencies /app/node_modules ./node_modules

# Compilar o TypeScript para JavaScript
RUN pnpm run build

# Etapa 2: Configuração de produção
FROM node:18-alpine AS production

# Definir o diretório de trabalho
WORKDIR /app

RUN npm i -g pnpm

# Copiar apenas as dependências de produção
COPY --from=build /app/dist ./dist
COPY --from=build /app/node_modules ./node_modules
COPY --from=build /app/package.json ./package.json

# Expor a porta da aplicação
EXPOSE 3000

# Comando para iniciar a aplicação
CMD ["pnpm","run", "start:prod"]