import Foundation
import ArgumentParser

// MARK: - Command line parsing
struct RunOptions: ParsableArguments {
  @Argument(help: "The location of the input file.", transform: URL.init(fileURLWithPath:))
  var inURL: URL
}

let options = RunOptions.parseOrExit()

// MARK: - Actual work done here
struct Stack<T> {
  var stack: [T] = []
  
  mutating func pop() -> T? {
    return stack.popLast()
  }
  
  mutating func push(_ val: T) {
    stack.append(val)
  }
}

extension Character {
  var isOpen: Bool {
    ["(", "[", "{", "<"].contains(self)
  }

  var match: Character {
    switch self {
    case ")": return "("
    case "]": return "["
    case "}": return "{"
    case ">": return "<"
    case "(": return ")"
    case "[": return "]"
    case "{": return "}"
    case "<": return ">"
    default: fatalError("Bad char \(self) in line")
    }
  }
  
  var value: Int {
    switch self {
    case ")": return 3
    case "]": return 57
    case "}": return 1197
    case ">": return 25137
    default: return 0
    }
  }

  var autoCompleteValue: Int {
    switch self {
    case ")": return 1
    case "]": return 2
    case "}": return 3
    case ">": return 4
    default: return 0
    }
  }
}

enum LineType {
  case corrupted(Int)
  case incomplete(Stack<Character>)
  case ok
}

let input = try String(contentsOf: options.inURL, encoding: .utf8).trimmingCharacters(in: .whitespacesAndNewlines)
let lines = input.split(separator: "\n", omittingEmptySubsequences: true)

func parse(_ line: Substring) -> LineType {
  var stack = Stack<Character>()
  
  for char in line {
    if char.isOpen {
      stack.push(char)
    } else {
      guard let top = stack.pop() else { return .ok }
      if top != char.match {
        return .corrupted(char.value)
      }
    }
  }
  return .incomplete(stack)
}

let parsed = lines.map(parse)



// MARK: - Part 1
let scores: [Int] = parsed.compactMap {
  switch $0 {
  case .corrupted(let score): return score
  default: return nil
  }
}

print("*  Total score of corrupted lines: \(scores.reduce(0, +))")

// MARK: - Part 2
func autocompleteScore(_ line: Stack<Character>) -> Int {
  line.stack.reversed().reduce(0) { score, char in
    score * 5 + char.match.autoCompleteValue
  }
}

let incompletes: [Stack<Character>] = parsed.compactMap {
  switch $0 {
  case .incomplete(let remaining): return remaining
  default: return nil
  }
}

let autoScores = incompletes.map(autocompleteScore).sorted()

print("** Median score of the incompletes is: \(autoScores[autoScores.count / 2])")
