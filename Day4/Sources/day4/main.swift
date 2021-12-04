import ArgumentParser
import Foundation

// MARK: - Command line parsing
struct RunOptions: ParsableArguments {
  @Argument(help: "The location of the input file.", transform: URL.init(fileURLWithPath:))
  var inURL: URL
}

let options = RunOptions.parseOrExit()

// MARK: - Actual work done here

struct Indices: Hashable {
  let r: Int, c: Int
}

struct Card {
  var indices: [Indices: Int] = [:]
  
  init(_ squares: String) {
    for (r,row) in squares.split(separator: "\n", omittingEmptySubsequences: true).enumerated() {
      for (c, val) in row.split(separator: " ", omittingEmptySubsequences: true).enumerated() {
        indices[Indices(r: r, c: c)] = Int(val)!
      }
    }
  }
  
  func row(_ r: Int) -> [Int] {
    (0..<5).map { indices[Indices(r: r, c: $0)]! }
  }

  func col(_ c: Int) -> [Int] {
    (0..<5).map { indices[Indices(r: $0, c: c)]! }
  }
  
  func hasWon(_ called: Set<Int>) -> Bool {
    for i in 0..<5 {
      if (row(i).allSatisfy { called.contains($0) } || col(i).allSatisfy { called.contains($0) }) {
        return true
      }
    }
    return false
  }
  
  func score(_ called: Set<Int>) -> Int {
    indices.values.filter({ !called.contains($0) }).reduce(0, +)
  }
}

let input = try String(contentsOf: options.inURL, encoding: .utf8).trimmingCharacters(in: .whitespacesAndNewlines)
var splits = input.components(separatedBy: "\n\n")

var numbers: ArraySlice<Int> = splits.first!.split(separator: ",").compactMap { Int($0) }[...]
var called: Set<Int> = []

var cards = splits.dropFirst().map(Card.init)

var gameWon = false
var lastWinner: Card?, lastNum: Int?, lastCalled: Set<Int>?

while !cards.isEmpty, let num = numbers.popFirst() {
  called.insert(num)
  if let winner = cards.first(where: { $0.hasWon(called) })  {
    lastWinner = winner
    lastNum = num
    lastCalled = called
    if !gameWon { print("* Sum: \(winner.score(called)), num: \(num), score: \(num * winner.score(called))"); gameWon = true }
    cards = cards.filter { !$0.hasWon(called) }
  }
}

let lastSum = lastWinner!.score(lastCalled!)
print("** Sum: \(lastSum), num: \(lastNum!), score: \(lastNum! * lastSum)")
