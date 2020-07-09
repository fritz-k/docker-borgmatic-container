ARG PYTHON_VERSION=3.8-alpine3.12

FROM python:${PYTHON_VERSION} as builder
ARG BORGMATIC_VERSION=1.5.8
ENV PYTHONUNBUFFERED 1

WORKDIR /wheels
RUN pip3 wheel borgmatic==${BORGMATIC_VERSION}

FROM python:${PYTHON_VERSION}
ARG BORGMATIC_VERSION=1.5.8

COPY --from=builder /wheels /wheels

RUN apk add --no-cache \
        bash \
        borgbackup \
        docker-cli \
        openssh-client \
    && pip3 install -f /wheels borgmatic==${BORGMATIC_VERSION} \
    && rm -fr \
        /.cache \
        /var/cache/apk/* \
        /wheels

COPY ./entrypoint.sh /entrypoint.sh

WORKDIR /
ENTRYPOINT ["/entrypoint.sh"]

LABEL org.label-schema.version=${BORGMATIC_VERSION}
