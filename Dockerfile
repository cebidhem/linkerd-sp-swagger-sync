FROM alpine:3.18 as base
RUN apk add --no-cache curl openssl
RUN addgroup -g 1001 app && \
    adduser -D -G app -u 1001 app

FROM base as builder
ENV KUBECTL_VERSION=1.26.4
ARG TARGETPLATFORM
RUN curl -LO https://dl.k8s.io/release/v${KUBECTL_VERSION}/bin/${TARGETPLATFORM}/kubectl && \
    chmod +x ./kubectl && \
    curl -LO https://run.linkerd.io/install && \
    chmod +x ./install && \
    sh install

FROM base as final
COPY --chown=app:app --from=builder kubectl /usr/local/bin/kubectl
COPY --chown=app:app --from=builder /root/.linkerd2/bin/linkerd /usr/local/bin/linkerd
ADD --chown=app:app entrypoint.sh /app/entrypoint.sh
WORKDIR /app
USER app
ENTRYPOINT ["./entrypoint.sh"]