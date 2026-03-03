FROM python:3.14.3-alpine3.23

ARG USERNAME
ARG UID
ARG HOME

RUN pip install --upgrade pip
RUN pip install ansible==13.4.0 ansible-lint yamllint
RUN apk update && apk --no-cache add openssh-client expect git sshpass build-base

RUN adduser -D -g "" -u ${UID}  ${USERNAME} -h ${HOME}
RUN echo "${USERNAME} ALL=(ALL) NOPASSWD:ALL" >> /etc/sudoers
USER ${USERNAME}

WORKDIR /ansible

