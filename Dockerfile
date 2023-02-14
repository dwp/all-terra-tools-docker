FROM public.ecr.aws/ubuntu/ubuntu:20.04_stable

ARG COMPLIANCE_VERSION=1.3.26
ARG TERRAFORM_VERSION=0.14.11
ARG TERRAGRUNT_VERSION=0.31.0
# Update tests/container/terratest.yaml when bumping the go version
ARG GO_VERSION=1.17.6
ARG TERRAFORM_DOCS_VERSION=0.14.1
ARG TFLINT_VERSION=0.30.0
ARG TFMASK_VERSION=0.7.0
ARG KUBECTL_VERSION=v1.21.2
ARG VAULT_VERSION=1.8.1

ARG HASHICORP_PGP_KEY
ARG TARGET_ARCH='linux_amd64'

LABEL terraform_compliance.version="${COMPLIANCE_VERSION}"
LABEL terraform.version="${TERRAFORM_VERSION}"
LABEL terragrunt.version="${TERRAGRUNT_VERSION}"

ENV TARGET_ARCH="${TARGET_ARCH}"
ENV HASHICORP_PGP_KEY="${HASHICORP_PGP_KEY}"
ENV GO111MODULE=on
ENV GOPATH=/root/go
ENV TZ=Europe/Dublin
ENV DEBIAN_FRONTEND=noninteractive
ENV PATH="/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin:/root/go/bin:/usr/local/go/bin"

RUN  set -ex \
     && BUILD_DEPS='wget unzip golang' \
     && RUN_DEPS="git tar gpg sudo jq python3-pip curl sed build-essential" \
     && apt-get update \
     && apt-get upgrade -y \
     && apt-get install -y ${BUILD_DEPS} ${RUN_DEPS} \
     && TERRAFORM_FILE_NAME="terraform_${TERRAFORM_VERSION}_${TARGET_ARCH}.zip" \
     && SHA256SUM_FILE_NAME="terraform_${TERRAFORM_VERSION}_SHA256SUMS" \
     && SHA256SUM_SIG_FILE_NAME="terraform_${TERRAFORM_VERSION}_SHA256SUMS.sig" \
     && SHA256SUM_FILE_NAME_FOR_ARCH="${SHA256SUM_FILE_NAME}.${TARGET_ARCH}" \
     && HASHICORP_PGP_KEY_FILE='hashicorp-pgp-key.pub' \
     && OLD_BASEDIR="$(pwd)" \
     && TMP_DIR=$(mktemp -d) \
     && cd "${TMP_DIR}" \
     && echo "${HASHICORP_PGP_KEY}" > "${HASHICORP_PGP_KEY_FILE}" \
     && wget -q "https://releases.hashicorp.com/terraform/${TERRAFORM_VERSION}/${SHA256SUM_FILE_NAME}" \
     && wget -q "https://releases.hashicorp.com/terraform/${TERRAFORM_VERSION}/${SHA256SUM_SIG_FILE_NAME}" \
     && gpg --import "${HASHICORP_PGP_KEY_FILE}" \
     # && gpg --verify "${SHA256SUM_SIG_FILE_NAME}" "${SHA256SUM_FILE_NAME}" \
     && wget -q "https://releases.hashicorp.com/terraform/${TERRAFORM_VERSION}/${TERRAFORM_FILE_NAME}" \
     && grep "${TERRAFORM_FILE_NAME}" "${SHA256SUM_FILE_NAME}" > "${SHA256SUM_FILE_NAME_FOR_ARCH}" \
     && wget --quiet "https://github.com/gruntwork-io/terragrunt/releases/download/v${TERRAGRUNT_VERSION}/terragrunt_linux_amd64" \
     && chmod +x terragrunt_linux_amd64 \
     && mv terragrunt_linux_amd64 /usr/local/bin/terragrunt \
     && ls -al . \
     && sha256sum -c "${SHA256SUM_FILE_NAME_FOR_ARCH}" \
     && unzip "${TERRAFORM_FILE_NAME}" \
     && install terraform /usr/bin/ \
     && curl -sSLo ./terraform-docs.tar.gz https://terraform-docs.io/dl/v${TERRAFORM_DOCS_VERSION}/terraform-docs-v${TERRAFORM_DOCS_VERSION}-$(uname)-amd64.tar.gz \
     && tar -xzf terraform-docs.tar.gz \
     && chmod +x terraform-docs \
     && mv terraform-docs /usr/local/bin/terraform-docs \
     && wget --quiet "https://golang.org/dl/go${GO_VERSION}.linux-amd64.tar.gz" \
     && tar -C /usr/local -xzf go${GO_VERSION}.linux-amd64.tar.gz \
     && /usr/local/go/bin/go get  "golang.org/x/lint/golint" \
     && curl -L -o ./tflint.zip https://github.com/terraform-linters/tflint/releases/download/v${TFLINT_VERSION}/tflint_linux_amd64.zip \
     && unzip tflint.zip \
     && chmod +x tflint \
     && mv tflint /usr/local/bin/tflint \
	 && curl -L https://github.com/cloudposse/tfmask/releases/download/${TFMASK_VERSION}_linux_amd64 -o /usr/bin/tfmask \
     && chmod +x /usr/bin/tfmask \
     && curl -LO https://dl.k8s.io/release/${KUBECTL_VERSION}/bin/linux/amd64/kubectl \
     && curl -LO https://dl.k8s.io/release/${KUBECTL_VERSION}/bin/linux/amd64/kubectl.sha256 \
     && echo "$(cat kubectl.sha256) kubectl" | sha256sum --check \
     && chmod +x kubectl \
     && mv kubectl /usr/local/bin/kubectl \
     && curl -LO https://releases.hashicorp.com/vault/${VAULT_VERSION}/vault_${VAULT_VERSION}_linux_amd64.zip \
     && curl -L https://releases.hashicorp.com/vault/${VAULT_VERSION}/vault_${VAULT_VERSION}_SHA256SUMS -o vault_SHA256SUMS \
     && VAULT_SHA=$(cat vault_SHA256SUMS | grep linux_amd | awk '{ print $1}') \
     && echo "$VAULT_SHA vault_${VAULT_VERSION}_linux_amd64.zip" | sha256sum --check \
     && unzip  vault_${VAULT_VERSION}_linux_amd64.zip \
     && chmod + vault \
     && mv vault /usr/local/bin/vault \
     && cd "${OLD_BASEDIR}" \
     && unset OLD_BASEDIR \
     && rm -vrf ${TMP_DIR} \
     && pip install --upgrade pip \
     && pip install terraform-compliance=="${COMPLIANCE_VERSION}" \
     && pip install pre-commit   \
     && pip install awscli \
	 && pip install terraform_external_data \
     && pip install gnupg \
     && apt-get remove -y ${BUILD_DEPS} \
     && apt-get autoremove -y \
     && apt-get clean -y \
     && rm -rf /var/lib/apt/lists/* \
     && mkdir -p /target

RUN echo "Host *" >> /etc/ssh/ssh_config
RUN echo " StrictHostKeyChecking no" >> /etc/ssh/ssh_config

RUN mkdir -p /tests/examples/terragrunt-example
RUN mkdir -p /tests/terragrunt/
COPY ./tests/examples/terragrunt-example/main.tf /tests/examples/terragrunt-example/
COPY ./tests/examples/terragrunt-example/terragrunt.hcl /tests/examples/terragrunt-example/
COPY ./tests/terragrunt/* /tests/terragrunt/

WORKDIR /target
ENTRYPOINT ["/bin/bash"]
