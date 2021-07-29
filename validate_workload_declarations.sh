#!/usr/bin/env bash

main() {
    CLUSTERS=$(find ./clusters -type d -mindepth 2 -maxdepth 2 -not -name 'bases') \
        || exit_with_message 'Error during search for cluster folders.'
    echo "${CLUSTERS}"

    for cluster in ${CLUSTERS}; do
        echo
        echo ==================== ;
        echo check "$cluster" ;
        echo ==================== ;

        echo
        echo ... kustomize;
        run_in_container "kustomize build ./${cluster} > generated_workloads ;"
        [ $? -ne 0 ] && echo -e "\e[31;1m❌ Error: generating workloads! \e[0m" && exit 1;
        echo -e "\e[32;1m✔️PASS\e[0m - workloads generated."

        echo
        echo ... kubeval;
        run_in_container "cat generated_workloads | kubeval --ignore-missing-schemas --exit-on-error ;"
        [ $? -ne 0 ] && echo -e "\e[31;1m❌ Error: validating k8s schemas! \e[0m" && exit 1;
        echo -e "\e[32;1m✔️PASS\e[0m - k8s schemas validated."

        echo
        echo ... conftest;
        run_in_container "cat generated_workloads | conftest test - ;"
        [ $? -ne 0 ] && echo -e "\e[31;1m❌ Error: validating policies! \e[0m" && exit 1;
        echo -e "\e[32;1m✔️PASS\e[0m - policies fullfileled."

        echo
        echo ... check unpatched values;
        if [ $(cat generated_workloads | grep "<patched>" | wc -l) -ne 0 ]; then
          echo -e "\e[31;1m❌ Error: found unpatched places! \e[0m";
          exit 1;
        fi
        echo -e "\e[32;1m✔️PASS\e[0m - no unpatched places found."
    done
}

exit_with_message() {
    local exit_status="$?"
    local message="$1"

    printf '%s\n' "$message" 'Aborting execution.'
    exit "$exit_status"
}

run_in_container() {
    local command="$1"

    docker run -it --rm  -v "$(pwd)":/workdir -w /workdir deck15/kubeval-tools /bin/sh -c "$command"
}


main "$@"

