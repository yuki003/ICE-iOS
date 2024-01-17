// swiftlint:disable all
import Amplify
import Foundation

// Contains the set of classes that conforms to the `Model` protocol. 

final public class AmplifyModels: AmplifyModelRegistration {
  public let version: String = "8d18097e35fc4a3aea1b69505196b32a"
  
  public func registerModels(registry: ModelRegistry.Type) {
    ModelRegistry.register(modelType: User.self)
    ModelRegistry.register(modelType: Group.self)
    ModelRegistry.register(modelType: Tasks.self)
    ModelRegistry.register(modelType: Rewards.self)
  }
}