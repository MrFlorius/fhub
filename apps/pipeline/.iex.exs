alias Pipeline.Image.CommandServer
{:ok, pid} = CommandServer.start_link()
img = File.read!("/Users/vadimtsvetkov/Documents/Elixir/fhub_umbrella/apps/fhub/test/support/resources/test.gif")
