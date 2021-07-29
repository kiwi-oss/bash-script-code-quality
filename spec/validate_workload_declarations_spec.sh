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

    Describe 'with a failing Kubeval tool'
        Parameters
           'kustomize build ' 'generating workloads' 0
           'kubeval --ignore-missing-schemas --exit-on-error' 'validating k8s schemas' 1
           'conftest test' 'validating policies' 2
        End

        It 'exits with corresponding message'
            validation_command="$1"
            error_message="$2"
            pass_message_count="$3"

            find() {
                printf '%s\n' 'some_cluster'
            }
            docker() {
                if [[ "$*" == *"$validation_command"* ]]; then
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
            The output should include "$error_message"
            The output should satisfy pass_message_count_is "$pass_message_count"
        End
    End
End
