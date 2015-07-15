#!/usr/bin/env bash

gitlab_url='<%= @gitlab_url %>'
ssh_key='<%= @ssh_key %>'
namespace_id='<%= @namespace %>'
token='<%= @gitlab_token %>'


function create_mirror_project{
    project="mirror_list"
    url="${gitlab_url}/api/v3/projects"
    cat > json_payload.json << 'EOF'
      {
       "name": "mirror_list",
       "namespace": "",
       "description": "List of mirrors to clone in private namespace",
       "merge_requests_enabled": true,
       "import_url": "https://github.com/logicminds/mirror_list",
       "public": false
      }

    EOF
    curl -k -H "PRIVATE-TOKEN: ${token}" -H "Accept: application/json" -H "Content-type: application/json" -X POST --data-binary @json_payload.json ${url}
    rm json_payload.json

}

function upload_ssh_key {
    data="{ \"title\": \"deploy-key\", \"key\": \"`cat ~/id_rsa.pub`\"}"
    echo $data > json_payload.json

    # the following loop will go through the modules directory where each directory represents a puppet module repository
    # in gitlab.  This also assumes that the directory name is the name of the project
       project="${namespace}%2F${name}"
    echo "Adding deploy key to project: ${namespace}/${name}"
    url="${gitlab_url}/api/v3/projects/${project}/keys"
    curl -k -H "PRIVATE-TOKEN: ${token}" -H "Accept: application/json" -H "Content-type: application/json" -X POST --data-binary @json_payload.json ${url}
    echo ''
}