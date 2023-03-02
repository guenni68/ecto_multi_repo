# EctoMultiRepo

<!-- README START -->

## Description

EctoMultiRepo is a "batteries included" library that allows you to 
create ecto repos dynamically at runtime.

## Usage

Create a module like:

```elixir
defmodule MyPostgresRepo do
  use EctoMultiRepo,
    # required
    # may be one of
    # - :postgres
    # - :mysql
    # - :mssql
    database_type: :postgres,

    # optional, defaults to 15 seconds
    # specifies the call timeout
    # see the documentation for Ecto.Repo :timeout
    # value in milliseconds
    timeout: :timer.seconds(15),

    # optional, defaults to 10 minutes
    # specifies the idle timeout of a dynamically
    # created repo / database connection.
    # every interaction with the repository resets the
    # timer 
    idle_timeout: :timer.minutes(10)
end

```

in your repository's client or in IEX do the following:

```elixir
...
database_host_name = "mypostgresserver.com"
port = 5432
database = "dummy_db_one"
username = "user_one"
password = "secret1"

{:ok, dummy0} =
  MyPostgresRepo.start_repo(
    database_host_name,
    port,
    database,
    username,
    password
  )

{:ok, result} = MyPostgresRepo.query(dummy0, "select 4 + 5")

# or alternatively, if you want to avoid multiple repo processes
# with identical configuration

dummy1 =
  :cryto.hash(
    :md5,
    [database_host_name, port, database, username, password]
  )
  |> Base.encode64()

{:ok, ^dummy1} =
  MyPostgresRepo.start_repo(
    dummy1,
    database_host_name,
    port,
    database,
    username,
    password
  )

```

almost all of Ecto.Repo methods are supported and should work as expected,
however you do need to prefix them with the repo's process handle, in this
case **dummy0**.

### Example
```elixir
{:ok, res} = MyPostgresRepo.query(dummy0, "select 4 + 5")

```

You may create as many dynamic connections based on **MyPostgresRepo** as you like
and you may also create as many repo modules in your code as you like, with different
configurations and with different types of backends.

### Things to consider when using dynamic repos:

Your client process and the repo process are __not__ linked, just as with vanilla
Ecto.Repo, which is why they timeout when idle. Otherwise there'd be dangling repo
processes that would stay alive forever.

That means that even if your client process may still be up and running, the repo
process may have timed out and ended because of inactivity.

You can avoid this by having your client process executing

```elixir
MyPostgresRepo.noop(dummy0)
```

in regular intervals.

## Installation

If [available in Hex](https://hex.pm/docs/publish), the package can be installed
by adding `ecto_multi_repo` to your list of dependencies in `mix.exs`:

```elixir
def deps do
  [
    {:ecto_multi_repo, "~> 0.1.0"}
  ]
end
```

Documentation can be generated with [ExDoc](https://github.com/elixir-lang/ex_doc)
and published on [HexDocs](https://hexdocs.pm). Once published, the docs can
be found at [https://hexdocs.pm/ecto_multi_repo](https://hexdocs.pm/ecto_multi_repo).

