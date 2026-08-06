FROM node:20-alpine@sha256:abc

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