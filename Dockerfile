# ---------- build stage ----------
FROM docker.io/library/elixir:1.19-otp-28 AS build

RUN apt-get update -qq && apt-get install -y --no-install-recommends git build-essential ca-certificates \
    && rm -rf /var/lib/apt/lists/*

WORKDIR /app

# install hex + rebar
RUN mix local.hex --force && mix local.rebar --force

# compile deps (cached unless mix.exs / mix.lock change)
COPY mix.exs mix.lock ./
RUN MIX_ENV=prod mix deps.get && MIX_ENV=prod mix deps.compile

# compile app + assets
COPY config config
COPY lib lib
COPY priv priv
COPY assets assets

ENV MIX_ENV=prod
RUN mix compile

RUN mix assets.setup && mix assets.deploy

# build the release
RUN mix release

# ---------- runtime stage ----------
FROM docker.io/library/debian:trixie-slim AS app

RUN apt-get update -qq && apt-get install -y --no-install-recommends openssl libncurses6 ca-certificates \
    && rm -rf /var/lib/apt/lists/*

RUN groupadd -r frontier && useradd -r -g frontier frontier

WORKDIR /app
COPY --from=build --chown=frontier:frontier /app/_build/prod/rel/frontier ./

USER frontier

EXPOSE 4000
ENV PORT=4000 PHX_SERVER=true

CMD ["/app/bin/frontier", "start"]
