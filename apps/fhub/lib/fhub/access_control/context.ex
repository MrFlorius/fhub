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

      if unquote(n) != nil do
        def unquote(:"create_#{s}")(actor) do
          unquote(:"create_#{s}")(%{}, actor, Fhub.Resources.get_resource_by(%{name: unquote(n)}))
        end

        def unquote(:"create_#{s}")(attrs, actor) do
          unquote(:"create_#{s}")(
            attrs,
            actor,
            Fhub.Resources.get_resource_by(%{name: unquote(n)})
          )
        end
      end

      def unquote(:"create_#{s}")(attrs, actor, parent) do
        Fhub.AccessControl.Transactions.operation(
          fn repo, _ ->
            struct(unquote(m))
            |> unquote(:"change_#{s}_create")(attrs)
            |> fn c ->
              Ecto.Changeset.put_assoc(c, unquote(r), unquote(:"build_resource_for_#{s}")(parent, actor, c))
            end.()
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
            |> unquote(:"change_#{s}_update")(attrs)
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

      def unquote(:"change_#{s}")(s, attrs \\ %{}) do
        unquote(m).changeset(s, attrs)
      end

      def unquote(:"change_#{s}_create")(s, attrs \\ %{}) do
        unquote(:"change_#{s}")(s, attrs)
      end

      def unquote(:"change_#{s}_update")(s, attrs \\ %{}) do
        unquote(:"change_#{s}")(s, attrs)
      end

      # seems a bit clunky
      def unquote(:"build_resource_for_#{s}")(resource, _actor, _changeset) do
        r = Fhub.Resources.ResourceProtocol.resource(resource)
        %Fhub.Resources.Resource{parent_id: r.id}
      end

      if unquote(n) != nil do
        defoverridable [
          {unquote(:"list_#{p}"), 1},
          {unquote(:"get_#{s}"), 2},
          {unquote(:"get_#{s}!"), 2},
          {unquote(:"create_#{s}"), 1},
          {unquote(:"create_#{s}"), 2},
          {unquote(:"create_#{s}"), 3},
          {unquote(:"update_#{s}"), 3},
          {unquote(:"delete_#{s}"), 2},
          {unquote(:"change_#{s}"), 1},
          {unquote(:"change_#{s}"), 2},
          {unquote(:"change_#{s}_create"), 1},
          {unquote(:"change_#{s}_create"), 2},
          {unquote(:"change_#{s}_update"), 1},
          {unquote(:"change_#{s}_update"), 2},
          {unquote(:"build_resource_for_#{s}"), 3}
        ]
      else
        defoverridable [
          {unquote(:"list_#{p}"), 1},
          {unquote(:"get_#{s}"), 2},
          {unquote(:"get_#{s}!"), 2},
          {unquote(:"create_#{s}"), 3},
          {unquote(:"update_#{s}"), 3},
          {unquote(:"delete_#{s}"), 2},
          {unquote(:"change_#{s}"), 1},
          {unquote(:"change_#{s}"), 2},
          {unquote(:"change_#{s}_create"), 1},
          {unquote(:"change_#{s}_create"), 2},
          {unquote(:"change_#{s}_update"), 1},
          {unquote(:"change_#{s}_update"), 2},
          {unquote(:"build_resource_for_#{s}"), 3}
        ]
      end
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
