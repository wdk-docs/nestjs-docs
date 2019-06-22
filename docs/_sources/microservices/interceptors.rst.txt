Interceptors
======================

There is no difference between `regular interceptors </interceptors>`__
and the microservices interceptors. Here is an example that makes use of
a manually instantiated method-scoped interceptor (class-scoped works
too):

.. code:: typescript

   @@filename()
   @UseInterceptors(new TransformInterceptor())
   @MessagePattern({ cmd: 'sum' })
   accumulate(data: number[]): number {
     return (data || []).reduce((a, b) => a + b);
   }
   @@switch
   @UseInterceptors(new TransformInterceptor())
   @MessagePattern({ cmd: 'sum' })
   accumulate(data) {
     return (data || []).reduce((a, b) => a + b);
   }
