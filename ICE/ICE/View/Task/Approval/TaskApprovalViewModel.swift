//
//  TaskApprovalViewModel.swift
//  ICE
//
//  Created by 佐藤友貴 on 2024/02/05.
//


import SwiftUI
import Amplify
import Combine

final class TaskApprovalViewModel: ViewModelBase {
    // MARK: Properties
    @Published var comment: String = ""
    @Published var selectedImage: String = ""
    @Published var image: UIImage = UIImage()
    @Published var images: [UIImage] = []
    let keys = TaskReports.keys
    
    // MARK: Flags
    @Published var showImage: Bool = false
    
    // MARK: Instances
    @Published var task: Tasks
    @Published var reportsWithUsers: [ReportWithUserInfo] = []
    @Published var selectedReport: TaskReports?
    @Published var approvedAlertProp: PopupAlertProperties = .init(title: "承認完了！", text: "ポイントがユーザーに付与されました。")
    @Published var rejectedAlertProp: PopupAlertProperties = .init(title: "却下しました", text: "レポートを却下しました。次の報告を待ちましょう。")
    
    // MARK: Validations
    
    // MARK: initializer
    init(task: Tasks)
    {
        self.task = task
    }
    @MainActor
    func loadData() async {
        asyncOperation({ [self] in
            let reportPredicate = keys.taskID.eq(task.id)
            let reportList = try await apiHandler.list(TaskReports.self, where: reportPredicate, keyName: "\(task.id)-reports")
            if !reportList.isEmpty {
                var userIDs: [String] = []
                userIDs = reportList.map{ $0.reportUserID }
                let userPredicate = self.apiService.orPredicateGroupByID(ids: userIDs, model: User.keys.userID)
                if let predicate = userPredicate {
                    let users = try await apiHandler.list(User.self, where: predicate, keyName: "\(task.id)-reports-users")
                    for report in reportList {
                        reportsWithUsers.append(ReportWithUserInfo(report: report, user: users.first(where: { $0.userID == report.reportUserID })))
                    }
                }
            }
        })
    }
    @MainActor
    func reportApprove() async {
        asyncOperation({ [self] in
            if let selectedReport = selectedReport  {
                try await updateGroupPointHistory(selectedReport: selectedReport)
                try await updateTaskReport(selectedReport: selectedReport)
                
            }
            approvedAlertProp.isPresented = true
        })
    }
    
    func updateGroupPointHistory(selectedReport: TaskReports) async throws {
        var pointHistoryModel: GroupPointsHistory
        let pointHistoryPredicate = GroupPointsHistory.keys.userID.eq(selectedReport.reportUserID)
        var pointHistory = try await apiHandler.list(GroupPointsHistory.self, where: pointHistoryPredicate, keyName: "\(task.id)-\(selectedReport.reportUserID)-point")
        if pointHistory.isEmpty {
            pointHistoryModel = GroupPointsHistory(userID: selectedReport.reportUserID, completedTaskID: [task.id], total: task.point, pending: 0, spent: 0, amount: task.point)
            try await apiHandler.create(pointHistoryModel, keyName: "\(task.id)-\(selectedReport.reportUserID)-point")
        } else {
            pointHistory[0].total = pointHistory[0].total + task.point
            pointHistory[0].amount = pointHistory[0].amount + task.point
            if pointHistory[0].completedTaskID != nil {
                pointHistory[0].completedTaskID?.append(task.id)
            } else {
                pointHistory[0].completedTaskID = [task.id]
            }
            let newList = try self.apiHandler.decodeUserDefault(modelType: [GroupPointsHistory].self, key: "\(task.id)-\(selectedReport.reportUserID)-point")?.filter({$0.id != pointHistory[0].id})
            apiHandler.replaceUserDefault(models: newList ?? [], keyName: "\(task.id)-\(selectedReport.reportUserID)-point")
            try await apiHandler.update(pointHistory[0], keyName: "\(task.id)-\(selectedReport.reportUserID)-point")
        }
    }
    
    func updateTaskReport(selectedReport: TaskReports) async throws {
        var selectedReport = selectedReport
        if comment.isNotEmpty {
            selectedReport.approvedComment = comment
        }
        selectedReport.status = .approved
        selectedReport.reportVersion = selectedReport.reportVersion! + 1
        let newList = try self.apiHandler.decodeUserDefault(modelType: [TaskReports].self, key: "\(task.id)-reports")?.filter({$0.id != selectedReport.id})
        apiHandler.replaceUserDefault(models: newList ?? [], keyName: "\(task.id)-reports")
        try await self.apiHandler.update(selectedReport, keyName: "\(task.id)-reports")
    }
    
    @MainActor
    func reportReject() async {
        asyncOperation({ [self] in
            if let selectedReport = selectedReport  {
                var selectedReport = selectedReport
                if comment.isNotEmpty {
                    if selectedReport.rejectedComment != nil {
                        selectedReport.rejectedComment?.append(comment)
                    } else {
                        selectedReport.rejectedComment = [comment]
                    }
                }
                selectedReport.status = .rejected
                let newList = try self.apiHandler.decodeUserDefault(modelType: [TaskReports].self, key: "\(task.id)-reports")?.filter({$0.id != selectedReport.id})
                apiHandler.replaceUserDefault(models: newList ?? [], keyName: "\(task.id)-reports")
                try await self.apiHandler.update(selectedReport, keyName: "\(task.id)-reports")
                
                if let receivingUserIDs = task.receivingUserIDs, receivingUserIDs.contains(selectedReport.reportUserID) {
                    task.hasPendingReport = false
                    let ids = receivingUserIDs.filter({ $0 != selectedReport.reportUserID})
                    task.receivingUserIDs = ids
                    if task.rejectedUserIDs != nil {
                        task.rejectedUserIDs!.append(selectedReport.reportUserID)
                    } else {
                        task.rejectedUserIDs = [selectedReport.reportUserID]
                    }
                    let newList = try self.apiHandler.decodeUserDefault(modelType: [Tasks].self, key: "\(task.groupID)-tasks")?.filter({$0.id != task.id})
                    apiHandler.replaceUserDefault(models: newList ?? [], keyName: "\(task.groupID)-tasks")
                    try await self.apiHandler.update(task, keyName: "\(task.groupID)-tasks")
                }
            }
            rejectedAlertProp.isPresented = true
        })
    }
    func fetchImages(_ urlList: String?...) -> [UIImage] {
        var images: [UIImage?] = []
        for url in urlList {
            if let url = url {
                images.append(UIImage(url: url))
            }
        }
        return images.compactMap{ $0 }
    }
}

struct ReportWithUserInfo {
    var report: TaskReports
    var user: User?
}
