App AfterInstall Role
=====================

This is intended to prepare an application that requires some setup after installation for running. It will modify SELinux labels. This is intended for use with AWS CodeDeploy as an AfterInstall hook.

Requirements
------------

None

Role Variables
--------------

None

Dependencies
------------

SELinux and a Red Hat Linux family OS

Example Playbook
----------------

Please see the example below:

    - name: Perform AfterInstall hook
      hosts: 127.0.0.1
      connection: local
      become: yes
      roles:
        - app-AfterInstall


License
-------

MIT

Author Information
------------------

Richard Bullington-McGuire <richard@moduscreate.com>
