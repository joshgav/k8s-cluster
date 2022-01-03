#! /usr/bin/env bash

function is_openshift() {
    set +e
    kubectl get namespaces openshift-operators &> /dev/null
    if [[ $? != 0 ]]; then
        return 1
    fi
    return 0
}

function create_subscription() {
    if is_openshift; then
        DEFAULT_OPERATOR_NAMESPACE=openshift-operators
    else
        DEFAULT_OPERATOR_NAMESPACE=operators
    fi

    operator_name=${1}
    operator_namespace=${2:-${DEFAULT_OPERATOR_NAMESPACE}}
    operator_channel=${3}

    package_manifest=$(kubectl get packagemanifests ${operator_name} --output json)
    catalog_name=$(echo ${package_manifest} | jq -r '.status.catalogSource')
    catalog_namespace=$(echo ${package_manifest} | jq -r '.status.catalogSourceNamespace')
    default_channel=$(echo ${package_manifest} | jq -r '.status.defaultChannel')
    if [[ -z "${operator_channel}" ]]; then
        operator_channel=${default_channel}
    fi
    starting_csv=$(echo ${package_manifest} | jq -r ".status.channels[] | select(.name == \"${operator_channel}\") | .currentCSV")

    kubectl apply -f - <<EOF
        apiVersion: operators.coreos.com/v1alpha1
        kind: Subscription
        metadata:
            name: ${operator_name}
            namespace: ${operator_namespace}
        spec:
            channel: ${operator_channel}
            installPlanApproval: Automatic
            name: ${operator_name}
            source: ${catalog_name}
            sourceNamespace: ${catalog_namespace}
            startingCSV: ${starting_csv}
EOF
}

echo "installing argocd-operator"
create_subscription argocd-operator