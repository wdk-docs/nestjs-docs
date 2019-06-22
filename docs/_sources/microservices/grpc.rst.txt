gRPC
======================

The `gRPC <https://github.com/grpc/grpc-node>`_ is a high-performance,
open-source universal RPC framework.

Installation
^^^^^^^^^^^^

Before we start, we have to install required package:

.. code:: bash

   $ npm i --save grpc @grpc/proto-loader

Transporter
^^^^^^^^^^^

In order to switch to **gRPC** transporter, we need to modify an options
object passed to the ``createMicroservice()`` method.

.. code:: typescript

   @@filename(main)
   const app = await NestFactory.createMicroservice(ApplicationModule, {
     transport: Transport.GRPC,
     options: {
       package: 'hero',
       protoPath: join(__dirname, 'hero/hero.proto'),
     },
   });

..

   info **Hint** The ``join()`` function is imported from ``path``
   package, while ``Transport`` enum is coming from
   ``@nestjs/microservices``.

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

protoLoader

.. raw:: html

   </td>

.. raw:: html

   <td>

NPM package name (if you want to use another proto-loader)

.. raw:: html

   </td>

.. raw:: html

   </tr>

.. raw:: html

   <tr>

.. raw:: html

   <td>

protoPath

.. raw:: html

   </td>

.. raw:: html

   <td>

Absolute (or relative to the root dir) path to the .proto file

.. raw:: html

   </td>

.. raw:: html

   </tr>

.. raw:: html

   <tr>

.. raw:: html

   <td>

loader

.. raw:: html

   </td>

.. raw:: html

   <td>

@grpc/proto-loader options. They are well-described here.

.. raw:: html

   </td>

.. raw:: html

   </tr>

.. raw:: html

   <tr>

.. raw:: html

   <td>

package

.. raw:: html

   </td>

.. raw:: html

   <td>

Protobuf package name

.. raw:: html

   </td>

.. raw:: html

   </tr>

.. raw:: html

   <tr>

.. raw:: html

   <td>

credentials

.. raw:: html

   </td>

.. raw:: html

   <td>

Server credentials (read more)

.. raw:: html

   </td>

.. raw:: html

   </tr>

.. raw:: html

   </table>

Overview
^^^^^^^^

In general, a ``package`` property sets a
`protobuf <https://developers.google.com/protocol-buffers/docs/proto>`__
package name, while ``protoPath`` is a path to the ``.proto``
definitions file. The ``hero.proto`` file is structured using protocol
buffer language.

.. code:: typescript

   syntax = "proto3";

   package hero;

   service HeroService {
     rpc FindOne (HeroById) returns (Hero) {}
   }

   message HeroById {
     int32 id = 1;
   }

   message Hero {
     int32 id = 1;
     string name = 2;
   }

In the above example, we defined a ``HeroService`` that exposes a
``FindOne()`` gRPC handler which expects ``HeroById`` as an input and
returns a ``Hero`` message. In order to define a handler that fulfills
this protobuf definition, we have to use a ``@GrpcMethod()`` decorator.
The previously known ``@MessagePattern()`` is no longer useful.

.. code:: typescript

   @@filename(hero.controller)
   @GrpcMethod('HeroService', 'FindOne')
   findOne(data: HeroById, metadata: any): Hero {
     const items = [
       { id: 1, name: 'John' },
       { id: 2, name: 'Doe' },
     ];
     return items.find(({ id }) => id === data.id);
   }
   @@switch
   @GrpcMethod('HeroService', 'FindOne')
   findOne(data, metadata) {
     const items = [
       { id: 1, name: 'John' },
       { id: 2, name: 'Doe' },
     ];
     return items.find(({ id }) => id === data.id);
   }

..

   info **Hint** The ``@GrpcMethod()`` decorator is imported from
   ``@nestjs/microservices`` package.

The ``HeroService`` is a service name, while ``FindOne`` points to a
``FindOne()`` gRPC handler. The corresponding ``findOne()`` method takes
two arguments, the ``data`` passed from the caller and ``metadata`` that
stores gRPC request’s metadata.

Furthermore, the ``FindOne`` is actually redundant here. If you don’t
pass a second argument to the ``@GrpcMethod()``, Nest will automatically
use the method name with the capitalized first letter, for example,
``findOne`` -> ``FindOne``.

.. code:: typescript

   @@filename(hero.controller)
   @Controller()
   export class HeroService {
     @GrpcMethod()
     findOne(data: HeroById, metadata: any): Hero {
       const items = [
         { id: 1, name: 'John' },
         { id: 2, name: 'Doe' },
       ];
       return items.find(({ id }) => id === data.id);
     }
   }
   @@switch
   @Controller()
   export class HeroService {
     @GrpcMethod()
     findOne(data, metadata) {
       const items = [
         { id: 1, name: 'John' },
         { id: 2, name: 'Doe' },
       ];
       return items.find(({ id }) => id === data.id);
     }
   }

Likewise, you might not pass any argument. In this case, Nest would use
a class name.

.. code:: typescript

   @@filename(hero.controller)
   @Controller()
   export class HeroService {
     @GrpcMethod()
     findOne(data: HeroById, metadata: any): Hero {
       const items = [
         { id: 1, name: 'John' },
         { id: 2, name: 'Doe' },
       ];
       return items.find(({ id }) => id === data.id);
     }
   }
   @@switch
   @Controller()
   export class HeroService {
     @GrpcMethod()
     findOne(data, metadata) {
       const items = [
         { id: 1, name: 'John' },
         { id: 2, name: 'Doe' },
       ];
       return items.find(({ id }) => id === data.id);
     }
   }

Client
^^^^^^

In order to create a client instance, we need to use ``@Client()``
decorator.

.. code:: typescript

   @Client({
     transport: Transport.GRPC,
     options: {
       package: 'hero',
       protoPath: join(__dirname, 'hero/hero.proto'),
     },
   })
   client: ClientGrpc;

There is a small difference compared to the previous examples. Instead
of the ``ClientProxy`` class, we use the ``ClientGrpc`` that provides a
``getService()`` method. The ``getService()`` generic method takes
service name as an argument and returns its instance if available.

.. code:: typescript

   @@filename(hero.controller)
   onModuleInit() {
     this.heroService = this.client.getService<HeroService>('HeroService');
   }
   @@switch
   onModuleInit() {
     this.heroService = this.client.getService('HeroService');
   }

The ``heroService`` object exposes the same set of methods that have
been defined inside ``.proto`` file. Note, all of them are
**lowercased** (in order to follow the natural convention). Basically,
our gRPC ``HeroService`` definition contains ``FindOne()`` function. It
means that ``heroService`` instance will provide the ``findOne()``
method.

.. code:: typescript

   interface HeroService {
     findOne(data: { id: number }): Observable<any>;
   }

All service methods return ``Observable``. Since Nest supports
`RxJS <https://github.com/reactivex/rxjs>`_ streams and works pretty
well with them, we can return them within HTTP handler as well.

.. code:: typescript

   @@filename(hero.controller)
   @Get()
   call(): Observable<any> {
     return this.heroService.findOne({ id: 1 });
   }
   @@switch
   @Get()
   call() {
     return this.heroService.findOne({ id: 1 });
   }

A full working example is available
`here <https://github.com/nestjs/nest/tree/master/sample/04-grpc>`__.
