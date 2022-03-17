---
title: "Virtual properties with MongoDB and Mongoose"
linkTitle: "虚拟属性"
weight: 45
---

In this series, we’ve used Mongoose to define properties in our schemas and work with models for documents. We’ve also defined various relations between collections. With Mongoose, we can also take advantage of virtual properties that are not stored in MongoDB. To understand them, we first grasp the concept of getters and setters.

You can find the code from this article in this repository.

## Getters and setters with Mongoose

We can execute custom logic when we get and set properties in a document with getters and setters.

### Getters

By using getters, we can modify the data of a document when we retrieve it. Let’s create an example when the user has a credit card number that we want to obfuscate when responding to the API request.

user.schema.ts

```ts
import { Prop, Schema, SchemaFactory } from "@nestjs/mongoose";
import { Document } from "mongoose";

export type UserDocument = User & Document;

@Schema({
  toJSON: {
    getters: true,
  },
})
export class User {
  @Prop({ unique: true })
  email: string;

  @Prop({
    get: (creditCardNumber: string) => {
      if (!creditCardNumber) {
        return;
      }
      const lastFourDigits = creditCardNumber.slice(creditCardNumber.length - 4);
      return `****-****-****-${lastFourDigits}`;
    },
  })
  creditCardNumber?: string;

  // ...
}

export const UserSchema = SchemaFactory.createForClass(User);
```

When we return the documents from our API, NestJS stringifies our data. When that happens, the toJSON method is called on our Mongoose models. Therefore, if we want our getters to be considered, we need to add getters: true to our configuration explicitly.

Documents also have the toObject method and we can customize it in a similar way.

We also use toJSON in our MongooseClassSerializerInterceptor. For more details, check out API with NestJS #44. Implementing relationships with MongoDB

In our code above, we obfuscate the credit card number every time we return the user’s document from our API.

Mongoose assignes our schemas a virtual getter for the id field. It now appears in the response because we’ve turned on getters through getters: true. More on virtuals later.

There are times where we want to access the original, non-modified property. To do that, we can use the Document.prototype.get() function.

```ts
const user = await this.usersService.getByEmail(email);
const creditCardNumber = await this.usersService.getByEmail(email);
```

### Setters

With setters, we can modify the data before saving it in the database.

post.schema.ts

```ts
import { Prop, Schema, SchemaFactory } from "@nestjs/mongoose";
import { Document, ObjectId } from "mongoose";
import { Transform } from "class-transformer";

export type PostDocument = Post & Document;

@Schema()
export class Post {
  @Transform(({ value }) => value.toString())
  _id: ObjectId;

  @Prop()
  title: string;

  @Prop({
    set: (content: string) => {
      return content.trim();
    },
  })
  content: string;

  // ...
}

export const PostSchema = SchemaFactory.createForClass(Post);
```

Thanks to doing the above, we now remove whitespace from both ends of the content string.

While setters are a valid technique, you might prefer to put this logic in the service for increased readability. However, even if that’s the case, setters are worth knowing.

## Virtual properties

A virtual is a property that we can get and set, but it is not stored inside the database. Let’s define a simple example of a use case.

user.schema.ts

```ts
import { Prop, Schema, SchemaFactory } from "@nestjs/mongoose";
import { Document } from "mongoose";

export type UserDocument = User & Document;

@Schema()
export class User {
  @Prop()
  firstName: string;

  @Prop()
  lastName: string;

  @Prop()
  fullName: string;

  // ...
}

export const UserSchema = SchemaFactory.createForClass(User);
```

The above approach is flawed, unfortunately. If we persist the fullName property into MongoDB, we duplicate the information because we already have the firstName and lastName. A more appropriate approach would be to create the fullName on the fly based on other properties.

### Getters

We can achieve the above with the virtual property. So, let’s create it along with a getter.

user.schema.ts

```ts
import { Prop, Schema, SchemaFactory } from "@nestjs/mongoose";
import { Document } from "mongoose";

export type UserDocument = User & Document;

@Schema({
  toJSON: {
    virtuals: true,
  },
})
export class User {
  @Prop()
  firstName: string;

  @Prop()
  lastName: string;

  fullName: string;

  // ...
}

const UserSchema = SchemaFactory.createForClass(User);

UserSchema.virtual("fullName").get(function (this: UserDocument) {
  return `${this.firstName} ${this.lastName}`;
});

export { UserSchema };
```

Please notice that we don’t use the @Prop() decorator on the fullName property. Instead, we call the UserSchema.virtual function at the bottom of the file.

Thanks to adding virtuals: true, our virtual properties are visible when converting a document to JSON. Even though we can see fullName in the above response, it isn’t saved to the database.

### Setters

With virtual, we can also create setters. We can use them, for example, to set multiple properties at once.

user.schema.ts

```ts
import { Prop, Schema, SchemaFactory } from "@nestjs/mongoose";
import { Document, ObjectId } from "mongoose";
import { Transform } from "class-transformer";
export type UserDocument = User & Document;

@Schema({
  toJSON: {
    getters: true,
    virtuals: true,
  },
})
export class User {
  @Prop()
  firstName: string;

  @Prop()
  lastName: string;

  fullName: string;

  // ...
}

const UserSchema = SchemaFactory.createForClass(User);

UserSchema.virtual("fullName")
  .get(function (this: UserDocument) {
    return `${this.firstName} ${this.lastName}`;
  })
  .set(function (this: UserDocument, fullName: string) {
    const [firstName, lastName] = fullName.split(" ");
    this.set({ firstName, lastName });
  });

export { UserSchema };
```

Above, we set the firstName and lastName properties based on the fullName.

## Populating virtual properties

A handy feature of virtual properties is using them to populate documents from another collection.

We learn the basics of the populate feature in API with NestJS #44. Implementing relationships with MongoDB

In an example in the previous article, we create a schema for a post, using it to store the reference to the author.

post.schema.ts

```ts
import { Prop, Schema, SchemaFactory } from "@nestjs/mongoose";
import { Document, ObjectId } from "mongoose";
import * as mongoose from "mongoose";
import { User } from "../users/user.schema";
import { Transform, Type } from "class-transformer";

export type PostDocument = Post & Document;

@Schema()
export class Post {
  @Transform(({ value }) => value.toString())
  _id: ObjectId;

  @Prop()
  title: string;

  @Prop()
  content: string;

  @Prop({ type: mongoose.Schema.Types.ObjectId, ref: User.name })
  @Type(() => User)
  author: User;
}

export const PostSchema = SchemaFactory.createForClass(Post);
```

Therefore, when we fetch the User document, we don’t have information about any posts. We can use virtual properties to tackle this issue.

user.schema.ts

```ts
import { Prop, Schema, SchemaFactory } from "@nestjs/mongoose";
import { Document } from "mongoose";
import { Type } from "class-transformer";
import { Post } from "../posts/post.schema";

export type UserDocument = User & Document;

@Schema({
  toJSON: {
    getters: true,
    virtuals: true,
  },
})
export class User {
  @Prop({ unique: true })
  email: string;

  @Type(() => Post)
  posts: Post[];

  // ...
}

const UserSchema = SchemaFactory.createForClass(User);

UserSchema.virtual("posts", {
  ref: "Post",
  localField: "_id",
  foreignField: "author",
});

export { UserSchema };
```

The last step is to call the populate function along with the document of the user. While we’re at it, we can also populate the nested categories property.

users.service.ts

```ts
import { Injectable, NotFoundException } from "@nestjs/common";
import { InjectModel } from "@nestjs/mongoose";
import { Model } from "mongoose";
import { UserDocument, User } from "./user.schema";

@Injectable()
export class UsersService {
  constructor(@InjectModel(User.name) private userModel: Model<UserDocument>) {}

  async getById(id: string) {
    const user = await this.userModel.findById(id).populate({
      path: "posts",
      populate: {
        path: "categories",
      },
    });

    if (!user) {
      throw new NotFoundException();
    }

    return user;
  }
}
```

## Summary

In this article, we’ve learned what virtual properties are how they can be useful. We’ve used them both to add simple properties and populate documents from other collections. To better grasp the concept of virtual, we’ve also investigated getters and setters. All of the above can surely come in handy when using Mongoose to define MongoDB schemas.
