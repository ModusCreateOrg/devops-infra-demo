Prepare Web Content
===================

This is intended to prepare a system running NGINX to host a web application.

Requirements
------------

None

Role Variables
--------------

None

Dependencies
------------

This depends on nginxinc.nginx.

Example Playbook
----------------

Please see the example below:

    - name: Install Web Application
      hosts: 127.0.0.1
      connection: local
      become: yes
      roles:
        - nginxinc.nginx
        - prepare-web-content


License
-------

MIT

Author Information
------------------

Richard Bullington-McGuire <richard@moduscreate.com>
