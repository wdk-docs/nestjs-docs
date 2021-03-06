??          ?               ?   <   ?   C   :  ?   ~  
     @     ?  ]  7   ?  .   5  9   d  ]   ?     ?       ?     |  ?  <   N  C   ?  ?   ?  
   b  @   m  ?  ?  7   N
  .   ?
  9   ?
  ]   ?
     M     T  ?   a   Afterward, we need to register ``DateScalar`` as a provider. And now we are able to use ``Date`` scalar in our type definitions. Another form of defining the scalar type is to create a simple class. Let’s say that we would like to enhance our schema with the ``Date`` type. Code first In order to create a ``Date`` scalar, simply create a new class. In order to define a custom scalar (read more about scalars `here <https://www.apollographql.com/docs/graphql-tools/scalars.html>`__), we have to create a type definition and a dedicated resolver as well. Here (as in the official documentation), we’ll take the ``graphql-type-json`` package for demonstration purposes. This npm package defines a ``JSON`` GraphQL scalar type. Firstly, let’s install the package: Now we can use ``JSON`` scalar in our type definitions: Now you can use ``Date`` type in your classes. Once it’s ready, register ``DateScalar`` as a provider. Once the package is installed, we have to pass a custom resolver to the ``forRoot()`` method: Scalars Schema first The GraphQL includes the following default types: ``Int``, ``Float``, ``String``, ``Boolean`` and ``ID``. However, sometimes you may need to support custom atomic data types (e.g. ``Date``). Project-Id-Version: nestjs docs 
Report-Msgid-Bugs-To: 
POT-Creation-Date: 2019-06-22 13:40+0800
PO-Revision-Date: YEAR-MO-DA HO:MI+ZONE
Last-Translator: FULL NAME <EMAIL@ADDRESS>
Language: zh_CN
Language-Team: zh_CN <LL@li.org>
Plural-Forms: nplurals=1; plural=0
MIME-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: 8bit
Generated-By: Babel 2.6.0
 Afterward, we need to register ``DateScalar`` as a provider. And now we are able to use ``Date`` scalar in our type definitions. Another form of defining the scalar type is to create a simple class. Let’s say that we would like to enhance our schema with the ``Date`` type. Code first In order to create a ``Date`` scalar, simply create a new class. In order to define a custom scalar (read more about scalars `here <https://www.apollographql.com/docs/graphql-tools/scalars.html>`__), we have to create a type definition and a dedicated resolver as well. Here (as in the official documentation), we’ll take the ``graphql-type-json`` package for demonstration purposes. This npm package defines a ``JSON`` GraphQL scalar type. Firstly, let’s install the package: Now we can use ``JSON`` scalar in our type definitions: Now you can use ``Date`` type in your classes. Once it’s ready, register ``DateScalar`` as a provider. Once the package is installed, we have to pass a custom resolver to the ``forRoot()`` method: 标量 Schema first The GraphQL includes the following default types: ``Int``, ``Float``, ``String``, ``Boolean`` and ``ID``. However, sometimes you may need to support custom atomic data types (e.g. ``Date``). 