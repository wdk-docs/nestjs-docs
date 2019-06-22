RabbitMQ
======================

The `RabbitMQ <https://www.rabbitmq.com/>`_ is the most widely deployed
open source message broker.

Installation
^^^^^^^^^^^^

Before we start, we have to install required packages:

.. code:: bash

   $ npm i --save amqplib amqp-connection-manager

Transporter
^^^^^^^^^^^

In order to switch to **RabbitMQ** transporter, we need to modify an
options object passed to the ``createMicroservice()`` method.

.. code:: typescript

   @@filename(main)
   const app = await NestFactory.createMicroservice(ApplicationModule, {
     transport: Transport.RMQ,
     options: {
       urls: [`amqp://localhost:5672`],
       queue: 'cats_queue',
       queueOptions: { durable: false },
     },
   });

..

   info **Hint** ``Transport`` enumerator is imported from the
   ``@nestjs/microservices`` package.

Options
^^^^^^^

There are a bunch of available options that determine a transporter
behavior.

.. raw:: html

   <table>

.. raw:: html

   <tr>

.. raw:: html

   <td>

urls

.. raw:: html

   </td>

.. raw:: html

   <td>

Connection urls

.. raw:: html

   </td>

.. raw:: html

   </tr>

.. raw:: html

   <tr>

.. raw:: html

   <td>

queue

.. raw:: html

   </td>

.. raw:: html

   <td>

Queue name which your server will listen to

.. raw:: html

   </td>

.. raw:: html

   </tr>

.. raw:: html

   <tr>

.. raw:: html

   <td>

prefetchCount

.. raw:: html

   </td>

.. raw:: html

   <td>

Sets the prefetch count for the channel

.. raw:: html

   </td>

.. raw:: html

   </tr>

.. raw:: html

   <tr>

.. raw:: html

   <td>

isGlobalPrefetchCount

.. raw:: html

   </td>

.. raw:: html

   <td>

Enables per channel prefetching

.. raw:: html

   </td>

.. raw:: html

   </tr>

.. raw:: html

   <tr>

.. raw:: html

   <td>

queueOptions

.. raw:: html

   </td>

.. raw:: html

   <td>

Additional queue options. They are well-described here

.. raw:: html

   </td>

.. raw:: html

   </tr>

.. raw:: html

   <tr>

.. raw:: html

   <td>

socketOptions

.. raw:: html

   </td>

.. raw:: html

   <td>

Additional socket options. They are well-described here

.. raw:: html

   </td>

.. raw:: html

   </tr>

.. raw:: html

   </table>
