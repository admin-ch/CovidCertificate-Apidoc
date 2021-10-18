#!/bin/bash

set -x

define_variables() {
  current_date=$(date +%Y_%m_%d)
  branch_name="feature/api_update_$current_date"
  remote_push_target="refs/heads/$branch_name"
  git_access_token="<put your own access token here>"
  git_push_address="https://$git_access_token@github.com/admin-ch/CovidCertificate-Apidoc"
  message="Update of api at $current_date"
  url="https://cc-api-gateway-service.abn.app.cfap02.atlantica.admin.ch/v3/api-docs.yaml"
}

take_new_api_doc_from_ABN() {
  curl "$url" -o ./open-api/api-doc.yaml
}

update_git_files() {
  git fetch
  echo "$branch_name"
  git checkout origin/main -b "$branch_name"
}

commit_updated_files_to_git() {
  git status
  git commit -a -m "$message"
}

push_updated_files_to_git() {
  git push "$git_push_address"
}

if [[ $# -eq 0 ]]; then
  echo "Updating api-doc.yaml"
  define_variables
  update_git_files
  take_new_api_doc_from_ABN
  commit_updated_files_to_git
  push_updated_files_to_git
else
  while test $# -gt 0
  do
      case "$1" in
          -u)
            echo "Update git files only"
            define_variables
            update_git_files
            ;;
	        -t)
            echo "Take new api with curl"
            define_variables
            take_new_api_doc_from_ABN
	          ;;
	        -c)
            echo "Take new api with curl"
            define_variables
            commit_updated_files_to_git
	          ;;
	        -p)
            echo "Push changes to remote branch"
            define_variables
            push_updated_files_to_git
	          ;;
          *)
            echo "Nothing to do. Run the command without parameters"
            echo "Or run the command with one of the steps using -u, -t, -c, -p in this order"
            echo "-u, update git files"
            echo "-t, take new api doc from ABN"
            echo "-c, commit updated files to git"
            echo "-p, push changes to remote branch"
            echo "-h, show this help"
            ;;
      esac
      shift
  done
fi

exit 0
