import gleam/int
import gleam/io
import gleam/list
import gleam/result
import gleam/string
import in

fn part1(input) {
  let assert [head, ..rest] = input

  let #(count, _) =
    rest
    |> list.fold(#(0, head), fn(acc, values) {
      let #(count, beams) = acc
      let #(split_count, new_beams) =
        beams
        |> list.fold(#(0, []), fn(acc, v) {
          let #(count, acc) = acc
          case values |> list.contains(v) {
            True -> #(count + 1, [v + 1, v - 1, ..acc])
            False -> #(count, [v, ..acc])
          }
        })
      #(count + split_count, new_beams |> list.unique())
    })

  io.println(int.to_string(count))
}

fn part2(input: List(List(Int)), width: Int) {
  let assert [head, ..rest] = input

  // list that is the width of the beams
  // counting the number of beams that are passing through any particular index
  // will sum up the list at the end
  let starting_beam =
    list.repeat(0, width)
    |> list.index_map(fn(v, idx) {
      case head |> list.contains(idx) {
        True -> v + 1
        False -> v
      }
    })

  let beams =
    rest
    |> list.fold(starting_beam, fn(acc, values) {
      acc
      |> list.index_fold(list.repeat(0, width), fn(acc, count, idx) { 
        let to_update = case values |> list.contains(idx) {
          True -> [idx - 1, idx + 1]
          False -> [idx]
        }
        acc |> list.index_map(fn(stored_count, idx) {
          case to_update |> list.contains(idx) {
            True -> stored_count + count
            False -> stored_count
          }
        })
        })
    })

  io.println(int.to_string(list.fold(beams, 0, fn(acc, v) { acc + v } )))
}

pub fn main() -> Nil {
  let assert Ok(content) = in.read_chars(40_000_000_000)
  let lines = content |> string.split("\n")
  let width = lines |> list.first() |> result.unwrap("") |> string.length()

  let idxs =
    lines
    |> list.map(fn(v) {
      v
      |> string.to_graphemes()
      |> list.index_fold([], fn(acc, v, idx) {
        case v {
          "S" | "^" -> [idx, ..acc]
          _ -> acc
        }
      })
    })
    |> list.filter(fn(v) { !list.is_empty(v) })

  part1(idxs)
  part2(idxs, width)

  Nil
}
