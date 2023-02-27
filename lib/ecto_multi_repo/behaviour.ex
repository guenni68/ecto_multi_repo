defmodule EctoMultiRepo.Behaviour do
  @type t :: module

  defmacro __using__(_opts) do
    quote do
      @behaviour unquote(__MODULE__)
    end
  end

  ## User callbacks

  ## Ecto.Adapter

  @callback noop(id :: String.t()) :: any()

  @doc """
  Returns the adapter configuration stored in the `:otp_app` environment.

  If the `c:init/2` callback is implemented in the repository,
  it will be invoked with the first argument set to `:runtime`.
  """
  @doc group: "Runtime API"
  @callback config(id :: String.t()) :: Keyword.t()

  @doc """
  Checks out a connection for the duration of the function.

  It returns the result of the function. This is useful when
  you need to perform multiple operations against the repository
  in a row and you want to avoid checking out the connection
  multiple times.

  `checkout/2` and `transaction/2` can be combined and nested
  multiple times. If `checkout/2` is called inside the function
  of another `checkout/2` call, the function is simply executed,
  without checking out a new connection.

  ## Options

  See the ["Shared options"](#module-shared-options) section at the module
  documentation for more options.
  """
  @doc group: "Transaction API"
  @callback checkout(id :: String.t(), (() -> result), opts :: Keyword.t()) :: result
            when result: var

  @doc """
  Returns true if a connection has been checked out.

  This is true if inside a `c:Ecto.Repo.checkout/2` or
  `c:Ecto.Repo.transaction/2`.

  ## Examples

      MyRepo.checked_out?
      #=> false

      MyRepo.transaction(fn ->
        MyRepo.checked_out? #=> true
      end)

      MyRepo.checkout(fn ->
        MyRepo.checked_out? #=> true
      end)

  """
  @doc group: "Transaction API"
  @callback checked_out?(id :: String.t()) :: boolean

  @doc """
  Loads `data` into a schema or a map.

  The first argument can be a a schema module or a map (of types).
  The first argument determines the return value: a struct or a map,
  respectively.

  The second argument `data` specifies fields and values that are to be loaded.
  It can be a map, a keyword list, or a `{fields, values}` tuple.
  Fields can be atoms or strings.

  Fields that are not present in the schema (or `types` map) are ignored.
  If any of the values has invalid type, an error is raised.

  To load data from non-database sources, use `Ecto.embedded_load/3`.

  ## Examples

      iex> MyRepo.load(User, %{name: "Alice", age: 25})
      %User{name: "Alice", age: 25}

      iex> MyRepo.load(User, [name: "Alice", age: 25])
      %User{name: "Alice", age: 25}

  `data` can also take form of `{fields, values}`:

      iex> MyRepo.load(User, {[:name, :age], ["Alice", 25]})
      %User{name: "Alice", age: 25, ...}

  The first argument can also be a `types` map:

      iex> types = %{name: :string, age: :integer}
      iex> MyRepo.load(types, %{name: "Alice", age: 25})
      %{name: "Alice", age: 25}

  This function is especially useful when parsing raw query results:

      iex> result = Ecto.Adapters.SQL.query!(MyRepo, "SELECT * FROM users", [])
      iex> Enum.map(result.rows, &MyRepo.load(User, {result.columns, &1}))
      [%User{...}, ...]

  """
  @doc group: "Schema API"
  @callback load(
              id :: String.t(),
              schema_or_map :: module | map(),
              data :: map() | Keyword.t() | {list, list}
            ) :: Ecto.Schema.t() | map()

  ## Ecto.Adapter.Queryable

  @doc """
  Fetches a single struct from the data store where the primary key matches the
  given id.

  Returns `nil` if no result was found. If the struct in the queryable
  has no or more than one primary key, it will raise an argument error.

  ## Options

    * `:prefix` - The prefix to run the query on (such as the schema path
      in Postgres or the database in MySQL). This will be applied to all `from`
      and `join`s in the query that did not have a prefix previously given
      either via the `:prefix` option on `join`/`from` or via `@schema_prefix`
      in the schema. For more information see the "Query Prefix" section of the
      `Ecto.Query` documentation.

  See the ["Shared options"](#module-shared-options) section at the module
  documentation for more options.

  ## Example

      MyRepo.get(Post, 42)

      MyRepo.get(Post, 42, prefix: "public")

  """
  @doc group: "Query API"
  @callback get(
              id :: String.t(),
              queryable :: Ecto.Queryable.t(),
              id :: term,
              opts :: Keyword.t()
            ) ::
              Ecto.Schema.t() | term | nil

  @doc """
  Similar to `c:get/3` but raises `Ecto.NoResultsError` if no record was found.

  ## Options

    * `:prefix` - The prefix to run the query on (such as the schema path
      in Postgres or the database in MySQL). This will be applied to all `from`
      and `join`s in the query that did not have a prefix previously given
      either via the `:prefix` option on `join`/`from` or via `@schema_prefix`
      in the schema. For more information see the "Query Prefix" section of the
      `Ecto.Query` documentation.

  See the ["Shared options"](#module-shared-options) section at the module
  documentation for more options.

  ## Example

      MyRepo.get!(Post, 42)

      MyRepo.get!(Post, 42, prefix: "public")

  """
  @doc group: "Query API"
  @callback get!(
              id :: String.t(),
              queryable :: Ecto.Queryable.t(),
              id :: term,
              opts :: Keyword.t()
            ) ::
              Ecto.Schema.t() | term

  @doc """
  Fetches a single result from the query.

  Returns `nil` if no result was found. Raises if more than one entry.

  ## Options

    * `:prefix` - The prefix to run the query on (such as the schema path
      in Postgres or the database in MySQL). This will be applied to all `from`
      and `join`s in the query that did not have a prefix previously given
      either via the `:prefix` option on `join`/`from` or via `@schema_prefix`
      in the schema. For more information see the "Query Prefix" section of the
      `Ecto.Query` documentation.

  See the ["Shared options"](#module-shared-options) section at the module
  documentation for more options.

  ## Example

      MyRepo.get_by(Post, title: "My post")

      MyRepo.get_by(Post, [title: "My post"], prefix: "public")

  """
  @doc group: "Query API"
  @callback get_by(
              id :: String.t(),
              queryable :: Ecto.Queryable.t(),
              clauses :: Keyword.t() | map,
              opts :: Keyword.t()
            ) :: Ecto.Schema.t() | term | nil

  @doc """
  Similar to `c:get_by/3` but raises `Ecto.NoResultsError` if no record was found.

  Raises if more than one entry.

  ## Options

    * `:prefix` - The prefix to run the query on (such as the schema path
      in Postgres or the database in MySQL). This will be applied to all `from`
      and `join`s in the query that did not have a prefix previously given
      either via the `:prefix` option on `join`/`from` or via `@schema_prefix`
      in the schema. For more information see the "Query Prefix" section of the
      `Ecto.Query` documentation.

  See the ["Shared options"](#module-shared-options) section at the module
  documentation for more options.

  ## Example

      MyRepo.get_by!(Post, title: "My post")

      MyRepo.get_by!(Post, [title: "My post"], prefix: "public")

  """
  @doc group: "Query API"
  @callback get_by!(
              id :: String.t(),
              queryable :: Ecto.Queryable.t(),
              clauses :: Keyword.t() | map,
              opts :: Keyword.t()
            ) :: Ecto.Schema.t() | term

  @doc """
  Reloads a given schema or schema list from the database.

  When using with lists, it is expected that all of the structs in the list belong
  to the same schema. Ordering is guaranteed to be kept. Results not found in
  the database will be returned as `nil`.

  ## Example

      MyRepo.reload(post)
      %Post{}

      MyRepo.reload([post1, post2])
      [%Post{}, %Post{}]

      MyRepo.reload([deleted_post, post1])
      [nil, %Post{}]
  """
  @doc group: "Schema API"
  @callback reload(
              id :: String.t(),
              struct_or_structs :: Ecto.Schema.t() | [Ecto.Schema.t()],
              opts :: Keyword.t()
            ) :: Ecto.Schema.t() | [Ecto.Schema.t() | nil] | nil

  @doc """
  Similar to `c:reload/2`, but raises when something is not found.

  When using with lists, ordering is guaranteed to be kept.

  ## Example

      MyRepo.reload!(post)
      %Post{}

      MyRepo.reload!([post1, post2])
      [%Post{}, %Post{}]
  """
  @doc group: "Schema API"
  @callback reload!(
              id :: String.t(),
              struct_or_structs,
              opts :: Keyword.t()
            ) :: struct_or_structs
            when struct_or_structs: Ecto.Schema.t() | [Ecto.Schema.t()]

  @doc """
  Calculate the given `aggregate`.

  If the query has a limit, offset, distinct or combination set, it will be
  automatically wrapped in a subquery in order to return the
  proper result.

  Any preload or select in the query will be ignored in favor of
  the column being aggregated.

  The aggregation will fail if any `group_by` field is set.

  ## Options

    * `:prefix` - The prefix to run the query on (such as the schema path
      in Postgres or the database in MySQL). This will be applied to all `from`
      and `join`s in the query that did not have a prefix previously given
      either via the `:prefix` option on `join`/`from` or via `@schema_prefix`
      in the schema. For more information see the "Query Prefix" section of the
      `Ecto.Query` documentation.

  See the ["Shared options"](#module-shared-options) section at the module
  documentation for more options.

  ## Examples

      # Returns the number of blog posts
      Repo.aggregate(Post, :count)

      # Returns the number of blog posts in the "private" schema path
      # (in Postgres) or database (in MySQL)
      Repo.aggregate(Post, :count, prefix: "private")

  """
  @doc group: "Query API"
  @callback aggregate(
              id :: String.t(),
              queryable :: Ecto.Queryable.t(),
              aggregate :: :count,
              opts :: Keyword.t()
            ) :: term | nil

  @doc """
  Calculate the given `aggregate` over the given `field`.

  See `c:aggregate/3` for general considerations and options.

  ## Examples

      # Returns the sum of the number of visits for every blog post
      Repo.aggregate(Post, :sum, :visits)

      # Returns the sum of the number of visits for every blog post in the
      # "private" schema path (in Postgres) or database (in MySQL)
      Repo.aggregate(Post, :sum, :visits, prefix: "private")

      # Returns the average number of visits for the first 10 blog posts
      query = from Post, limit: 10
      Repo.aggregate(query, :avg, :visits)
  """
  @doc group: "Query API"
  @callback aggregate(
              id :: String.t(),
              queryable :: Ecto.Queryable.t(),
              aggregate :: :avg | :count | :max | :min | :sum,
              field :: atom,
              opts :: Keyword.t()
            ) :: term | nil

  @doc """
  Checks if there exists an entry that matches the given query.

  Returns a boolean.

  ## Options

    * `:prefix` - The prefix to run the query on (such as the schema path
      in Postgres or the database in MySQL). This will be applied to all `from`
      and `join`s in the query that did not have a prefix previously given
      either via the `:prefix` option on `join`/`from` or via `@schema_prefix`
      in the schema. For more information see the "Query Prefix" section of the
      `Ecto.Query` documentation.

  See the ["Shared options"](#module-shared-options) section at the module
  documentation for more options.

  ## Examples

      # checks if any posts exist
      Repo.exists?(Post)

      # checks if any posts exist in the "private" schema path (in Postgres) or
      # database (in MySQL)
      Repo.exists?(Post, schema: "private")

      # checks if any post with a like count greater than 10 exists
      query = from p in Post, where: p.like_count > 10
      Repo.exists?(query)
  """
  @doc group: "Query API"
  @callback exists?(
              id :: String.t(),
              queryable :: Ecto.Queryable.t(),
              opts :: Keyword.t()
            ) :: boolean()

  @doc """
  Fetches a single result from the query.

  Returns `nil` if no result was found. Raises if more than one entry.

  ## Options

    * `:prefix` - The prefix to run the query on (such as the schema path
      in Postgres or the database in MySQL). This will be applied to all `from`
      and `join`s in the query that did not have a prefix previously given
      either via the `:prefix` option on `join`/`from` or via `@schema_prefix`
      in the schema. For more information see the "Query Prefix" section of the
      `Ecto.Query` documentation.

  See the ["Shared options"](#module-shared-options) section at the module
  documentation for more options.

  ## Examples

      Repo.one(from p in Post, join: c in assoc(p, :comments), where: p.id == ^post_id)

      query = from p in Post, join: c in assoc(p, :comments), where: p.id == ^post_id
      Repo.one(query, prefix: "private")
  """
  @doc group: "Query API"
  @callback one(
              id :: String.t(),
              queryable :: Ecto.Queryable.t(),
              opts :: Keyword.t()
            ) ::
              Ecto.Schema.t() | term | nil

  @doc """
  Similar to `c:one/2` but raises `Ecto.NoResultsError` if no record was found.

  Raises if more than one entry.

  ## Options

    * `:prefix` - The prefix to run the query on (such as the schema path
      in Postgres or the database in MySQL). This will be applied to all `from`
      and `join`s in the query that did not have a prefix previously given
      either via the `:prefix` option on `join`/`from` or via `@schema_prefix`
      in the schema. For more information see the "Query Prefix" section of the
      `Ecto.Query` documentation.

  See the ["Shared options"](#module-shared-options) section at the module
  documentation for more options.
  """
  @doc group: "Query API"
  @callback one!(
              id :: String.t(),
              queryable :: Ecto.Queryable.t(),
              opts :: Keyword.t()
            ) ::
              Ecto.Schema.t() | term

  @doc """
  Preloads all associations on the given struct or structs.

  This is similar to `Ecto.Query.preload/3` except it allows
  you to preload structs after they have been fetched from the
  database.

  In case the association was already loaded, preload won't attempt
  to reload it.

  If you want to reset the loaded fields, see `Ecto.reset_fields/2`.

  ## Options

    * `:force` - By default, Ecto won't preload associations that
      are already loaded. By setting this option to true, any existing
      association will be discarded and reloaded.
    * `:in_parallel` - If the preloads must be done in parallel. It can
      only be performed when we have more than one preload and the
      repository is not in a transaction. Defaults to `true`.
    * `:prefix` - the prefix to fetch preloads from. By default, queries
      will use the same prefix as the first struct in the given collection.
      This option allows the prefix to be changed.

  See the ["Shared options"](#module-shared-options) section at the module
  documentation for more options.

  ## Examples

      # Use a single atom to preload an association
      posts = Repo.preload posts, :comments

      # Use a list of atoms to preload multiple associations
      posts = Repo.preload posts, [:comments, :authors]

      # Use a keyword list to preload nested associations as well
      posts = Repo.preload posts, [comments: [:replies, :likes], authors: []]

      # You can mix atoms and keywords, but the atoms must come first
      posts = Repo.preload posts, [:authors, comments: [:likes, replies: [:reactions]]]

      # Use a keyword list to customize how associations are queried
      posts = Repo.preload posts, [comments: from(c in Comment, order_by: c.published_at)]

      # Use a two-element tuple for a custom query and nested association definition
      query = from c in Comment, order_by: c.published_at
      posts = Repo.preload posts, [comments: {query, [:replies, :likes]}]

  The query given to preload may also preload its own associations.
  """
  @doc group: "Schema API"
  @callback preload(
              id :: String.t(),
              structs_or_struct_or_nil,
              preloads :: term,
              opts :: Keyword.t()
            ) ::
              structs_or_struct_or_nil
            when structs_or_struct_or_nil: [Ecto.Schema.t()] | Ecto.Schema.t() | nil

  @doc """
  A user customizable callback invoked for query-based operations.

  This callback can be used to further modify the query and options
  before it is transformed and sent to the database.

  This callback is invoked for all query APIs, including the `stream`
  functions. It is also invoked for `insert_all` if a source query is
  given. It is not invoked for any of the other schema functions.

  ## Examples

  Let's say you want to filter out records that were "soft-deleted"
  (have `deleted_at` column set) from all operations unless an admin
  is running the query; you can define the callback like this:

      @impl true
      def prepare_query(_operation, query, opts) do
        if opts[:admin] do
          {query, opts}
        else
          query = from(x in query, where: is_nil(x.deleted_at))
          {query, opts}
        end
      end

  And then execute the query:

      Repo.all(query)              # only non-deleted records are returned
      Repo.all(query, admin: true) # all records are returned

  The callback will be invoked for all queries, including queries
  made from associations and preloads. It is not invoked for each
  individual join inside a query.
  """
  @doc group: "User callbacks"
  @callback prepare_query(
              id :: String.t(),
              operation,
              query :: Ecto.Query.t(),
              opts :: Keyword.t()
            ) ::
              {Ecto.Query.t(), Keyword.t()}
            when operation: :all | :update_all | :delete_all | :stream | :insert_all

  @doc """
  A user customizable callback invoked to retrieve default options
  for operations.

  This can be used to provide default values per operation that
  have higher precedence than the values given on configuration
  or when starting the repository. It can also be used to set
  query specific options, such as `:prefix`.

  This callback is invoked as the entry point for all repository
  operations. For example, if you are executing a query with preloads,
  this callback will be invoked once at the beginning, but the
  options returned here will be passed to all following operations.
  """
  @doc group: "User callbacks"
  @callback default_options(
              id :: String.t(),
              operation
            ) :: Keyword.t()
            when operation:
                   :all
                   | :insert_all
                   | :update_all
                   | :delete_all
                   | :stream
                   | :transaction
                   | :insert
                   | :update
                   | :delete
                   | :insert_or_update

  @doc """
  Fetches all entries from the data store matching the given query.

  May raise `Ecto.QueryError` if query validation fails.

  ## Options

    * `:prefix` - The prefix to run the query on (such as the schema path
      in Postgres or the database in MySQL). This will be applied to all `from`
      and `join`s in the query that did not have a prefix previously given
      either via the `:prefix` option on `join`/`from` or via `@schema_prefix`
      in the schema. For more information see the "Query Prefix" section of the
      `Ecto.Query` documentation.

  See the ["Shared options"](#module-shared-options) section at the module
  documentation for more options.

  ## Example

      # Fetch all post titles
      query = from p in Post,
           select: p.title
      MyRepo.all(query)
  """
  @doc group: "Query API"
  @callback all(
              id :: String.t(),
              queryable :: Ecto.Queryable.t(),
              opts :: Keyword.t()
            ) :: [Ecto.Schema.t() | term]

  @doc """
  Returns a lazy enumerable that emits all entries from the data store
  matching the given query.

  SQL adapters, such as Postgres and MySQL, can only enumerate a stream
  inside a transaction.

  May raise `Ecto.QueryError` if query validation fails.

  ## Options

    * `:prefix` - The prefix to run the query on (such as the schema path
      in Postgres or the database in MySQL). This will be applied to all `from`
      and `join`s in the query that did not have a prefix previously given
      either via the `:prefix` option on `join`/`from` or via `@schema_prefix`
      in the schema. For more information see the "Query Prefix" section of the
      `Ecto.Query` documentation.

    * `:max_rows` - The number of rows to load from the database as we stream.
      It is supported at least by Postgres and MySQL and defaults to 500.

  See the ["Shared options"](#module-shared-options) section at the module
  documentation for more options.

  ## Example

      # Fetch all post titles
      query = from p in Post,
           select: p.title
      stream = MyRepo.stream(query)
      MyRepo.transaction(fn ->
        Enum.to_list(stream)
      end)
  """
  @doc group: "Query API"
  @callback stream(id :: String.t(), queryable :: Ecto.Queryable.t(), opts :: Keyword.t()) ::
              Enum.t()

  @doc """
  Updates all entries matching the given query with the given values.

  It returns a tuple containing the number of entries and any returned
  result as second element. The second element is `nil` by default
  unless a `select` is supplied in the update query. Note, however,
  not all databases support returning data from UPDATEs.

  Keep in mind this `update_all` will not update autogenerated
  fields like the `updated_at` columns.

  See `Ecto.Query.update/3` for update operations that can be
  performed on fields.

  ## Options

    * `:prefix` - The prefix to run the query on (such as the schema path
      in Postgres or the database in MySQL). This will be applied to all `from`
      and `join`s in the query that did not have a prefix previously given
      either via the `:prefix` option on `join`/`from` or via `@schema_prefix`
      in the schema. For more information see the "Query Prefix" section of the
      `Ecto.Query` documentation.

  See the ["Shared options"](#module-shared-options) section at the module
  documentation for remaining options.

  ## Examples

      MyRepo.update_all(Post, set: [title: "New title"])

      MyRepo.update_all(Post, inc: [visits: 1])

      from(p in Post, where: p.id < 10, select: p.visits)
      |> MyRepo.update_all(set: [title: "New title"])

      from(p in Post, where: p.id < 10, update: [set: [title: "New title"]])
      |> MyRepo.update_all([])

      from(p in Post, where: p.id < 10, update: [set: [title: ^new_title]])
      |> MyRepo.update_all([])

      from(p in Post, where: p.id < 10, update: [set: [title: fragment("upper(?)", ^new_title)]])
      |> MyRepo.update_all([])

      from(p in Post, where: p.id < 10, update: [set: [visits: p.visits * 1000]])
      |> MyRepo.update_all([])

  """
  @doc group: "Query API"
  @callback update_all(
              id :: String.t(),
              queryable :: Ecto.Queryable.t(),
              updates :: Keyword.t(),
              opts :: Keyword.t()
            ) :: {non_neg_integer, nil | [term]}

  @doc """
  Deletes all entries matching the given query.

  It returns a tuple containing the number of entries and any returned
  result as second element. The second element is `nil` by default
  unless a `select` is supplied in the delete query. Note, however,
  not all databases support returning data from DELETEs.

  ## Options

    * `:prefix` - The prefix to run the query on (such as the schema path
      in Postgres or the database in MySQL). This will be applied to all `from`
      and `join`s in the query that did not have a prefix previously given
      either via the `:prefix` option on `join`/`from` or via `@schema_prefix`
      in the schema. For more information see the "Query Prefix" section of the
      `Ecto.Query` documentation.

  See the ["Shared options"](#module-shared-options) section at the module
  documentation for remaining options.

  ## Examples

      MyRepo.delete_all(Post)

      from(p in Post, where: p.id < 10) |> MyRepo.delete_all
  """
  @doc group: "Query API"
  @callback delete_all(id :: String.t(), queryable :: Ecto.Queryable.t(), opts :: Keyword.t()) ::
              {non_neg_integer, nil | [term]}

  ## Ecto.Adapter.Schema

  @doc """
  Inserts all entries into the repository.

  It expects a schema module (`MyApp.User`) or a source (`"users"`) or
  both (`{"users", MyApp.User}`) as the first argument. The second
  argument is a list of entries to be inserted, either as keyword
  lists or as maps. The keys of the entries are the field names as
  atoms and the value should be the respective value for the field
  type or, optionally, an `Ecto.Query` that returns a single entry
  with a single value.

  It returns a tuple containing the number of entries
  and any returned result as second element. If the database
  does not support RETURNING in INSERT statements or no
  return result was selected, the second element will be `nil`.

  When a schema module is given, the entries given will be properly dumped
  before being sent to the database. If the schema primary key has type
  `:id` or `:binary_id`, it will be handled either at the adapter
  or the storage layer. However any other primary key type or autogenerated
  value, like `Ecto.UUID` and timestamps, won't be autogenerated when
  using `c:insert_all/3`. You must set those fields explicitly. This is by
  design as this function aims to be a more direct way to insert data into
  the database without the conveniences of `c:insert/2`. This is also
  consistent with `c:update_all/3` that does not handle auto generated
  values as well.

  It is also not possible to use `insert_all` to insert across multiple
  tables, therefore associations are not supported.

  If a source is given, without a schema module, the given fields are passed
  as is to the adapter.

  ## Options

    * `:returning` - selects which fields to return. When `true`,
      returns all fields in the given schema. May be a list of
      fields, where a struct is still returned but only with the
      given fields. Or `false`, where nothing is returned (the default).
      This option is not supported by all databases.

    * `:prefix` - The prefix to run the query on (such as the schema path
      in Postgres or the database in MySQL). This overrides the prefix set
      in the query and any `@schema_prefix` set in the schema.

    * `:on_conflict` - It may be one of `:raise` (the default), `:nothing`,
      `:replace_all`, `{:replace_all_except, fields}`, `{:replace, fields}`,
      a keyword list of update instructions or an `Ecto.Query`
      query for updates. See the "Upserts" section for more information.

    * `:conflict_target` - A list of column names to verify for conflicts.
      It is expected those columns to have unique indexes on them that may conflict.
      If none is specified, the conflict target is left up to the database.
      It may also be `{:unsafe_fragment, binary_fragment}` to pass any
      expression to the database without any sanitization, this is useful
      for partial index or index with expressions, such as
      `{:unsafe_fragment, "(coalesce(firstname, ""), coalesce(lastname, "")) WHERE middlename IS NULL"}` for
      `ON CONFLICT (coalesce(firstname, ""), coalesce(lastname, "")) WHERE middlename IS NULL` SQL query.

    * `:placeholders` - A map with placeholders. This feature is not supported
      by all databases. See the "Placeholders" section for more information.

  See the ["Shared options"](#module-shared-options) section at the module
  documentation for remaining options.

  ## Source query

  A query can be given instead of a list with entries. This query needs to select
  into a map containing only keys that are available as writeable columns in the
  schema.

  ## Examples

      MyRepo.insert_all(Post, [[title: "My first post"], [title: "My second post"]])

      MyRepo.insert_all(Post, [%{title: "My first post"}, %{title: "My second post"}])

      query = from p in Post,
        join: c in assoc(p, :comments),
        select: %{
          author_id: p.author_id,
          posts: count(p.id, :distinct),
          interactions: sum(p.likes) + count(c.id)
        },
        group_by: p.author_id
      MyRepo.insert_all(AuthorStats, query)

  ## Upserts

  `c:insert_all/3` provides upserts (update or inserts) via the `:on_conflict`
  option. The `:on_conflict` option supports the following values:

    * `:raise` - raises if there is a conflicting primary key or unique index

    * `:nothing` - ignores the error in case of conflicts

    * `:replace_all` - replace **all** values on the existing row with the values
      in the schema/changeset, including fields not explicitly set in the changeset,
      such as IDs and autogenerated timestamps (`inserted_at` and `updated_at`).
      Do not use this option if you have auto-incrementing primary keys, as they
      will also be replaced. You most likely want to use `{:replace_all_except, [:id]}`
      or `{:replace, fields}` explicitly instead. This option requires a schema

    * `{:replace_all_except, fields}` - same as above except the given fields
      are not replaced. This option requires a schema

    * `{:replace, fields}` - replace only specific columns. This option requires
      `:conflict_target`

    * a keyword list of update instructions - such as the one given to
      `c:update_all/3`, for example: `[set: [title: "new title"]]`

    * an `Ecto.Query` that will act as an `UPDATE` statement, such as the
      one given to `c:update_all/3`

  Upserts map to "ON CONFLICT" on databases like Postgres and "ON DUPLICATE KEY"
  on databases such as MySQL.

  ## Return values

  By default, both Postgres and MySQL will return the number of entries
  inserted on `c:insert_all/3`. However, when the `:on_conflict` option
  is specified, Postgres and MySQL will return different results.

  Postgres will only count a row if it was affected and will
  return 0 if no new entry was added.

  MySQL will return, at a minimum, the number of entries attempted. For example,
  if `:on_conflict` is set to `:nothing`, MySQL will return
  the number of entries attempted to be inserted, even when no entry
  was added.

  Also note that if `:on_conflict` is a query, MySQL will return
  the number of attempted entries plus the number of entries modified
  by the UPDATE query.

  ## Placeholders

  Passing in a map for the `:placeholders` allows you to send less
  data over the wire when you have many entries with the same value
  for a field. To use a placeholder, replace its value in each of your
  entries with `{:placeholder, key}`,  where `key` is the key you
  are using in the `:placeholders` option map. For example:

      placeholders = %{blob: large_blob_of_text(...)}

      entries = [
        %{title: "v1", body: {:placeholder, :blob}},
        %{title: "v2", body: {:placeholder, :blob}}
      ]

      Repo.insert_all(Post, entries, placeholders: placeholders)

  Keep in mind that:

    * placeholders cannot be nested in other values. For example, you
      cannot put a placeholder inside an array. Instead, the whole
      array has to be the placeholder

    * a placeholder key can only be used with columns of the same type

    * placeholders require a database that supports index parameters,
      so they are not currently compatible with MySQL

  """
  @doc group: "Schema API"
  @callback insert_all(
              id :: String.t(),
              schema_or_source :: binary | {binary, module} | module,
              entries_or_query :: [%{atom => value} | Keyword.t(value)] | Ecto.Query.t(),
              opts :: Keyword.t()
            ) :: {non_neg_integer, nil | [term]}
            when value: term | Ecto.Query.t()

  @doc """
  Inserts a struct defined via `Ecto.Schema` or a changeset.

  In case a struct is given, the struct is converted into a changeset
  with all non-nil fields as part of the changeset.

  In case a changeset is given, the changes in the changeset are
  merged with the struct fields, and all of them are sent to the
  database. If more than one database operation is required, they're
  automatically wrapped in a transaction.

  It returns `{:ok, struct}` if the struct has been successfully
  inserted or `{:error, changeset}` if there was a validation
  or a known constraint error.

  ## Options

    * `:returning` - selects which fields to return. It accepts a list
      of fields to be returned from the database. When `true`, returns
      all fields. When `false`, no extra fields are returned. It will
      always include all fields in `read_after_writes` as well as any
      autogenerated id. Not all databases support this option and it
      may not be available during upserts. See the "Upserts" section
      for more information.

    * `:prefix` - The prefix to run the query on (such as the schema path
      in Postgres or the database in MySQL). This overrides the prefix set
      in the query and any `@schema_prefix` set on any schemas. Also, the
      `@schema_prefix` for the parent record will override all default
      `@schema_prefix`s set in any child schemas for associations.

    * `:on_conflict` - It may be one of `:raise` (the default), `:nothing`,
      `:replace_all`, `{:replace_all_except, fields}`, `{:replace, fields}`,
      a keyword list of update instructions or an `Ecto.Query` query for updates.
      See the "Upserts" section for more information.

    * `:conflict_target` - A list of column names to verify for conflicts.
      It is expected those columns to have unique indexes on them that may conflict.
      If none is specified, the conflict target is left up to the database.
      It may also be `{:unsafe_fragment, binary_fragment}` to pass any
      expression to the database without any sanitization, this is useful
      for partial index or index with expressions, such as
      `{:unsafe_fragment, "(coalesce(firstname, ""), coalesce(lastname, "")) WHERE middlename IS NULL"}` for
      `ON CONFLICT (coalesce(firstname, ""), coalesce(lastname, "")) WHERE middlename IS NULL` SQL query.

    * `:stale_error_field` - The field where stale errors will be added in
      the returning changeset. This option can be used to avoid raising
      `Ecto.StaleEntryError`.

    * `:stale_error_message` - The message to add to the configured
      `:stale_error_field` when stale errors happen, defaults to "is stale".

  See the ["Shared options"](#module-shared-options) section at the module
  documentation for more options.

  ## Examples

  A typical example is calling `MyRepo.insert/1` with a struct
  and acting on the return value:

      case MyRepo.insert %Post{title: "Ecto is great"} do
        {:ok, struct}       -> # Inserted with success
        {:error, changeset} -> # Something went wrong
      end

  ## Upserts

  `c:insert/2` provides upserts (update or inserts) via the `:on_conflict`
  option. The `:on_conflict` option supports the following values:

    * `:raise` - raises if there is a conflicting primary key or unique index

    * `:nothing` - ignores the error in case of conflicts

    * `:replace_all` - replace **all** values on the existing row with the values
      in the schema/changeset, including fields not explicitly set in the changeset,
      such as IDs and autogenerated timestamps (`inserted_at` and `updated_at`).
      Do not use this option if you have auto-incrementing primary keys, as they
      will also be replaced. You most likely want to use `{:replace_all_except, [:id]}`
      or `{:replace, fields}` explicitly instead. This option requires a schema

    * `{:replace_all_except, fields}` - same as above except the given fields are
      not replaced. This option requires a schema

    * `{:replace, fields}` - replace only specific columns. This option requires
      `:conflict_target`

    * a keyword list of update instructions - such as the one given to
      `c:update_all/3`, for example: `[set: [title: "new title"]]`

    * an `Ecto.Query` that will act as an `UPDATE` statement, such as the
      one given to `c:update_all/3`. Similarly to `c:update_all/3`, auto
      generated values, such as timestamps are not automatically updated.
      If the struct cannot be found, `Ecto.StaleEntryError` will be raised.

  Upserts map to "ON CONFLICT" on databases like Postgres and "ON DUPLICATE KEY"
  on databases such as MySQL.

  As an example, imagine `:title` is marked as a unique column in
  the database:

      {:ok, inserted} = MyRepo.insert(%Post{title: "this is unique"})

  Now we can insert with the same title but do nothing on conflicts:

      {:ok, ignored} = MyRepo.insert(%Post{title: "this is unique"}, on_conflict: :nothing)

  Because we used `on_conflict: :nothing`, instead of getting an error,
  we got `{:ok, struct}`. However the returned struct does not reflect
  the data in the database. If the primary key is auto-generated by the
  database, the primary key in the `ignored` record will be nil if there
  was no insertion. For example, if you use the default primary key
  (which has name `:id` and a type of `:id`), then `ignored.id` above
  will be nil if there was no insertion.

  If your id is generated by your application (typically the case for
  `:binary_id`) or if you pass another value for `:on_conflict`, detecting
  if an insert or update happened is slightly more complex, as the database
  does not actually inform us what happened. Let's insert a post with the
  same title but use a query to update the body column in case of conflicts:

      # In Postgres (it requires the conflict target for updates):
      on_conflict = [set: [body: "updated"]]
      {:ok, updated} = MyRepo.insert(%Post{title: "this is unique"},
                                     on_conflict: on_conflict, conflict_target: :title)

      # In MySQL (conflict target is not supported):
      on_conflict = [set: [title: "updated"]]
      {:ok, updated} = MyRepo.insert(%Post{id: inserted.id, title: "updated"},
                                     on_conflict: on_conflict)

  In the examples above, even though it returned `:ok`, we do not know
  if we inserted new data or if we updated only the `:on_conflict` fields.
  In case an update happened, the data in the struct most likely does
  not match the data in the database. For example, autogenerated fields
  such as `inserted_at` will point to now rather than the time the
  struct was actually inserted.

  If you need to guarantee the data in the returned struct mirrors the
  database, you have three options:

    * Use `on_conflict: :replace_all`, although that will replace all
      fields in the database with the ones in the struct/changeset,
      including autogenerated fields such as `inserted_at` and `updated_at`:

          MyRepo.insert(%Post{title: "this is unique"},
                        on_conflict: :replace_all, conflict_target: :title)

    * Specify `read_after_writes: true` in your schema for choosing
      fields that are read from the database after every operation.
      Or pass `returning: true` to `insert` to read all fields back.
      (Note that it will only read from the database if at least one
      field is updated).

          MyRepo.insert(%Post{title: "this is unique"}, returning: true,
                        on_conflict: on_conflict, conflict_target: :title)

    * Alternatively, read the data again from the database in a separate
      query. This option requires the primary key to be generated by the
      database:

          {:ok, updated} = MyRepo.insert(%Post{title: "this is unique"}, on_conflict: on_conflict)
          Repo.get(Post, updated.id)

  Because of the inability to know if the struct is up to date or not,
  inserting a struct with associations and using the `:on_conflict` option
  at the same time is not recommended, as Ecto will be unable to actually
  track the proper status of the association.
  """
  @doc group: "Schema API"
  @callback insert(
              id :: String.t(),
              struct_or_changeset :: Ecto.Schema.t() | Ecto.Changeset.t(),
              opts :: Keyword.t()
            ) :: {:ok, Ecto.Schema.t()} | {:error, Ecto.Changeset.t()}

  @doc """
  Updates a changeset using its primary key.

  A changeset is required as it is the only mechanism for
  tracking dirty changes. Only the fields present in the `changes` part
  of the changeset are sent to the database. Any other, in-memory
  changes done to the schema are ignored. If more than one database
  operation is required, they're automatically wrapped in a transaction.

  If the struct has no primary key, `Ecto.NoPrimaryKeyFieldError`
  will be raised.

  If the struct cannot be found, `Ecto.StaleEntryError` will be raised.

  It returns `{:ok, struct}` if the struct has been successfully
  updated or `{:error, changeset}` if there was a validation
  or a known constraint error.

  ## Options

    * `:returning` - selects which fields to return. It accepts a list
      of fields to be returned from the database. When `true`, returns
      all fields. When `false`, no extra fields are returned. It will
      always include all fields in `read_after_writes`. Not all
      databases support this option.

    * `:force` - By default, if there are no changes in the changeset,
      `c:update/2` is a no-op. By setting this option to true, update
      callbacks will always be executed, even if there are no changes
      (including timestamps).

    * `:prefix` - The prefix to run the query on (such as the schema path
      in Postgres or the database in MySQL). This overrides the prefix set
      in the query and any `@schema_prefix` set on any schemas. Also, the
      `@schema_prefix` for the parent record will override all default
      `@schema_prefix`s set in any child schemas for associations.

    * `:stale_error_field` - The field where stale errors will be added in
      the returning changeset. This option can be used to avoid raising
      `Ecto.StaleEntryError`.

    * `:stale_error_message` - The message to add to the configured
      `:stale_error_field` when stale errors happen, defaults to "is stale".

  See the ["Shared options"](#module-shared-options) section at the module
  documentation for more options.

  ## Example

      post = MyRepo.get!(Post, 42)
      post = Ecto.Changeset.change post, title: "New title"
      case MyRepo.update post do
        {:ok, struct}       -> # Updated with success
        {:error, changeset} -> # Something went wrong
      end
  """
  @doc group: "Schema API"
  @callback update(id :: String.t(), changeset :: Ecto.Changeset.t(), opts :: Keyword.t()) ::
              {:ok, Ecto.Schema.t()} | {:error, Ecto.Changeset.t()}

  @doc """
  Inserts or updates a changeset depending on whether the struct is persisted
  or not.

  The distinction whether to insert or update will be made on the
  `Ecto.Schema.Metadata` field `:state`. The `:state` is automatically set by
  Ecto when loading or building a schema.

  Please note that for this to work, you will have to load existing structs from
  the database. So even if the struct exists, this won't work:

      struct = %Post{id: "existing_id", ...}
      MyRepo.insert_or_update changeset
      # => {:error, changeset} # id already exists

  ## Options

    * `:prefix` - The prefix to run the query on (such as the schema path
      in Postgres or the database in MySQL). This overrides the prefix set
      in the query and any `@schema_prefix` set any schemas. Also, the
      `@schema_prefix` for the parent record will override all default
      `@schema_prefix`s set in any child schemas for associations.
    * `:stale_error_field` - The field where stale errors will be added in
      the returning changeset. This option can be used to avoid raising
      `Ecto.StaleEntryError`. Only applies to updates.
    * `:stale_error_message` - The message to add to the configured
      `:stale_error_field` when stale errors happen, defaults to "is stale".
      Only applies to updates.

  See the ["Shared options"](#module-shared-options) section at the module
  documentation for more options.

  ## Example

      result =
        case MyRepo.get(Post, id) do
          nil  -> %Post{id: id} # Post not found, we build one
          post -> post          # Post exists, let's use it
        end
        |> Post.changeset(changes)
        |> MyRepo.insert_or_update

      case result do
        {:ok, struct}       -> # Inserted or updated with success
        {:error, changeset} -> # Something went wrong
      end
  """
  @doc group: "Schema API"
  @callback insert_or_update(
              id :: String.t(),
              changeset :: Ecto.Changeset.t(),
              opts :: Keyword.t()
            ) ::
              {:ok, Ecto.Schema.t()} | {:error, Ecto.Changeset.t()}

  @doc """
  Deletes a struct using its primary key.

  If the struct has no primary key, `Ecto.NoPrimaryKeyFieldError`
  will be raised. If the struct has been removed prior to the call,
  `Ecto.StaleEntryError` will be raised. If more than one database
  operation is required, they're automatically wrapped in a transaction.

  It returns `{:ok, struct}` if the struct has been successfully
  deleted or `{:error, changeset}` if there was a validation
  or a known constraint error. By default, constraint errors will
  raise the `Ecto.ConstraintError` exception, unless a changeset is
  given as the first argument with the relevant constraints declared
  in it (see `Ecto.Changeset`).

  ## Options

    * `:prefix` - The prefix to run the query on (such as the schema path
      in Postgres or the database in MySQL). This overrides the prefix set
      in the query and any `@schema_prefix` set in the schema.

    * `:stale_error_field` - The field where stale errors will be added in
      the returning changeset. This option can be used to avoid raising
      `Ecto.StaleEntryError`.

    * `:stale_error_message` - The message to add to the configured
      `:stale_error_field` when stale errors happen, defaults to "is stale".

  See the ["Shared options"](#module-shared-options) section at the module
  documentation for more options.

  ## Example

      post = MyRepo.get!(Post, 42)
      case MyRepo.delete post do
        {:ok, struct}       -> # Deleted with success
        {:error, changeset} -> # Something went wrong
      end

  """
  @doc group: "Schema API"
  @callback delete(
              id :: String.t(),
              struct_or_changeset :: Ecto.Schema.t() | Ecto.Changeset.t(),
              opts :: Keyword.t()
            ) :: {:ok, Ecto.Schema.t()} | {:error, Ecto.Changeset.t()}

  @doc """
  Same as `c:insert/2` but returns the struct or raises if the changeset is invalid.
  """
  @doc group: "Schema API"
  @callback insert!(
              id :: String.t(),
              struct_or_changeset :: Ecto.Schema.t() | Ecto.Changeset.t(),
              opts :: Keyword.t()
            ) :: Ecto.Schema.t()

  @doc """
  Same as `c:update/2` but returns the struct or raises if the changeset is invalid.
  """
  @doc group: "Schema API"
  @callback update!(id :: String.t(), changeset :: Ecto.Changeset.t(), opts :: Keyword.t()) ::
              Ecto.Schema.t()

  @doc """
  Same as `c:insert_or_update/2` but returns the struct or raises if the changeset
  is invalid.
  """
  @doc group: "Schema API"
  @callback insert_or_update!(
              id :: String.t(),
              changeset :: Ecto.Changeset.t(),
              opts :: Keyword.t()
            ) ::
              Ecto.Schema.t()

  @doc """
  Same as `c:delete/2` but returns the struct or raises if the changeset is invalid.
  """
  @doc group: "Schema API"
  @callback delete!(
              id :: String.t(),
              struct_or_changeset :: Ecto.Schema.t() | Ecto.Changeset.t(),
              opts :: Keyword.t()
            ) :: Ecto.Schema.t()

  ## Ecto.Adapter.Transaction

  @doc """
  Runs the given function or `Ecto.Multi` inside a transaction.

  ## Use with function

  `c:transaction/2` can be called with both a function of arity
  zero or one. The arity zero function will just be executed as is:

      import Ecto.Changeset, only: [change: 2]

      MyRepo.transaction(fn ->
        MyRepo.update!(change(alice, balance: alice.balance - 10))
        MyRepo.update!(change(bob, balance: bob.balance + 10))
      end)

  While the arity one function will receive the repo of the transaction
  as its first argument:

      MyRepo.transaction(fn repo ->
        repo.insert!(%Post{})
      end)

  If an Elixir exception occurs the transaction will be rolled back
  and the exception will bubble up from the transaction function.
  If no exception occurs, the transaction is committed when the
  function returns. A transaction can be explicitly rolled back
  by calling `c:rollback/1`, this will immediately leave the function
  and return the value given to `rollback` as `{:error, value}`.

  A successful transaction returns the value returned by the function
  wrapped in a tuple as `{:ok, value}`.

  ### Nested transactions

  If `c:transaction/2` is called inside another transaction, the function
  is simply executed, without wrapping the new transaction call in any
  way. If there is an error in the inner transaction and the error is
  rescued, or the inner transaction is rolled back, the whole outer
  transaction is aborted, guaranteeing nothing will be committed.

  Below is an example of how rollbacks work with nested transactions:

      {:error, :rollback} =
        MyRepo.transaction(fn ->
          {:error, :posting_not_allowed} =
            MyRepo.transaction(fn ->
              # This function call causes the following to happen:
              #
              #   * the transaction is rolled back in the database,
              #   * code execution is stopped within the current function,
              #   * and the value, passed to `rollback/1` is returned from
              #     `MyRepo.transaction/1` as the second element in the error
              #     tuple.
              #
              MyRepo.rollback(:posting_not_allowed)

              # `rollback/1` stops execution, so code here won't be run
            end)

          # The transaction here is now aborted and any further
          # operation will raise an exception.
        end)

  See the "Aborted transactions" section for more examples of aborted
  transactions and how to handle them.

  In practice, managing nested transactions can become complex quickly.
  For this reason, Ecto provides `Ecto.Multi` for composing transactions.

  ## Use with Ecto.Multi

  `c:transaction/2` also accepts the `Ecto.Multi` struct as first argument.
  `Ecto.Multi` allows you to compose transactions operations, step by step,
  and manage what happens in case of success or failure.

  When an `Ecto.Multi` is given to this function, a transaction will be started,
  all operations applied and in case of success committed returning `{:ok, changes}`:

      # With Ecto.Multi
      Ecto.Multi.new()
      |> Ecto.Multi.insert(:post, %Post{})
      |> MyRepo.transaction

  In case of any errors the transaction will be rolled back and
  `{:error, failed_operation, failed_value, changes_so_far}` will be returned.

  Explore the `Ecto.Multi` documentation to learn more and find detailed examples.

  ## Aborted transactions

  When an operation inside a transaction fails, the transaction is aborted in the database.
  For instance, if you attempt an insert that violates a unique constraint, the insert fails
  and the transaction is aborted. In such cases, any further operation inside the transaction
  will raise exceptions.

  Take the following transaction as an example:

      Repo.transaction(fn repo ->
        case repo.insert(changeset) do
          {:ok, post} ->
            repo.insert(%Status{value: "success"})

          {:error, changeset} ->
            repo.insert(%Status{value: "failure"})
        end
      end)

  If the changeset is valid, but the insert operation fails due to a database constraint,
  the subsequent `repo.insert(%Failure{})` operation will raise an exception because the
  database has already aborted the transaction and thus making the operation invalid.
  In Postgres, the exception would look like this:

      ** (Postgrex.Error) ERROR 25P02 (in_failed_sql_transaction) current transaction is aborted, commands ignored until end of transaction block

  If the changeset is invalid before it reaches the database due to a validation error,
  no statement is sent to the database, an `:error` tuple is returned, and `repo.insert(%Failure{})`
  operation will execute as usual.

  We have two options to deal with such scenarios:

  If don't want to change the semantics of your code,  you can also use the savepoints
  feature by passing the `:mode` option like this: `repo.insert(changeset, mode: :savepoint)`.
  In case of an exception, the transaction will rollback to the savepoint and prevent
  the transaction from failing.

  Another alternative is to handle this operation outside of the transaction.
  For example, you can choose to perform an explicit `repo.rollback` call in the
  `{:error, changeset}` clause and then perform the `repo.insert(%Failure{})` outside
  of the transaction. You might also consider using `Ecto.Multi`, as they automatically
  rollback whenever an operation fails.

  ## Working with processes

  The transaction is per process. A separate process started inside a
  transaction won't be part of the same transaction and will use a separate
  connection altogether.

  When using the `Ecto.Adapters.SQL.Sandbox` in tests, while it may be
  possible to share the connection between processes, the parent process
  will typically hold the connection until the transaction completes. This
  may lead to a deadlock if the child process attempts to use the same connection.
  See the docs for
  [`Ecto.Adapters.SQL.Sandbox`](https://hexdocs.pm/ecto_sql/Ecto.Adapters.SQL.Sandbox.html)
  for more information.

  ## Options

  See the ["Shared options"](#module-shared-options) section at the module
  documentation for more options.
  """
  @doc group: "Transaction API"
  @callback transaction(
              id :: String.t(),
              fun_or_multi :: fun | Ecto.Multi.t(),
              opts :: Keyword.t()
            ) ::
              {:ok, any}
              | {:error, any}
              | {:error, Ecto.Multi.name(), any, %{Ecto.Multi.name() => any}}

  @doc """
  Returns true if the current process is inside a transaction.

  If you are using the `Ecto.Adapters.SQL.Sandbox` in tests, note that even
  though each test is inside a transaction, `in_transaction?/0` will only
  return true inside transactions explicitly created with `transaction/2`. This
  is done so the test environment mimics dev and prod.

  ## Examples

      MyRepo.in_transaction?
      #=> false

      MyRepo.transaction(fn ->
        MyRepo.in_transaction? #=> true
      end)

  """
  @doc group: "Transaction API"
  @callback in_transaction?(id :: String.t()) :: boolean

  @doc """
  Rolls back the current transaction.

  The transaction will return the value given as `{:error, value}`.

  Note that calling `rollback` causes the code in the transaction to stop executing.
  """
  @doc group: "Transaction API"
  @callback rollback(
              id :: String.t(),
              value :: any
            ) :: no_return
end
