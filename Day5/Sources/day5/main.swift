import ArgumentParser
import Foundation

// MARK: - Command line parsing
struct RunOptions: ParsableArguments {
  @Argument(help: "The location of the input file.", transform: URL.init(fileURLWithPath:))
  var inURL: URL
}

let options = RunOptions.parseOrExit()

// MARK: - Actual work done here
let input = try String(contentsOf: options.inURL, encoding: .utf8).trimmingCharacters(in: .whitespacesAndNewlines)

struct Point: Hashable, CustomStringConvertible {
  var x: Int
  var y: Int
  
  var description: String {
    "(x: \(x), y: \(y))"
  }
}

struct Line: Hashable, CustomStringConvertible {
  var start: Point
  var end: Point
  
  var isVertical: Bool { start.x == end.x }
  var isHorizontal: Bool { start.y == end.y }
  var isSimple: Bool { self.isVertical || self.isHorizontal }

  var description: String {
    "\(start) ~> \(end)"
  }
  
  var generateLine: [Point] {
    if self.isVertical {
      return (min(start.y, end.y)...max(start.y, end.y)).map { Point(x: start.x, y:  $0) }
    } else if self.isHorizontal {
      return (min(start.x, end.x)...max(start.x, end.x)).map { Point(x: $0, y: start.y) }
    } else {
      let steps = abs(start.x - end.x)
      let deltaY = (end.y - start.y) / max(steps, 1)
      let deltaX = (end.x - start.x) / max(steps, 1)
      return (0...steps).map { Point(x: start.x + ($0 * deltaX), y: start.y + ($0 * deltaY)) }
    }
  }
}

let lines: [Line] = input.split(separator: "\n")
  .map { line in
    let endpoints = line.components(separatedBy: " -> ").map { (point) -> Point in
      let coords = point.split(separator: ",").map { Int($0)! }
      return Point(x: coords[0], y: coords[1])
    }
    return Line(start: endpoints[0], end: endpoints[1])
  }


// MARK: - Part 1

var points: [Point: Int] = [:]
for point in lines.filter(\.isSimple).flatMap(\.generateLine) {
  points[point, default: 0] += 1
}

let dangerPoints = points.filter { $0.value > 1 }
print("* There are \(dangerPoints.count) dangerPoints:")
//for dp in dangerPoints { print(dp) }

// MARK: - Part 2

var allPoints: [Point: Int] = [:]
for point in lines.flatMap(\.generateLine) {
  allPoints[point, default: 0] += 1
}

let allDangerPoints = allPoints.filter { $0.value > 1 }
print("** There are \(allDangerPoints.count) total dangerPoints:")
//for dp in dangerPoints { print(dp) }
