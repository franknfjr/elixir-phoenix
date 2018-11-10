# Script for populating the database. You can run it as:
#
#     mix run priv/repo/seeds.exs
#
# Inside the script, you can read and write to any of your
# repositories directly:
#
#     Blog.Repo.insert!(%Blog.SomeSchema{})
#
# We recommend using the bang functions (`insert!`, `update!`
# and so on) as they will fail if something goes wrong.
Blog.Repo.delete_all Blog.Coherence.User

Blog.Coherence.User.changeset(%Blog.Coherence.User{}, %{name: "Gissandro Gama", email: "gissandrogama@gissandro.com", password: "123123", password_confirmation: "123123"})
|> Blog.Repo.insert!
Blog.Coherence.User.changeset(%Blog.Coherence.User{}, %{name: "aasdasd", email: "a@a.com", password: "123123", password_confirmation: "123123"})
|> Blog.Repo.insert!