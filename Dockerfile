# ---- Stage 1: Build React frontend ----
FROM node:18-alpine AS frontend-build
WORKDIR /app
COPY gui/package*.json ./
RUN npm install --legacy-peer-deps
COPY gui/ .
RUN npm run build

# ---- Stage 2: Serve frontend with nginx ----
FROM nginx:alpine AS frontend
COPY --from=frontend-build /app/build /usr/share/nginx/html
EXPOSE 80

# ---- Stage 3: Backend ----
FROM node:18-alpine AS backend
WORKDIR /app
COPY server/package*.json ./
RUN npm ci --omit=dev
COPY server/ .
EXPOSE 8080
CMD ["node", "server.js"]
