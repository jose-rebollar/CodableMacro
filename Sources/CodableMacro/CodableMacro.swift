// The Swift Programming Language
// https://docs.swift.org/swift-book

/// A macro that produces both a value and a string containing the
/// source code that generated the value. For example,
///
///     #stringify(x + y)
///
/// produces a tuple `(x + y, "x + y")`.
//@freestanding(expression)
//public macro stringify<T>(_ value: T) -> (T, String) = #externalMacro(module: "CodableMacroMacros", type: "StringifyMacro")
//@attached(member, names: named(EGKey), named(EGExcluded))
//public macro EGCodable() = #externalMacro(module: "CodableMacroMacros", type: "EGCodable")
@attached(extension, conformances: Codable, names: named(EGKey), named(EGExcluded), named(CodingKeys))
public macro EGCodable() = #externalMacro(module: "CodableMacroMacros", type: "EGCodable")

@attached(peer)
public macro EGKey(name: String) = #externalMacro(module: "CodableMacroMacros", type: "EGKey")

@attached(peer)
public macro EGExcluded() = #externalMacro(module: "CodableMacroMacros", type: "EGExcluded")

public protocol NewTypeProtocol: RawRepresentable {
  init(_ rawValue: RawValue)
}

extension NewTypeProtocol {
  public init(rawValue: RawValue) { self.init(rawValue) }
}

extension NewTypeProtocol where Self: Encodable, RawValue: Encodable {
  public func encode(to encoder: Encoder) throws {
    var container = encoder.singleValueContainer()
    try container.encode(rawValue)
  }
}

extension NewTypeProtocol where Self: Decodable, RawValue: Decodable {
  public init(from decoder: Decoder) throws {
    let container = try decoder.singleValueContainer()
    self.init(try container.decode(RawValue.self))
  }
}
