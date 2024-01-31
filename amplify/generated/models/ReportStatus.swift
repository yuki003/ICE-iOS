// swiftlint:disable all
import Amplify
import Foundation

public enum ReportStatus: String, EnumPersistable {
  case pending = "PENDING"
  case approved = "APPROVED"
  case rejected = "REJECTED"
}