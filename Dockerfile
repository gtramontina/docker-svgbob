FROM rust:1.61-slim as build
ARG version
WORKDIR /opt
RUN rustup target add x86_64-unknown-linux-musl
RUN cargo install \
	--target x86_64-unknown-linux-musl \
	--root /opt \
	--version $version \
	svgbob_cli

# ---

FROM scratch
COPY --from=build /opt/bin/svgbob_cli /svgbob
ENTRYPOINT ["/svgbob"]
