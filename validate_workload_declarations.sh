#!/usr/bin/env bash

main() {
	local -a clusters
	{ readarray -d '' clusters < <(find_cluster_folders) && wait "$!"; } \
		|| exit_with_message 'Error during search for cluster folders.'

	printf '%s\n' "${clusters[@]}"

	local temporary_file_path
	temporary_file_path="$(create_temporary_file)" \
		|| exit_with_message $'\nCould not create temporary file for generated workloads.'

	set_up_deletion_upon_exit "$temporary_file_path"

	for cluster in "${clusters[@]}"; do
		validate_workload_declarations_for "$cluster" "$temporary_file_path"
	done
}

find_cluster_folders() {
	find ./clusters -mindepth 2 -maxdepth 2 -type d -not -name 'bases' -print0
}

create_temporary_file() {
	mktemp --tmpdir='.' generated_workloads.XXXXXXXXXX
}

set_up_deletion_upon_exit() {
	local file_path="$1"

	# Ignore warning because the local variable must be expanded immediately,
	# not when the trap is triggered
	# shellcheck disable=SC2064
	trap "rm --force -- '$file_path'" SIGHUP SIGINT SIGQUIT SIGTERM EXIT
}

validate_workload_declarations_for() {
	local cluster="$1"
	local workloads_file_path="$2"

	cat <<-EOF

		====================
		check $cluster
		====================
	EOF

	printf '\n%s\n' '... kustomize'
	run_in_container "kustomize build ./${cluster}" > "$workloads_file_path" \
		|| exit_with_message "$(red '❌ Error while generating workloads')"
	printf '%s\n' "$(green '✔️PASS') - Workloads generated."

	printf '\n%s\n' '... kubeval'
	run_in_container "kubeval --ignore-missing-schemas --exit-on-error < ${workloads_file_path}" \
		|| exit_with_message "$(red '❌ Error while validating k8s schemas')"
	printf '%s\n' "$(green '✔️PASS') - K8s schemas validated."

	printf '\n%s\n' '... conftest'
	run_in_container "conftest test ${workloads_file_path}" \
		|| exit_with_message "$(red '❌ Error while validating policies')"
	printf '%s\n' "$(green '✔️PASS') - Policies validated."

	printf '\n%s\n' '... search for unpatched values'
	if patch_markers_left "$workloads_file_path"; then
		exit_with_message "$(red '❌ Error: Found missing patches')" 1
	fi
	printf '%s\n' "$(green '✔️PASS') - No unpatched values found."
}

run_in_container() {
	local command="$1"

	docker run \
		--interactive --tty --rm \
		--volume "$(pwd)":/workdir \
		--workdir /workdir \
		deck15/kubeval-tools \
		/bin/sh -c "$command"
}

exit_with_message() {
	local exit_status="${2:-$?}"
	local message="$1"

	printf '%s\n' "$message" 'Aborting execution.'
	exit "$exit_status"
}

red() {
	local last_exit_status="$?"
	local text="$1"

	printf '\e[31;1m%s\e[0m' "$text"
	return "$last_exit_status"
}

green() {
	local last_exit_status="$?"
	local text="$1"

	printf '\e[32;1m%s\e[0m' "$text"
	return "$last_exit_status"
}

patch_markers_left() {
	local workloads_file_path="$1"

	(( $(grep --count '<patched>' "$workloads_file_path") > 0 ))
}

main "$@"

