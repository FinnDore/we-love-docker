FROM node:20.13.1-bullseye@sha256:6d72e3efec7d7844d5fd268e25da86c59306bd732341b25d810840dd1d4c05c8 as deps

WORKDIR /repo
ENV CI true

RUN corepack enable pnpm

COPY tooling/prettier/package.json tooling/prettier/package.json
COPY tooling/typescript/package.json tooling/typescript/package.json
COPY tooling/eslint/package.json tooling/eslint/package.json
COPY tooling/tailwind/package.json tooling/tailwind/package.json
COPY packages/auth/package.json packages/auth/package.json
COPY packages/api/package.json packages/api/package.json
COPY packages/db/package.json packages/db/package.json
COPY apps/nextjs/package.json apps/nextjs/package.json
COPY packages/ui/package.json packages/ui/package.json 
COPY packages/validators/package.json packages/validators/package.json
COPY pnpm-lock.yaml pnpm-workspace.yaml .npmrc /repo/

RUN pnpm --filter nextjs deploy dependencies 

FROM node:20.13.1-bullseye@sha256:6d72e3efec7d7844d5fd268e25da86c59306bd732341b25d810840dd1d4c05c8 as builder

WORKDIR /repo
ENV CI true

RUN corepack enable pnpm

COPY --from=deps /repo/dependencies .

RUN pnpm build

FROM node:20.13.1-bullseye@sha256:6d72e3efec7d7844d5fd268e25da86c59306bd732341b25d810840dd1d4c05c8

WORKDIR /app
EXPOSE 3000
ENV PORT 3000
ENV NODE_ENV production 

RUN addgroup --system --gid 1001 runner 
RUN adduser --system --uid 1001 app 
USER app 

COPY --from=builder --chown=app:runner /repo .

CMD node dist/index.js

