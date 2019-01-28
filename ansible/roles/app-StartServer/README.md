App StartServer Role
=====================

This is intended to prepare an application that requires some setup after installation for running. This is intended for use with AWS CodeDeploy as a StartServer hook.

Requirements
------------

None

Role Variables
--------------

None

Dependencies
------------

nginx

Example Playbook
----------------

Please see the example below:

    - name: Perform StartServer hook
      hosts: 127.0.0.1
      connection: local
      become: yes
      roles:
        - app-StartServer


License
-------

MIT

Author Information
------------------

Richard Bullington-McGuire <richard@moduscreate.com>
