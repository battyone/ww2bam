## Who Wants to Be a Millionaire?

### Description

Web app based on the [famous game](https://en.wikipedia.org/wiki/Who_Wants_to_Be_a_Millionaire?).

App covered with views, models, controllers and features tests.

Three types of lifelines are implemented (Ask the Audience, 50:50 and Phone a Friend).

Admin can load questions from files (see `data` folder).

The app uses the data of [good programmer](https://goodprogrammer.ru).

Realized in Ruby on Rails. Language: Russian.

### Launching

1. Download or clone repo. Use bundler

```console
$ bundle install
```

NB: If you want at the same time create the database, load the schema and initialize it with the seed data run

```console
$ rails db:setup
```

Skip Items 2-4 in this case.

2. Create database

```console
$ rails db:create
```

3. Run database migrations

```console
$ rails db:migrate
```

4. If you want to populate your database with seed data run

```console
$ rails db:seed
```

5. To make the user says with id `7` admin run

```console
$ rails c
>> User.find(7).toggle!(:is_admin)
```

### License

MIT – see `LICENSE`

### Contacts

Email me at

```rb
'dcdl-snotynu?fl`hk-bnl'.each_char.map(&:succ).join
```
