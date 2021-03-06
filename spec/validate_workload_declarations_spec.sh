#shellcheck shell=bash

Describe 'Workload declarations validation'

	pass_message_count_is() {
		local text=${pass_message_count_is:?}
		local expected_count="$1"

		(( $(grep --ignore-case --count $'\e\[32;1m.*pass\e\[0m' <<< "$text") \
			== expected_count ))
	}

	It 'outputs success messages for all steps when they pass'
		find() {
			printf '%s\0' 'some_cluster'
		}
		docker() {
			printf '%s\n' 'Output from Kubeval tool'
			return 0
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
				printf '%s\0' 'some_cluster'
			}
			docker() {
				if [[ "$*" == *"$validation_command"* ]]; then
					return 1
				fi
				printf '%s\n' 'Output from Kubeval tool'
				return 0
			}

			When run source validate_workload_declarations.sh
			The status should be failure
			The output should match pattern $'*\e[31;1m*Error*\e[0m*'
			The output should include "$error_message"
			The output should satisfy pass_message_count_is "$pass_message_count"
		End
	End

	It 'exits with corresponding message for failing patch validation'
		find() {
			printf '%s\0' 'some_cluster'
		}
		docker() {
			printf '%s\n' 'Contains remaining <patched> value'
			return 0
		}

		When run source validate_workload_declarations.sh
		The status should be failure
		The output should match pattern $'*\e[31;1m*Error*\e[0m*'
		The output should include 'Found missing patches'
		The output should satisfy pass_message_count_is 3
	End

	It 'outputs success messages for multiple clusters'
		find() {
			printf '%s\0' 'first_cluster' 'second_cluster' 'third_cluster'
		}
		docker() {
			printf '%s\n' 'Output from Kubeval tool'
			return 0
		}

		When run source validate_workload_declarations.sh
		The status should be success
		The output should satisfy pass_message_count_is $(( 3 * 4 ))
	End

	It 'outputs the found cluster folders first'
		find() {
			printf '%s\0' 'first_cluster' 'second_cluster' 'third_cluster'
		}
		docker() {
			return 1
		}

		When run source validate_workload_declarations.sh
		The status should be failure
		The line 1 should equal 'first_cluster'
		The line 2 should equal 'second_cluster'
		The line 3 should equal 'third_cluster'
		The line 4 should equal ''
	End

	contains_header_for_cluster() {
		local text=${contains_header_for_cluster:?}
		local cluster_name="$1"

		local expected_header
		read -r -d '' expected_header <<-EOF
			====================
			check $cluster_name
			====================
		EOF

		grep --perl-regexp --null-data --quiet \
			"${expected_header//$'\n'/'\n'}" <<< "$text"
	}

	It 'outputs headers for all clusters'
		find() {
			printf '%s\0' 'first_cluster' 'second_cluster' 'third_cluster'
		}
		docker() {
			printf '%s\n' 'Output from Kubeval tool'
			return 0
		}

		When run source validate_workload_declarations.sh
		The status should be success
		The output should satisfy contains_header_for_cluster 'first_cluster'
		The output should satisfy contains_header_for_cluster 'second_cluster'
		The output should satisfy contains_header_for_cluster 'third_cluster'
	End

	It 'exits with corresponding message for failing find command'
		find() {
			printf '%s\0' 'some_cluster'
			return 13
		}
		docker() {
			return 1
		}

		When run source validate_workload_declarations.sh
		The status should equal 13
		The output should include 'Error during search'
		The lines of stdout should equal 2
	End

	It 'validates clusters with spaces and newline in name correctly'
		find() {
			printf '%s\0' $'first\ncluster' 'my second cluster'
		}
		docker() {
			printf '%s\n' 'Output from Kubeval tool'
			return 0
		}

		When run source validate_workload_declarations.sh
		The status should be success
		The line 1 should equal 'first'
		The line 2 should equal 'cluster'
		The line 3 should equal 'my second cluster'
		The output should satisfy contains_header_for_cluster $'first\ncluster'
		The output should satisfy contains_header_for_cluster 'my second cluster'
		The output should satisfy pass_message_count_is $(( 2 * 4 ))
	End

	It 'does not leave generated files in the current folder'
		find() {
			printf '%s\0' 'first_cluster' 'second_cluster' 'third_cluster'
		}
		docker() {
			printf '%s\n' 'Output from Kubeval tool'
			return 0
		}

		When run source validate_workload_declarations.sh
		The status should be success
		The output should be present
		The file ./generated_workloads* should not be exist
	End

	It 'exits with corresponding message if temporary file could not be created'
		find() {
			printf '%s\0' 'some_cluster'
		}
		mktemp() {
			printf '%s\n' 'temporary_file'
			return 42
		}
		docker() {
			return 1
		}

		When run source validate_workload_declarations.sh
		The status should equal 42
		The output should include 'Could not create temporary file'
		The lines of stdout should equal 4
	End
End
