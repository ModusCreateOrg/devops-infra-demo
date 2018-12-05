Prepare CodeDeploy
==================

Prepare an image for having AWS CodeDeploy installed on it with a minimum of runtime downloads.

Requirements
------------

This is tested only on CentOS 7 currently. It might work on other distributions.

Role Variables
--------------

None

Dependencies
------------

None

Example Playbook
----------------

Including an example of how to use your role (for instance, with variables passed in as parameters) is always nice for users too:

    - hosts: servers
      roles:
         - { role: prepare-codedeploy }

License
-------

MIT

Author Information
------------------

Richard Bullington-McGuire <richard@moduscreate.com>
