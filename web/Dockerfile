FROM node:16.17-alpine AS client-build
WORKDIR /usr/src/app
COPY client/ ./client/

RUN cd client && npm install --legacy-peer-deps && npm run build

FROM node:16.17-alpine AS server-build
WORKDIR /root/
COPY --from=client-build /usr/src/app/client/build ./client/build
COPY server/package*.json ./server/
RUN cd server && npm install

COPY server/ ./server/

EXPOSE 80

CMD ["node", "./server/app/index.js"]