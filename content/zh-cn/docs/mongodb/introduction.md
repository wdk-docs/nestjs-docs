---
title: "Introduction to MongoDB"
linkTitle: "介绍"
weight: 43
---

So far, in this series, we’ve focused on working with SQL and the Postgres database. While PostgreSQL is an excellent choice, it is worth checking out the alternatives. In this article, we learn about how MongoDB works and how it differs from SQL databases. We also create a simple application with MongoDB and NestJS.

You can find the source code from the below article in this repository.

MongoDB vs. SQL Databases
The design principles of MongoDB differ quite a bit from traditional SQL databases. Instead of representing data with tables and rows, MongoDB stores it as JSON-like documents. Therefore, it is relatively easy to grasp for developers familiar with JavaScript.

Documents in MongoDB consist of key and value pairs. The significant aspect of them is that the keys can differ across documents in a given collection. This is a big difference between MongoDB and SQL databases. It makes MongoDB a lot more flexible and less structured. Therefore, it can be perceived either as an advantage or a drawback.

Advantages and drawbacks of MongoDB
Since MongoDB and SQL databases differ so much, choosing the right tool for a given job is crucial. Since NoSQL databases put fewer restrictions on the data, it might be a good choice for an application evolving quickly. We still might need to update our data as our schema changes.

For example, we might want to add a new property containing the user’s avatar URL. When it happens, we still should deal with documents not containing our new property. We can do that by writing a script that puts a default value for old documents. Alternatively, we can assume that this field can be missing and handle it differently on the application level.

On the contrary, adding a new property to an existing SQL database requires writing a migration that explicitly handles the new property. This might seem like a bit of a chore in a lot of cases. However, with MongoDB, it is not required. This might make the work easier and faster, but we need to watch out and not lose the integrity of our data.

If you want to know more about SQL migrations, check out The basics of migrations using TypeORM and Postgres

SQL databases such as Postgres keep the data in tables consisting of columns and rows. A big part of the design process is defining relationships between the above tables. For example, a user can be an author of an article. On the other hand, MongoDB is a non-relational database. Therefore, while we can mimic SQL-style relationships with MongoDB, they will not be as efficient and foolproof.

Using MongoDB with NestJS
So far, in this series, we’ve used Docker to set up the architecture for our project. We can easily achieve that with MongoDB also.

docker-compose.yml

```yml
version: "3"
services:
mongo:
image: mongo:latest
environment:
MONGO_INITDB_ROOT_USERNAME: ${MONGO_USERNAME}
MONGO_INITDB_ROOT_PASSWORD: ${MONGO_PASSWORD}
MONGO_INITDB_DATABASE: ${MONGO_DATABASE}
ports: - '27017:27017'
```

Above, you can see that we refer to a few variables. Let’s put them into our .env file:

.env

```env
MONGO_USERNAME=admin
MONGO_PASSWORD=admin
MONGO_DATABASE=nestjs
MONGO_HOST=localhost:27017
```

In the previous parts of this series, we’ve used TypeORM to connect to our PostgreSQL database and manage our data. For MongoDB, the most popular library is Mongoose.

npm install --save @nestjs/mongoose mongoose
Let’s use Mongoose to connect to our database. To do that, we need to define a URI connection string:

app.module.ts

```ts
import { Module } from '@nestjs/common';
import { MongooseModule } from '@nestjs/mongoose';
import { ConfigModule, ConfigService } from '@nestjs/config';
import PostsModule from './posts/posts.module';
import \* as Joi from '@hapi/joi';

@Module({
imports: [
ConfigModule.forRoot({
validationSchema: Joi.object({
MONGO_USERNAME: Joi.string().required(),
MONGO_PASSWORD: Joi.string().required(),
MONGO_DATABASE: Joi.string().required(),
MONGO_PATH: Joi.string().required(),
}),
}),
MongooseModule.forRootAsync({
imports: [ConfigModule],
useFactory: async (configService: ConfigService) => {
const username = configService.get('MONGO_USERNAME');
const password = configService.get('MONGO_PASSWORD');
const database = configService.get('MONGO_DATABASE');
const host = configService.get('MONGO_HOST');

        return {
          uri: `mongodb://${username}:${password}@${host}`,
          dbName: database,
        };
      },
      inject: [ConfigService],
    }),
    PostsModule,

],
controllers: [],
providers: [],
})
export class AppModule {}
```

Saving and retrieving data
With MongoDB, we operate on documents grouped into collections. To start saving and retrieving data with MongoDB and Mongoose, we first need to define a schema. This might seem surprising at first because MongoDB is considered schemaless. Even though MongoDB is flexible, Mongoose uses schemas to operate on collections and define their shape.

Defining a schema
Every schema maps to a single MongoDB collection. It also defines the shape of the documents within it.

post.schema.ts

```ts
import { Prop, Schema, SchemaFactory } from "@nestjs/mongoose";
import { Document } from "mongoose";

export type PostDocument = Post & Document;

@Schema()
export class Post {
  @Prop()
  title: string;

  @Prop()
  content: string;
}

export const PostSchema = SchemaFactory.createForClass(Post);
```

With the @Schema() decorator, we can mark our class as a schema definition and map it to a MongoDB collection. We use the @Prop() decorator to definite a property of our document. Thanks to TypeScript metadata, the schema types for our properties are automatically inferred.

We will expand on the topic of defining a schema in the upcoming articles.

Working with a model
Mongoose wraps our schemas into models. We can use them to create and read documents. For our service to use the model, we need to add it to our module.

posts.module.ts

```ts
import { Module } from "@nestjs/common";
import { MongooseModule } from "@nestjs/mongoose";
import PostsController from "./posts.controller";
import PostsService from "./posts.service";
import { Post, PostSchema } from "./post.schema";

@Module({
  imports: [MongooseModule.forFeature([{ name: Post.name, schema: PostSchema }])],
  controllers: [PostsController],
  providers: [PostsService],
})
class PostsModule {}

export default PostsModule;
```

We also need to inject the model into our service:

posts.service.ts

```ts
import { Model } from "mongoose";
import { Injectable } from "@nestjs/common";
import { InjectModel } from "@nestjs/mongoose";
import { Post, PostDocument } from "./post.schema";

@Injectable()
class PostsService {
  constructor(@InjectModel(Post.name) private postModel: Model<PostDocument>) {}
}

export default PostsService;
```

Once we do that, we can start interacting with our collection.

Fetching all entities
The most basic thing we can do is to fetch the list of all of the documents. To do that, we need the find() method:

posts.service.ts

```ts
import { Model } from "mongoose";
import { Injectable } from "@nestjs/common";
import { InjectModel } from "@nestjs/mongoose";
import { Post, PostDocument } from "./post.schema";

@Injectable()
class PostsService {
  constructor(@InjectModel(Post.name) private postModel: Model<PostDocument>) {}

  async findAll() {
    return this.postModel.find();
  }
}
```

Fetching a single entity
Every document we create is assigned with a string id. If we want to fetch a single document, we can use the findById method:

posts.service.ts

````ts
import { Model } from 'mongoose';
import { Injectable } from '@nestjs/common';
import { InjectModel } from '@nestjs/mongoose';
import { Post, PostDocument } from './post.schema';
import { NotFoundException } from '@nestjs/common';

@Injectable()
class PostsService {
constructor(@InjectModel(Post.name) private postModel: Model<PostDocument>) {}

async findOne(id: string) {
const post = await this.postModel.findById(id);
if (!post) {
throw new NotFoundException();
}
return post;
}

// ...
}
```ts
Creating entities
In the fourth part of this series, we’ve tackled data validation. Let’s create a Data Transfer Object for our entity.

post.dto.ts
```ts
import { IsString, IsNotEmpty } from 'class-validator';

export class PostDto {
@IsString()
@IsNotEmpty()
title: string;

@IsString()
@IsNotEmpty()
content: string;
}

export default PostDto;
```ts
We can now use it when creating a new instance of our model and saving it.

posts.service.ts
```ts
import { Model } from 'mongoose';
import { Injectable } from '@nestjs/common';
import { InjectModel } from '@nestjs/mongoose';
import { Post, PostDocument } from './post.schema';
import PostDto from './dto/post.dto';

@Injectable()
class PostsService {
constructor(@InjectModel(Post.name) private postModel: Model<PostDocument>) {}

create(postData: PostDto) {
const createdPost = new this.postModel(postData);
return createdPost.save();
}

// ...
}
````

Updating entities
We might also need to update an entity we’ve already created. To do that, we can use the findByIdAndUpdate method:

posts.service.ts

```ts
import { Model } from "mongoose";
import { Injectable } from "@nestjs/common";
import { InjectModel } from "@nestjs/mongoose";
import { Post, PostDocument } from "./post.schema";
import { NotFoundException } from "@nestjs/common";
import PostDto from "./dto/post.dto";

@Injectable()
class PostsService {
  constructor(@InjectModel(Post.name) private postModel: Model<PostDocument>) {}

  async update(id: string, postData: PostDto) {
    const post = await this.postModel.findByIdAndUpdate(id, postData).setOptions({ overwrite: true, new: true });
    if (!post) {
      throw new NotFoundException();
    }
    return post;
  }

  // ...
}
```

Above, a few important things are happening. Thanks to using the new: true parameter, the findByIdAndUpdate method returns an updated version of our entity.

By using overwrite: true, we indicate that we want to replace a whole document instead of performing a partial update. This is what differentiates the PUT and PATCH HTTP methods.

If you want to know more, check out TypeScript Express tutorial #15. Using PUT vs PATCH in MongoDB with Mongoose.

Deleting entities
To delete an existing entity, we need to use the findByIdAndDelete method:

posts.service.ts

```ts
import { Model } from "mongoose";
import { Injectable } from "@nestjs/common";
import { InjectModel } from "@nestjs/mongoose";
import { Post, PostDocument } from "./post.schema";
import { NotFoundException } from "@nestjs/common";

@Injectable()
class PostsService {
  constructor(@InjectModel(Post.name) private postModel: Model<PostDocument>) {}

  async delete(postId: string) {
    const result = await this.postModel.findByIdAndDelete(postId);
    if (!result) {
      throw new NotFoundException();
    }
  }

  // ...
}
```

Defining a controller
Once we’ve got our service up and running, we can use it with our controller:

posts.controller.ts

````ts
import {
Body,
Controller,
Delete,
Get,
Param,
Post,
Put,
} from '@nestjs/common';
import PostsService from './posts.service';
import ParamsWithId from '../utils/paramsWithId';
import PostDto from './dto/post.dto';

@Controller('posts')
export default class PostsController {
constructor(private readonly postsService: PostsService) {}

@Get()
async getAllPosts() {
return this.postsService.findAll();
}

@Get(':id')
async getPost(@Param() { id }: ParamsWithId) {
return this.postsService.findOne(id);
}

@Post()
async createPost(@Body() post: PostDto) {
return this.postsService.create(post);
}

@Delete(':id')
async deletePost(@Param() { id }: ParamsWithId) {
return this.postsService.delete(id);
}

@Put(':id')
async updatePost(@Param() { id }: ParamsWithId, @Body() post: PostDto) {
return this.postsService.update(id, post);
}
}
```ts
The crucial part above is that we’ve defined the ParamsWithId class. With it, we can validate if the provided string is a valid MongoDB id:

paramsWithId.ts
```ts
import { IsMongoId } from 'class-validator';

class ParamsWithId {
@IsMongoId()
id: string;
}

export default ParamsWithId;
````

Summary
In this article, we’ve learned the very basics of how to use MongoDB with NestJS. To do that, we’ve created a local MongoDB database using Docker Compose and connected it with NestJS and Mongoose. To better grasp MongoDB, we’ve also compared it to SQL databases such as Postgres. There are still a lot of things to cover when it comes to MongoDB, so stay tuned!
