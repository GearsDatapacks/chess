import carpenter/table
import engine/router
import gleam/erlang/process
import mist
import wisp
import wisp/wisp_mist

pub fn main() {
  wisp.configure_logger()

  let secret_key_base = wisp.random_string(64)

  let assert Ok(table) =
    table.build("board")
    |> table.privacy(table.Public)
    |> table.write_concurrency(table.AutoWriteConcurrency)
    |> table.read_concurrency(True)
    |> table.decentralized_counters(True)
    |> table.compression(False)
    |> table.set

  let assert Ok(_) =
    wisp_mist.handler(router.handle_request(_, table), secret_key_base)
    |> mist.new
    |> mist.port(8000)
    |> mist.start_http

  process.sleep_forever()
}
