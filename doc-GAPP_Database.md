# Documentation: GAPP Database

This is the documentation for `gapp_db_production` database, written by Alex J. K. XU on April 20, 2022.  

[TOC]

## Overall

This document explains, as required, the database system and some of the internal details used for the GAPP website in the current production environment (at the time of writing). I'll list all the fields in each table in alphabetical order, explain the main role the table plays, and explain some of the details.

## Development Team

@author	Mr. Xun ZHANG					xzhang2487-c@my.cityu.edu.hk		

Mainly responsible for building the following data tables: account_roles, accounts, account_roles, roles, users. Responsible for the initial creation of the database on the server side and overseeing data migration.

@author	Mr. Jiakai XU			  			jiakai.xu@my.cityu.edu.hk		

Mainly responsible for building the following data tables: active_storage, analyses, apps, categories. Responsible for the monitoring and daily maintenance of the database.

@author	Miss Yuqin HUANG			  yqhuang23-c@my.cityu.edu.hk		

Mainly responsible for building the following data tables: active_storage, tasks, users.

## Database Version

**PostgreSQL**

## Explanation of the files

As requested, I provided the database definition tables (DDL) in this folder, SQL scripts to insert the current existing data, and JSON record files to facilitate later inspection of objects in the database. 

However, it is important to note that we never attempt to use those SQL files to manipulate the database directly, and  due to rails' built-in database controls, **we strongly discourage direct manipulation of the database** (especially for database / table building). 

<u>**Using the data manipulation provided by the Rails Console or the admin interface already provided on our website is highly recommended.**</u>

## Set up database

Please refer to our Technical Director, Ms. Yanfei WANG, for guidance on the project page (`~/gapp_rails/readme.md`). The general process is as follows:

```bash
#for mac user
createuser --interactive

#for linux user
sudo su - postgres
createuser --interactive
exit

bin/rails db:create

bin/rails db:migrate

```

## Tables in the database

### Overview diagram

![Image text](https://homepage.cs.cityu.edu.hk/jiakaixu2/project/gapp.database.diagram)

### Rails active storage mechanism 

We use the Active Storage mechanism provided by Rails itself to store all the data files, including gene files uploaded by users, cover images and panel data provided by App producers, and so on.

It contains the following two tables, which are managed by Rails and we won't emphasize the internal details in this documentation.

#### active_storage_attachments

```sql
create table if not exists active_storage_attachments (
    id          bigserial primary key,
    name        varchar   not null,
    record_type varchar   not null,
    record_id   bigint    not null,
    blob_id     bigint    not null,
    created_at  timestamp not null
);
```

#### active_storage_blobs

```sql
create table if not exists active_storage_blobs (
    id           bigserial primary key,
    key          varchar   not null,
    filename     varchar   not null,
    content_type varchar,
    metadata     text,
    byte_size    bigint    not null,
    checksum     varchar   not null,
    created_at   timestamp not null
);
```

### User authentication and permissions

We use *devise*, *cancan*, and *rolify* to set up a user rights management system for our GAPP website.

#### roles

```sql
create table if not exists roles (
    id         bigserial    primary key,
    name       varchar,
    created_at timestamp(6) not null,
    updated_at timestamp(6) not null
);
```

Roles usually support "admin", "producer", and "user" in descending order of privileges. Roles with higher privileges have all the privileges of roles with lower privileges. As a metaphor, I usually like to compare Admin to the manager of Taobao website, Producer is equivalent to the account of seller, User is equivalent to the account of buyer registered by our ordinary people, and Visitor without account is another person who opens taobao web page while surfing the Internet.

#### accounts

```sql
create table if not exists accounts (
    id                     bigserial	primary key,
    email                  varchar default ''::character varying not null,
    encrypted_password     varchar default ''::character varying not null,
    reset_password_token   varchar,
    reset_password_sent_at timestamp,
    remember_created_at    timestamp,
    sign_in_count          integer default 0  not null,
    current_sign_in_at     timestamp,
    last_sign_in_at        timestamp,
    current_sign_in_ip     inet,
    last_sign_in_ip        inet,
    confirmation_token     varchar,
    confirmed_at           timestamp,
    confirmation_sent_at   timestamp,
    unconfirmed_email      varchar,
    failed_attempts        integer default 0  not null,
    unlock_token           varchar,
    locked_at              timestamp,
    created_at             timestamp(6)   not null,
    updated_at             timestamp(6)   not null,
    invitation_token       varchar,
    invitation_created_at  timestamp,
    invitation_sent_at     timestamp,
    invitation_accepted_at timestamp,
    invitation_limit       integer,
    invited_by_type        varchar,
    invited_by_id          bigint,
    invitations_count      integer default 0
);
```

You may have some difficulty creating users for the first time due to our server not being able to send any e-mail, etc. Fortunately, our talented colleague Mr. Xun ZHANG has written a detailed use and development manual in our group's gitlab platform (`~/gapp_account_system/readme.md`), you are welcome to check it out. Basically, after you have the Rails Console open, you can use the following code to create your first user (administrator account):

```ruby
Account.create(email: "xxx@xxx.xxx", password: "asdasd", password_confirmation: "asdasd")
Account.find(1).roles = []
Account.find(1).add_role "admin"
Account.find(1).confirm
```

Please note:

- Account is only used to control login and identity systems. User is used elsewhere. Therefore, the user ID may be different from the account ID. The recommended way to find the user ID is:

  ```ruby
  @uid=User.find_by(account_id: current_account.id).id
  ```

- When a new Account is registered, a corresponding User is automatically generated. The default User name is set to the part before the @ symbol of the Account.

- The User automatically generated with an Account has the account_id field pointing to the Account for future updates.

- When the role of a User is changed from the admin control screen, the role of the corresponding Account is also updated.

- If a User is deleted from the admin control page, the corresponding Account is also deleted.

#### account_roles

```sql
create table if not exists account_roles (
    id            bigserial	primary key,
    name          varchar,
    resource_type varchar,
    resource_id   bigint,
    created_at    timestamp(6) not null,
    updated_at    timestamp(6) not null
);
```

#### accounts_account_roles

```sql
create table if not exists accounts_account_roles (
    account_id      bigint,
    account_role_id bigint
);
```

This table, which we added ourselves, provides a mapping between the account system and the original user system.

#### users

```sql
create table if not exists users (
    id              bigserial	primary key,
    username        varchar,
    password_digest varchar,
    "dataFiles"     character varying[] default '{}'::character varying[],
    created_at      timestamp(6) not null,
    updated_at      timestamp(6) not null,
    role_id         bigint,
    account_id      bigint
);
```

In this table I want to emphasize the `dataFiles` field. This field, associated with the active storage mentioned earlier, is an array in which each object points to a personal genetic file uploaded by the user. Under current Settings, a user should hold up to two genetic files at a time.

**Special note:** 

- File size limits are controlled in many ways. First of all, if you choose to use the "direct upload" method, in `~/gapp_rails/app/controllers/users_controller.rb`, we artificially set a file size limit of 1 ~ 1024*1024 bytes to save storage space on the server. Secondly, whether you use "direct upload" or "server-side attach", you are limited by the HTTPS connection response time and the default restrictions (if any) that Active Storage places on your system. Because the configuration of different servers and networks varies, we do not consider setting any extra limits in this regard, but at the same time we do not artificially expand or remove these limits.

### analyses

```sql
create table if not exists analyses (
    id                 bigserial	primary key,
    name               varchar not null,
    doap_id            integer not null,
    param_for_userid   varchar,
    param_for_filename varchar,
    ispipeline         boolean
);
```

This table provides a back-end core analysis method that the any APP can use. 

`doad_id` is the ID number of the corresponding analysis method provided by you on the Deepomics core analysis platform. 

In addition, `param_for_userid` and `param_for_filename` are the two fields that we set during the deepomics Module development phase. They specify the port number that the different modules can receive files on, so in the case of Module, The `ispipeline` field is certainly set to false. Therefore, in a production environment, we have the following entry.

```json
{
    "id": 10,
    "name": "GeneAPP 2nd (GAPP_workflow)",
    "doap_id": 736,
    "param_for_userid": "p-1777",
    "param_for_filename": "p-1776",
    "ispipeline": false
}
```

However, as we entered the later stage of Pipeline development (early 2022), we found that the original two input ports did not meet our needs. Mr. Jiakai XU, one of our genius developers, foresees that a given number of two input ports would obviously be difficult to maintain if we were to continuously develop the website in the future, neither on the GAPP side nor the Deepomics side. Based on this, Mr. XU proposed the idea of <u>T</u>ask <u>S</u>ubmission <u>U</u>sing <u>T</u>ransfered <u>J</u>son <u>F</u>ile (TSUTJF).

Under the guidance of the new idea, our pipeline (starting from Main02) only needs one input port number to run. Therefore, we have the following entry for the analysis method of pipeline.

```json
{
    "id": 12,
    "name": "GeneAPP Pipeline (GAPP_Main02)",
    "doap_id": 65,
    "param_for_userid": "i-160",
    "param_for_filename": "no_use_for_pipeline",
    "ispipeline": true
}
```

However, since the project manager made it clear that this part of the analysis method does not need to be maintained dynamically at any time, because only a handful of analysis methods will be available to developers in the future. There is no user interface for this part to be maintained, and it needs to be edited in the Rails Console for now.

### apps

```sql
create table if not exists apps (
    id            bigserial	   primary key,
    app_no        varchar,
    name          varchar      not null,
    price         integer      not null,
    description   text         not null,
    create_report boolean default false,
    status        varchar default 'offline'::character varying,
    user_id       bigint,
    analysis_id   bigint,
    category_id   bigint,
    cover_image   varchar,
    panel         varchar,
    created_at    timestamp(6) not null,
    updated_at    timestamp(6) not null
);
```

This table is all the information about the product, the APP.

The point we need to make is that `app_no` is not an `id` number, but a meaningful, easy-to-read string that can acts as an ID to some extent though (because each category has different letters and the categories are sorted in ascending order, such as CD-000005), I will mention this part again when we go to the [categories](###categories) part later.

`cover_image` and `panel` are both pointers to active storage files and are responsible for storing the uploaded files. While `user_id`, `analysis_id`, and `category_id` are three foreign keys that points to its producer's id, analyze method, and its category respectively.

### categories

```sql
create table if not exists categories (
    id         bigserial	primary key,
    name       varchar not null,
    initial    varchar,
    serial     bigint,
    created_at timestamp,
    updated_at timestamp
);
```

This table is the category information of each APP. Among all fields, the `initial` is the representative letter of the category, such as CD for "cancer detection" or T for "testing", which defaults to capitalize the first letter of each word in the name string you enter in the admin page. And the field `serial` is a rails controlled id number which will be increased by one when one app of this category is built. So, if we have one more App for Cancer Detection now, of course, its `initial` is "CD" and the `serial` maybe is "5" according to the sequence, then your new app will have a permanent call number [CD-000005] other than the internal id maybe "75".

### tasks

```sql
create table if not exists tasks (
    id              bigserial	 primary key,
    name            varchar,
    user_id         bigint       not null,
    created_at      timestamp(6) not null,
    updated_at      timestamp(6) not null,
    app_id          bigint       not null,
    task_id         varchar,
    status          varchar,
    generate_report boolean
);
```

This table is the information for the tasks created by the user. He stores all the information about a task, such as which APP it belongs to, which user created it, how well it went on, whether it succeeded or failed?

Of all the fields, I'd like to highlight one, `task_id`, which is stored in an encrypted string to keep user information secure. Such as "Wrvjq4GlzYA8w1eE". To actually use it for deepomics queries, there is one more decoding operation to complete, which you can do in `~/gapp_rails/app/controllers/tasks_controller.rb` using the following code.

```ruby
@tid=decode(task.task_id)
```

## In the end

Finally, this is all about our gapp database system. It's time to say goodbye to you, thank you for reading our development documentation, and we the GAPP development team would like to wish you all the best in your work! If you have any questions, please ask our corresponding developers according to the specific types of problems. We will try our best to help you solve the problems and improve our products together. Thank you very much!

Jiakai XU
On behalf of the GAPP development team
April 20, 2022

## Reference

None
