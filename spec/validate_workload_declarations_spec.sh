#shellcheck shell=bash

Describe 'Workload declarations validation'

    pass_message_count_is() {
        local string=${pass_message_count_is:?}
        local expected_count="$1"

        (( $(grep --ignore-case --count 'pass' <<< "$string") == expected_count ))
    }

    It 'outputs success messages for all steps when they pass'
        find() {
            printf '%s\n' 'some_cluster'
        }
        docker() {
            printf '%s\n' 'Output from Kubeval tool'
            return 0
        }
        cat() {
            printf '%s\n' 'dummy workload'
        }

        When run source validate_workload_declarations.sh
        The status should be success
        The output should satisfy pass_message_count_is 4
    End

    It 'exits with a failure messages if a step fails'
        find() {
            printf '%s\n' 'some_cluster'
        }
        docker() {
            if [[ "$*" == *'kustomize build '* ]]; then
                return 1
            fi
            printf '%s\n' 'Output from Kubeval tool'
            return 0
        }
        cat() {
            printf '%s\n' 'dummy workload'
        }

        When run source validate_workload_declarations.sh
        The status should be failure
        The output should include 'Error'
        The output should include 'generating workloads'
    End
End
