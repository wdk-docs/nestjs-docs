??          T               ?      ?   	   ?   ?   ?     /  p  8  e   ?  |       ?  	   ?  ?   ?    *  p  3  e   ?   Asynchronous providers Injection The above example is for demonstration purposes. If you’re looking for more detailed one, `see here </recipes/sql-typeorm>`__. The asynchronous providers can be simply injected to other components by their tokens (in the above case, by the ``ASYNC_CONNECTION`` token). Each class that depends on the asynchronous provider will be instantiated once the async provider is **already resolved**. When the application start has to be delayed until some **asynchronous tasks** will be finished, for example, until the connection with the database will be established, you should consider using asynchronous providers. In order to create an ``async`` provider, we use the ``useFactory``. The factory has to return a ``Promise`` (thus ``async`` functions fit as well). info **Hint** Learn more about the custom providers syntax `here </fundamentals/custom-providers>`__. Project-Id-Version: nestjs docs 
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
 异步提供程序 Injection The above example is for demonstration purposes. If you’re looking for more detailed one, `see here </recipes/sql-typeorm>`__. The asynchronous providers can be simply injected to other components by their tokens (in the above case, by the ``ASYNC_CONNECTION`` token). Each class that depends on the asynchronous provider will be instantiated once the async provider is **already resolved**. When the application start has to be delayed until some **asynchronous tasks** will be finished, for example, until the connection with the database will be established, you should consider using asynchronous providers. In order to create an ``async`` provider, we use the ``useFactory``. The factory has to return a ``Promise`` (thus ``async`` functions fit as well). info **Hint** Learn more about the custom providers syntax `here </fundamentals/custom-providers>`__. 