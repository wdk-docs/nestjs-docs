Custom route decorators
===============================================

Nest is built around a language feature called **decorators**.
Decorators are a well-known concept in a lot of commonly used
programming languages, but in the JavaScript world, they’re still
relatively new. In order to better understand how decorators work, we
recommend reading `this
article <https://medium.com/google-developers/exploring-es7-decorators-76ecb65fb841>`__.
Here’s a simple definition:

.. raw:: html

   <blockquote class="external">

An ES2016 decorator is an expression which returns a function and can
take a target, name and property descriptor as arguments. You apply it
by prefixing the decorator with an @ character and placing this at the
very top of what you are trying to decorate. Decorators can be defined
for either a class or a property.

.. raw:: html

   </blockquote>

Param decorators
^^^^^^^^^^^^^^^^

Nest provides a set of useful **param decorators** that you can use
together with the HTTP route handlers. Below is a list of the provided
decorators and the plain Express (or Fastify) objects they represent

.. raw:: html

   <table>

.. raw:: html

   <tbody>

.. raw:: html

   <tr>

.. raw:: html

   <td>

@Request()

.. raw:: html

   </td>

.. raw:: html

   <td>

req

.. raw:: html

   </td>

.. raw:: html

   </tr>

.. raw:: html

   <tr>

.. raw:: html

   <td>

@Response()

.. raw:: html

   </td>

.. raw:: html

   <td>

res

.. raw:: html

   </td>

.. raw:: html

   </tr>

.. raw:: html

   <tr>

.. raw:: html

   <td>

@Next()

.. raw:: html

   </td>

.. raw:: html

   <td>

next

.. raw:: html

   </td>

.. raw:: html

   </tr>

.. raw:: html

   <tr>

.. raw:: html

   <td>

@Session()

.. raw:: html

   </td>

.. raw:: html

   <td>

req.session

.. raw:: html

   </td>

.. raw:: html

   </tr>

.. raw:: html

   <tr>

.. raw:: html

   <td>

@Param(param?: string)

.. raw:: html

   </td>

.. raw:: html

   <td>

req.params / req.params[param]

.. raw:: html

   </td>

.. raw:: html

   </tr>

.. raw:: html

   <tr>

.. raw:: html

   <td>

@Body(param?: string)

.. raw:: html

   </td>

.. raw:: html

   <td>

req.body / req.body[param]

.. raw:: html

   </td>

.. raw:: html

   </tr>

.. raw:: html

   <tr>

.. raw:: html

   <td>

@Query(param?: string)

.. raw:: html

   </td>

.. raw:: html

   <td>

req.query / req.query[param]

.. raw:: html

   </td>

.. raw:: html

   </tr>

.. raw:: html

   <tr>

.. raw:: html

   <td>

@Headers(param?: string)

.. raw:: html

   </td>

.. raw:: html

   <td>

req.headers / req.headers[param]

.. raw:: html

   </td>

.. raw:: html

   </tr>

.. raw:: html

   </tbody>

.. raw:: html

   </table>

Additionally, you can create your own **custom decorators**. Why is this
useful?

In the node.js world, it’s common practice to attach properties to the
**request** object. Then you manually extract them in each route
handler, using code like the following:

.. code:: typescript

   const user = req.user;

In order to make your code more readable and transparent, you can create
a ``@User()`` decorator and reuse it across all of your controllers.

.. code:: typescript

   @@filename(user.decorator)
   import { createParamDecorator } from '@nestjs/common';

   export const User = createParamDecorator((data, req) => {
     return req.user;
   });

Then, you can simply use it wherever it fits your requirements.

.. code:: typescript

   @@filename()
   @Get()
   async findOne(@User() user: UserEntity) {
     console.log(user);
   }
   @@switch
   @Get()
   @Bind(User())
   async findOne(user) {
     console.log(user);
   }

Passing data
^^^^^^^^^^^^

When the behavior of your decorator depends on some conditions, you can
use the ``data`` parameter to pass an argument to the decorator’s
factory function. One use case for this is a custom decorator that
extracts properties from the request object by key. Let’s assume, for
example, that our authentication layer validates requests and attaches a
user entity to the request object. The user entity for an authenticated
request might look like:

.. code:: json

   {
     "id": 101,
     "firstName": "Alan",
     "lastName": "Turing",
     "email": "alan@email.com",
     "roles": ["admin"]
   }

Let’s define a decorator that takes a property name as key, and returns
the associated value if it exists (or undefined if it doesn’t exist, or
if the ``user`` object has not been created).

.. code:: typescript

   @@filename(user.decorator)
   import { createParamDecorator } from '@nestjs/common';

   export const User = createParamDecorator((data: string, req) => {
     return data ? req.user && req.user[data] : req.user;
   });
   @@switch
   import { createParamDecorator } from '@nestjs/common';

   export const User = createParamDecorator((data, req) => {
     return data ? req.user && req.user[data] : req.user;
   });

Here’s how you could then access a particular property via the
``@User()`` decorator in the controller:

.. code:: typescript

   @@filename()
   @Get()
   async findOne(@User('firstName') firstName: string) {
     console.log(`Hello ${firstName}`);
   }
   @@switch
   @Get()
   @Bind(User('firstName'))
   async findOne(firstName) {
     console.log(`Hello ${firstName}`);
   }

You can use this same decorator with different keys to access different
properties. If the ``user`` object is deep or complex, this can make for
easier and more readable request handler implementations.

Working with pipes
^^^^^^^^^^^^^^^^^^

Nest treats custom param decorators in the same fashion as the built-in
ones (``@Body()``, ``@Param()`` and ``@Query()``). This means that pipes
are executed for the custom annotated parameters as well (in our
examples, the ``user`` argument). Moreover, you can apply the pipe
directly to the custom decorator:

.. code:: typescript

   @@filename()
   @Get()
   async findOne(@User(new ValidationPipe()) user: UserEntity) {
     console.log(user);
   }
   @@switch
   @Get()
   @Bind(User(new ValidationPipe()))
   async findOne(user) {
     console.log(user);
   }
