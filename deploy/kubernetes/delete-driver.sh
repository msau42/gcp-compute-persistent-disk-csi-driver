#!/bin/bash

# This script will remove the Google Compute Engine Persistent Disk CSI Driver
# from the currently available Kubernetes cluster
#
# Args:
# GCE_PD_DRIVER_VERSION: The kustomize overlay to deploy (located under
#   deploy/kubernetes/overlays).

set -o nounset
set -o errexit

readonly NAMESPACE="${GCE_PD_DRIVER_NAMESPACE:-gce-pd-csi-driver}"
readonly DEPLOY_VERSION="${GCE_PD_DRIVER_VERSION:-stable-master}"
readonly PKGDIR="."
source "${PKGDIR}/deploy/common.sh"

ensure_kustomize

if [[ "${KUSTOMIZE_PATH}" == *kubectl* ]]; then
  ${KUSTOMIZE_PATH} "${PKGDIR}/deploy/kubernetes/overlays/${DEPLOY_VERSION}" | ${KUBECTL} delete -v="${VERBOSITY}" --ignore-not-found -f -
else
  ${KUSTOMIZE_PATH} build "${PKGDIR}/deploy/kubernetes/overlays/${DEPLOY_VERSION}" | ${KUBECTL} delete -v="${VERBOSITY}" --ignore-not-found -f -
fi
${KUBECTL} delete secret cloud-sa -v="${VERBOSITY}" --ignore-not-found

if [[ "${NAMESPACE}" != "" && "${NAMESPACE}" != "default" ]] && \
  ${KUBECTL} get namespace "${NAMESPACE}" -v="${VERBOSITY}";
then
    ${KUBECTL} delete namespace "${NAMESPACE}" -v="${VERBOSITY}"
fi
