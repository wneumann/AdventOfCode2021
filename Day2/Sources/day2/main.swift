import ArgumentParser
import Foundation

// MARK: - Command line parsing
struct RunOptions: ParsableArguments {
  @Argument(help: "The location of the input file.", transform: URL.init(fileURLWithPath:))
  var inURL: URL
}

let options = RunOptions.parseOrExit()

// MARK: - Actual work done here
let input = try String(contentsOf: options.inURL, encoding: .utf8)

print(input)

enum Control: String {
  case forward, up, down
}

var program: [(Control, Int)] = input.components(separatedBy: .newlines).compactMap { cmd in
  let split = cmd.split(separator: " ")
  guard split.count > 1 else { return nil }
  guard let dir = Control(rawValue: String(split[0])), let amount = Int(split[1]) else { return nil }
  return (dir, amount)
}

let position = program.reduce(into: (h: 0, d: 0)) { (currentPosition, instruction) in
  switch instruction.0 {
  case .forward: currentPosition = (h: currentPosition.h + instruction.1, d: currentPosition.d)
  case .down: currentPosition = (h: currentPosition.h, d: currentPosition.d + instruction.1)
  case .up: currentPosition = (h: currentPosition.h, d: currentPosition.d - instruction.1)
  }
}

print("*  The final position is \(position.h * position.d)")

let aimPos = program.reduce(into: (a: 0, h: 0, d: 0)) { (currentPosition, instruction) in
  switch instruction.0 {
  case .forward: currentPosition = (a: currentPosition.a,  h: currentPosition.h + instruction.1, d: currentPosition.d + currentPosition.a * instruction.1)
  case .down: currentPosition = (a: currentPosition.a + instruction.1, h: currentPosition.h, d: currentPosition.d)
  case .up: currentPosition = (a: currentPosition.a - instruction.1, h: currentPosition.h, d: currentPosition.d )
  }
}

print("** The final aim position is \(aimPos.h * aimPos.d)")
