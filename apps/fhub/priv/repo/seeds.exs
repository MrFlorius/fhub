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
{:ok, functions} = Resources.create_resource(%{name: "functions", parent_id: root.id})
{:ok, apps} = Resources.create_resource(%{name: "apps", parent_id: root.id})

# permissions
alias Fhub.AccessControl

{:ok, root_permission} =
  AccessControl.create_permission(%{
    can: [AccessControl.Permission.access_any()],
    resource_id: root.id
  })

{:ok, user_permission} =
  AccessControl.create_permission(%{
    can: [:read],
    resource_id: root.id
  })

{:ok, _} = AccessControl.add_actors(root_permission, [root])

# accounts
alias Fhub.Accounts

{:ok, user} =
  Accounts.create_user(
    %{
      resource: %{parent_id: accounts.id},
      name: "florius",
      email: "vadim.tsvetkov80@gmail.com"
    },
    root
  )

{:ok, _} = AccessControl.add_actors(user_permission, [user])
