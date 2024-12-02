// swiftlint:disable all
import Amplify
import Foundation

// Contains the set of classes that conforms to the `Model` protocol. 

final public class AmplifyModels: AmplifyModelRegistration {
  public let version: String = "cbcc73cd56771f58ffa000d6d2d3ede5"
  
  public func registerModels(registry: ModelRegistry.Type) {
    ModelRegistry.register(modelType: User.self)
    ModelRegistry.register(modelType: Group.self)
    ModelRegistry.register(modelType: GroupPointsHistory.self)
    ModelRegistry.register(modelType: Tasks.self)
    ModelRegistry.register(modelType: TaskReports.self)
    ModelRegistry.register(modelType: Rewards.self)
  }
}