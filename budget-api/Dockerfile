# Stage 1: Build
FROM node:current-alpine3.22 AS builder

WORKDIR /app

# Copier les fichiers de dépendances
COPY package*.json ./

# Installer TOUTES les dépendances
RUN npm ci

# Copier le code source
COPY . .

# Build l'application
RUN npm run build

# Stage 2: Production
FROM node:current-alpine3.22

WORKDIR /app

# Copier seulement ce qui est nécessaire pour la production
COPY package*.json ./
RUN npm ci --omit=dev

# Copier les fichiers buildés
COPY --from=builder /app/.next ./.next
COPY --from=builder /app/public ./public
COPY --from=builder /app/package.json ./package.json
COPY --from=builder /app/node_modules ./node_modules

EXPOSE 3000

CMD ["npm", "start"]
