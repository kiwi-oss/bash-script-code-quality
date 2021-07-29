#!/usr/bin/env bash

main() {
	local -a clusters
	{ readarray -d '' clusters < <(find_cluster_folders) && wait "$!"; } \
		|| exit_with_message 'Error during search for cluster folders.'

	printf '%s\n' "${clusters[@]}"

	for cluster in "${clusters[@]}"; do
		validate_workload_declarations_for "$cluster"
	done
}

find_cluster_folders() {
	find ./clusters -mindepth 2 -maxdepth 2 -type d -not -name 'bases' -print0
}

validate_workload_declarations_for() {
	local cluster="$1"

	cat <<-EOF

		====================
		check $cluster
		====================
	EOF

	printf '\n%s\n' '... kustomize'
	run_in_container "kustomize build ./${cluster} > generated_workloads" \
		|| exit_with_message "$(red '❌ Error while generating workloads')"
	printf '%s\n' "$(green '✔️PASS') - Workloads generated."

	printf '\n%s\n' '... kubeval'
	run_in_container "kubeval --ignore-missing-schemas --exit-on-error < generated_workloads" \
		|| exit_with_message "$(red '❌ Error while validating k8s schemas')"
	printf '%s\n' "$(green '✔️PASS') - K8s schemas validated."

	printf '\n%s\n' '... conftest'
	run_in_container "conftest test generated_workloads" \
		|| exit_with_message "$(red '❌ Error while validating policies')"
	printf '%s\n' "$(green '✔️PASS') - Policies validated."

	printf '\n%s\n' '... search for unpatched values'
	if patch_markers_left; then
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
	(( $(grep --count '<patched>' generated_workloads) > 0 ))
}

main "$@"

