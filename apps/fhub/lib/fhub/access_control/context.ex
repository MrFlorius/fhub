defmodule Fhub.AccessControl.Context do
  defmacro __using__(opts) do
    [module: m, single: s, plural: p, resource_field: r, resource_parent: n] = parse_opts(opts)

    quote do
      def unquote(:"list_#{p}")(actor) do
        Fhub.AccessControl.Transactions.operation_filter(
          fn repo, _ -> {:ok, repo.all(unquote(m))} end,
          actor,
          :read
        )
      end

      def unquote(:"get_#{s}")(id, actor) do
        Fhub.AccessControl.Transactions.operation(
          fn repo, _ ->
            case repo.get(unquote(m), id) do
              nil -> {:error, :does_not_exisists}
              x -> {:ok, x}
            end
          end,
          actor,
          :read
        )
      end

      def unquote(:"get_#{s}!")(id, actor) do
        case apply(__MODULE__, unquote(:"get_#{s}"), [id, actor]) do
          {:ok, x} -> x
          {:error, _} -> nil
        end
      end

      def unquote(:"create_#{s}")(attrs \\ %{}, actor) do
        Fhub.AccessControl.Transactions.operation(
          fn repo, _ ->
            s = struct(unquote(m))

            s
            |> unquote(:"change_#{s}")(attrs)
            |> Ecto.Changeset.change(%{unquote(r) => unquote(:"build_resource_for_#{s}")(s, actor)})
            |> Ecto.Changeset.cast_assoc(unquote(r), with: &Fhub.Resources.Resource.changeset/2)
            |> repo.insert()
          end,
          actor,
          :create
        )
      end

      def unquote(:"update_#{s}")(s = %unquote(m){}, attrs, actor) do
        Fhub.AccessControl.Transactions.operation(
          fn repo, _ ->
            s
            |> unquote(:"change_#{s}")(attrs)
            |> repo.update()
          end,
          actor,
          :update
        )
      end

      def unquote(:"delete_#{s}")(s = %unquote(m){}, actor) do
        Fhub.AccessControl.Transactions.operation(
          fn repo, _ -> repo.delete(s) end,
          actor,
          :delete
        )
      end

      def unquote(:"change_#{s}")(s = %unquote(m){}, attrs \\ %{}) do
        unquote(m).changeset(s, attrs)
      end

      # seems a bit clunky
      def unquote(:"build_resource_for_#{s}")(s = %unquote(m){}, _actor) do
        r = Fhub.Resources.get_resource_by(%{name: unquote(n)})
        %Fhub.Resources.Resource{parent_id: r.id}
      end

      defoverridable [
        {unquote(:"list_#{p}"),   1},
        {unquote(:"get_#{s}"),    2},
        {unquote(:"get_#{s}!"),   2},
        {unquote(:"create_#{s}"), 1},
        {unquote(:"create_#{s}"), 2},
        {unquote(:"update_#{s}"), 3},
        {unquote(:"delete_#{s}"), 2},
        {unquote(:"change_#{s}"), 1},
        {unquote(:"change_#{s}"), 2},
        {unquote(:"build_resource_for_#{s}"), 2}
      ]
    end
  end

  defp parse_opts(opts) do
    alias = Keyword.fetch!(opts, :for)

    [
      module: alias,
      single: single(opts, alias),
      plural: plural(opts, alias),
      resource_field: Keyword.get(opts, :resource_field, :resource),
      resource_parent: Keyword.get(opts, :resource_parent, nil)
    ]
  end

  defp single(opts, {:__aliases__, _, m}) do
    s =
      m
      |> List.last()
      |> Atom.to_string()
      |> String.downcase()

    Keyword.get(opts, :single, s)
  end

  defp plural(opts, alias) do
    Keyword.get(opts, :plural, "#{single(opts, alias)}s")
  end
end
