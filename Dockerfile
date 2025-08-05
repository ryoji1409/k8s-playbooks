FROM python:3.13.5-alpine3.22

ARG USERNAME
ARG UID
ARG HOME

RUN pip install --upgrade pip
RUN pip install ansible==11.8.0 ansible-lint yamllint
RUN apk update && apk --no-cache add openssh-client expect git sshpass build-base

RUN adduser -D -g "" -u ${UID}  ${USERNAME} -h ${HOME}
RUN echo "${USERNAME} ALL=(ALL) NOPASSWD:ALL" >> /etc/sudoers
USER ${USERNAME}

WORKDIR /ansible

