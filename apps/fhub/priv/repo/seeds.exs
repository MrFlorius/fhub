# Script for populating the database. You can run it as:
#
#     mix run priv/repo/seeds.exs
#
# Inside the script, you can read and write to any of your
# repositories directly:
#
#     Fhub.Repo.insert!(%Fhub.SomeSchema{})
#
# We recommend using the bang functions (`insert!`, `update!`
# and so on) as they will fail if something goes wrong.

# resources
alias Fhub.Resources

{:ok, root} = Resources.create_resource(%{name: "root"})
{:ok, accounts} = Resources.create_resource(%{name: "accounts", parent_id: root.id})

# accounts
alias Fhub.Accounts

{:ok, user} =
  Accounts.create_user(%{
    resource: %{parent_id: accounts.id},
    name: "florius",
    email: "vadim.tsvetkov80@gmail.com"
  })

# permissions
alias Fhub.AccessControl

{:ok, root_permission} =
  AccessControl.create_permission(%{
    can: ["create", "read", "update", "delete"],
    resource_id: root.id,
  })

{:ok, root_permission} = AccessControl.add_actors(root_permission, [root])
