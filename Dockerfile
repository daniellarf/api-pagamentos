FROM node:20-alpine@sha256:fb4cd12c85ee03686f6af5362a0b0d56d50c58a04632e6c0fb8363f609372293

WORKDIR /app

COPY package*.json ./

RUN npm ci --omit=dev

COPY server.js ./

LABEL org.opencontainers.image.licenses="MIT"

HEALTHCHECK --interval=30s --timeout=5s --start-period=10s --retries=3 \
  CMD node -e "fetch('http://localhost:3000').then(r => { if (!r.ok) process.exit(1) }).catch(() => process.exit(1))"

USER node

EXPOSE 3000

CMD ["npm", "start"]