Redis
======================

A second built-in transporter is based on `Redis <https://redis.io/>`__
database. This transporter takes advantage of **publish/subscribe**
feature.

.. raw:: html

   <figure>

.. raw:: html

   </figure>

Installation
^^^^^^^^^^^^

Before we start, we have to install required package:

.. code:: bash

   $ npm i --save redis

Overview
^^^^^^^^

In order to switch from TCP transport strategy to Redis **pub/sub**, we
need to change an options object passed to the ``createMicroservice()``
method.

.. code:: typescript

   @@filename(main)
   const app = await NestFactory.createMicroservice(ApplicationModule, {
     transport: Transport.REDIS,
     options: {
       url: 'redis://localhost:6379',
     },
   });

..

   info **Hint** ``Transport`` enumerator is imported from the
   ``@nestjs/microservices`` package.

Options
^^^^^^^

There are a bunch of available options that determine a transporter
behaviour.

.. raw:: html

   <table>

.. raw:: html

   <tr>

.. raw:: html

   <td>

url

.. raw:: html

   </td>

.. raw:: html

   <td>

Connection url

.. raw:: html

   </td>

.. raw:: html

   </tr>

.. raw:: html

   <tr>

.. raw:: html

   <td>

retryAttempts

.. raw:: html

   </td>

.. raw:: html

   <td>

A total amount of connection attempts

.. raw:: html

   </td>

.. raw:: html

   </tr>

.. raw:: html

   <tr>

.. raw:: html

   <td>

retryDelay

.. raw:: html

   </td>

.. raw:: html

   <td>

A connection retrying delay (ms)

.. raw:: html

   </td>

.. raw:: html

   </tr>

.. raw:: html

   </table>
