Describe 'Workload declarations validation'

    It 'outputs success messages for all steps when they pass'
        When run source validate_workload_declarations.sh
        The status should be success
        The output should include 'PASS'
        Dump
    End
End
