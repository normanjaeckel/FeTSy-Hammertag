=================
 FeTSy-Hammertag
=================

.. image:: https://david-dm.org/normanjaeckel/FeTSy-Hammertag/status.svg
   :target: https://david-dm.org/normanjaeckel/FeTSy-Hammertag

.. image:: https://travis-ci.org/normanjaeckel/FeTSy-Hammertag.svg?branch=master
    :target: https://travis-ci.org/normanjaeckel/FeTSy-Hammertag

.. image:: https://img.shields.io/badge/license-MIT-blue.svg
   :target: http://opensource.org/licenses/MIT

Smart tool for administration of objects and supplies during mass events.


Development
===========

Node.js (tested with 4.x) and MongoDB (tested with 2.4.x) are required. To
setup development version start MongoDB server instance and run::

    $ npm install
    $ node_modules/.bin/gulp serve


Production
==========

To run in production you should do the following:

- Install dependencies::

    $ npm install

- Optionally create a ``config.yml`` file next to ``gulpfile.js`` with the
  following content::

    logoURL: static/path/to/logo.png

  This will let the client look for a logo at ``dist/static/path/to/logo.png``.

- Run Gulp once with production flag::

    $ node_modules/.bin/gulp --production

- Check and setup the following environment variables:

  - ``NODE_ENV=production``, see `this chapter of ExpressJS docs
    <http://expressjs.com/en/advanced/best-practice-performance.html#in-environment>`_.

  - ``DEBUG=''``, see `debugging guide for ExpressJS
    <http://expressjs.com/en/guide/debugging.html>`_.

  - ``FETSY_PORT=8080`` or whatever you like. FeTSy-Hammertag will listen on
    ``localhost`` on this port.

  - ``MONGODB_DATABASE=fetsy-hammertag`` or whatever you like.

  - ``MONGODB_PORT=27017``, change this if you use something like
    `systemd-socket-proxyd
    <https://www.freedesktop.org/software/systemd/man/systemd-socket-proxyd.html>`_
    to provide socket activation support for MongoDB.

- Use a `process manager <http://expressjs.com/en/advanced/pm.html>`_ to
  start ExpressJS server with something like::

    /usr/bin/node dist/server/server.js

  A systemd unit with `Type=notify
  <https://www.freedesktop.org/software/systemd/man/systemd.service.html#Type
  =>`_ and `NotifyAccess=all
  <https://www.freedesktop.org/software/systemd/man/systemd.service.html#Noti
  fyAccess=>`_ is supported. FeTSy-Hammertag uses `python-systemd
  <https://github.com/systemd/python-systemd>`_ to send the notify message
  to systemd if ``NOTIFY_SOCKET`` is set. Do not forget to install
  python-systemd in this case.

- Setup a proxy server like NginX or Apache HTTP Server and point it to the
  port of FeTSy-Hammertag (default 8080).

- Start all the stuff (proxy server, MongoDB, process manager).


License
=======

MIT
