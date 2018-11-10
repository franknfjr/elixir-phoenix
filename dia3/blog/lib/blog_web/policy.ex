defmodule BlogWeb.Policies do
    use PolicyWonk.Policy         # set up support for policies
    use PolicyWonk.Enforce        # turn this module into an enforcement plug
  
    def policy( assigns, :current_user ) do
      case assigns[:current_user] do
        %Blog.Coherence.User{} ->
          :ok
        _ ->
          {:error, :current_user}
      end
    end
  
    def policy_error(conn, :current_user) do
      BlogWeb.ErrorHandlers.unauthenticated(conn, "Must be logged in")
    end
  end