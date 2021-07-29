#shellcheck shell=bash

Describe 'Workload declarations validation'

    It 'outputs success messages for all steps when they pass'
        find() {
            printf '%s\n' 'some_cluster'
        }
        docker() {
            return 0
        }
        cat() {
            printf '%s\n' 'dummy workload'
        }

        When run source validate_workload_declarations.sh
        The status should be success
        The output should include 'PASS'
        Dump
    End
End
