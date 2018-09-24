Extra CIS Remediation
=====================

This takes care of remediating CIS issues that the Mindpoint role does not.

Requirements
------------

None

Role Variables
--------------

None

Dependencies
------------

This is intended for use with the MindPointGroup.RHEL7-CIS role, but it doesn't depend on it strictly. Use it before that role runs.

Example Playbook
----------------

Please see the example below:

    - name: Harden Server
      hosts: 127.0.0.1
      connection: local
      become: yes
      roles:
        - extra-cis-remediation
        - MindPointGroup.RHEL7-CIS

License
-------

MIT

Author Information
------------------

Richard Bullington-McGuire <richard@moduscreate.com>
