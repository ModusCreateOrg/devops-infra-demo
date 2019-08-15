Role Name
=========

Set up the AWS CloudWatch agent and capture some basic log files.

Requirements
------------

A working AWS account. The config file included is suitable for CentOS 7 and an instance running on EC2.

Role Variables
--------------

N/A

Dependencies
------------

This role stands alone and has no dependencies.

Example Playbook
----------------

Here is an example playbook:

    - hosts: servers
      become: yes
      roles:
        - cloudwatch-agent

License
-------

MIT

Author Information
------------------

Copyright © 2019 Modus Create, Inc.

* Madalin Borodi (@MadalinBorodi)
* Richard Bullington-McGuire (@obscurerichard) <richard@moduscreate.com>


