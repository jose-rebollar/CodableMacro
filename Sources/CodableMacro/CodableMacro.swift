// The Swift Programming Language
// https://docs.swift.org/swift-book

@attached(extension, conformances: Codable, names: named(EGKey), named(EGExcluded), named(CodingKeys))
public macro EGCodable() = #externalMacro(module: "CodableMacroMacros", type: "EGCodableMacro")

@attached(peer)
public macro EGKey(name: String) = #externalMacro(module: "CodableMacroMacros", type: "EGKeyMacro")

@attached(peer)
public macro EGExcluded() = #externalMacro(module: "CodableMacroMacros", type: "EGExcludedMacro")

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
