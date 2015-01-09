# Puppet Gitlab Mirrors

#### Table of Contents

1. [Overview](#overview)
2. [Module Description - What the module does and why it is useful](#module-description)
3. [Setup - The basics of getting started with gitlab_mirrors](#setup)
    * [What gitlab_mirrors affects](#what-gitlab_mirrors-affects)
    * [Setup requirements](#setup-requirements)
    * [Beginning with gitlab_mirrors](#beginning-with-gitlab_mirrors)
4. [Usage - Configuration options and additional functionality](#usage)
5. [Reference - An under-the-hood peek at what the module is doing and how](#reference)
5. [Limitations - OS compatibility, etc.](#limitations)
6. [Development - Guide for contributing to the module](#development)

## Overview

The gitlab_mirrors module is first and foremost the configuration code around the gitlab mirrors shell scripts.
https://github.com/samrocketman/gitlab-mirrors

I basically went through the instructions and converted them to puppet code. I have also added support for a mirror_list
seed file that bootstraps the git-mirrors script.



## Module Description

### Background Info
The gitlab-mirrors project is designed to fill in a feature which is currently missing from GitLab: the ability to
mirror remote repositories. gitlab-mirrors creates read only copies of remote repositories in gitlab. It provides
a CLI management interface for managing the mirrored repositories (e.g. add, delete, update) so that an admin may
regularly update all mirrors using crontab. It operates by interacting with the GitLab API using python-gitlab3.

Now that you know what the gitlab-mirrors project does you probably want to know how to configure it.  Instructions
are provided on the https://github.com/samrocketman/gitlab-mirrors page but this module automates the entire thing for
you so you can just skip the instructions.

Additionally, I have written a [script](https://github.com/logicminds/gitlab_mirrors/blob/master/files/sync_mirrors.rb)
that wraps the add_mirror.sh script and allows for a "repo seed file" that I call a mirror_list.yaml file. This allows one
to automatically add a bunch of repos from simply updating the mirror_list.yaml file.

This script will utilize the gitlab-mirrors config.sh variables to figure out where the scripts are located.

## Setup
### Setup Requirements
Python and Python pip are required in order to use this module.  Please ensure you have them installed.
I purposely left these out since there may be other puppet classes that already declare those packages in your environment.

You will also need to create a gitlab user account with admin privileges to be used specifically with gitlab_mirrors
and this project.  Admin privileges is required in order to create projects if they don't already exist.

In order for gitlab_mirrors to work correctly the local system user account that this puppet project creates must have its
public ssh key in the gitlab user account.  This means login as the gitmirror user and copy the ~/.ssh/id_rsa.pub contents
to the gitmirror user profile in gitlab UI. (http://doc.gitlab.com/ce/ssh/ssh.html)

The local system user account can be on any system within your network as long as it can ssh into the gitlab system.  So
you are not required to run this puppet module on your gitlab system.

Once the public ssh key is setup the local system account will be able to push projects to your gitlab server sucessfully.

Additionally, since gitlab_mirrors use the gitlab API it also needs the private token from the newly created gitlab user.

This project makes use of the following modules which is not on the forge.
- https://github.com/nanliu/puppet-git.git

### Setup a mirror list functionality using a repo (Optionally, but highly recommended)
1. Create a repo on your gitlab server called mirror_list
2. Add a yaml file called mirror_list.yaml to the repo
3. Populate the list with the repos you want to mirror.
4. Commit and push this file to the mirror_list repo you created in step 1
5. Add a readme file that points to this repo and some additional notes you think are important for maintaining the mirror list

Example mirror_list.yaml file:
```yaml
---
puppet-staging: https://github.com/nanliu/puppet-staging.git
```

### What gitlab_mirrors affects

* Creates a new user on the system called gitmirror
* Installs the gitlab3 python api
* Adds cron jobs to the specified user.
* Clones repos from github/gitlab to the specified user account
* Creates a repositories directory in the specified user home directory where all repos will be maintained
* Creates ssh key for suplied user
* Maintains a copy of the private token for the associated gitlab user account

### Beginning with gitlab_mirrors


## Usage
Install the python related requirements.  Must have python and pip installed
```puppet
   include gitlab_mirrors::install
```

To setup gitlab_mirrors alone without the mirror list functionality
```puppet
  class{'gitlab_mirrors::config':
      gitlab_mirror_user_token  => '12345678abcdefg',
      gitlab_url                => 'http://192.168.1.1',
      gitlab_mirror_user        => 'gitmirror',
      system_mirror_user        => 'gitmirror',
      system_mirror_group       => 'gitmirror',
      base_home_dir             => '/home',
      mirror_repo               => 'https://github.com/samrocketman/gitlab-mirrors.git',
      mirror_repo_dir_name      => 'gitlab-mirrors',
      repositories_dir_name     => 'repositories',
      gitlab_namespace          => 'gitlab-mirrors',
      generate_public_mirrors   => true,
      ensure_mirror_update_job  => present,
      prune_mirrors             => true,
      force_update              => true,
  }
```

To setup the gitlab_mirrors automated sync_mirror tasks.

```puppet
   class{'gitlab_mirrors::mirror_list':
     mirror_list_repo                 => undef,
     mirror_list_repo_path            => '/home/gitmirror/mirror_list',
     ensure_mirror_sync_job           => absent,
     system_mirror_user               => 'gitmirror',
     system_mirror_group              => 'gitmirror',
     gitlab_mirrors_repo_dir_path     => '/home/gitmirror/gitlab_mirrors',
     mirrors_list_yaml_file           => 'mirror_list.yaml',
     ensure_mirror_list_repo_cron_job => present,
     system_user_home_dir             => '/home/gitmirror'
```

Install everything with just one resource declaration
```
class{'gitlab_mirrors':
  (
    gitlab_mirror_user_token => 'abc1233dkdsisdaf',
    gitlab_url               => 'http://gitlab.company.corp,
    mirror_list_repo         => 'https://github.com/logicminds/mirror_list.git',
    mirror_list_repo_path    => '/home/gitmirror/mirror_list',
  )
}
```
### Mirror List Functionality
Example Mirror list file
```yaml
---
puppet-staging: https://github.com/nanliu/puppet-staging.git
```

The script loops around the mirror list and adds them via the add_mirrors.sh script which is part of the gitlab_mirrors project.
Setting up a cron job allows us to automatically add new mirrors by just updating the mirror_list.yaml.
Furthermore, if you keep the mirror list in a git repo and create a cron job to auto update the mirror_list repo you
can basically control the whole mirroring via a new commit to the mirror list repo.  All of this functionality is
baked into the mirror_list class so you don't need to configure anything but the creation of the repo.

## Reference
- gitlab_mirror_user_token # this is the private token of the gitlab user you need to create,
- gitlab_url  # this is the url to your gitlab server
- mirror_list_repo,
- mirror_list_repo_path,
- gitlab_mirror_user
- system_mirror_user
- system_mirror_group
- system_user_home_dir
- mirror_repo
- mirror_repo_dir_name
- repositories_dir_name
- gitlab_namespace
- generate_public_mirrors
- ensure_mirror_update_job
- prune_mirrors
- force_update
- ensure_mirror_sync_job
- mirrors_list_yaml_file
- ensure_mirror_list_repo_cron_job
- configure_mirror_list_feature     # if true, sets ups the mirror list functionality


## Limitations

Windows is untested.  But if your windows installation has bash and all the python libraries needed by gitlab3 python
api then it should work.

## Development
1. fork this repo
2. Create a feature branch
3. bundle install from feature branch
4. bundle exec rake lint
5. bundle exec rake spec
6. Create Merge request

## Release Notes/Contributors/Etc
This additional functionality of the sync_mirrors.rb script may later be contributed to the
gitlab-mirrors project and removed from this module since it adds additional functionality outside of the puppet code.
