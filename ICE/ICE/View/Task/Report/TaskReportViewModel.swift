//
//  TaskReportViewModel.swift
//  ICE
//
//  Created by 佐藤友貴 on 2024/01/31.
//

import SwiftUI
import Amplify
import Combine

final class TaskReportViewModel: ViewModelBase {
    // MARK: Properties
    @Published var report: String = ""
    @Published var image: UIImage = UIImage()
    @Published var images: [UIImage] = []
    let keys = TaskReports.keys
    
    // MARK: Flags
    @Published var editReport: Bool = false
    
    // MARK: Instances
    @Published var task: Tasks
    @Published var taskReports: TaskReports?
    @Published var submitAlertProp: PopupAlertProperties = .init(text: "この内容で報告しますか？")
    @Published var deleteAlertProp: PopupAlertProperties = .init(title: "レポートを取り消しますか？", text: "取り消したタスクは再チャレンジできません。")
    @Published var completedSubmitAlertProp: PopupAlertProperties = .init(title: "報告完了!!", text: "ホストの承認を受けるとポイントゲット！")

    
    var alreadyReported: Bool {
        taskReports != nil
    }
    var reportPics: [String?] {
        [taskReports?.picture1,taskReports?.picture2,taskReports?.picture3].filter({ $0 != nil })
    }
    
    // MARK: Validations
    
    // MARK: initializer
    init(task: Tasks)
    {
        self.task = task
    }
    
    @MainActor
    func loadData() async {
        asyncOperation({ [self] in
//            if apiHandler.isRunFetch(userDefaultKey: "\(task.id)-report") || reload {
                let reportPredicate = keys.taskID.eq(task.id) && keys.reportUserID.eq(userID)
                let reportList = try await apiHandler.list(TaskReports.self, where: reportPredicate, keyName: "\(task.id)-report")
                if !reportList.isEmpty {
                    taskReports = reportList[0]
//                    let reportIndex = reportList[0].reportVersion! - 1
//                    report = reportList[0].reports![reportIndex] ?? ""
//                    images = fetchImages(taskReports?.picture1,taskReports?.picture2,taskReports?.picture3)
                }
//            } else {
//                let report = try self.apiHandler.decodeUserDefault(modelType: [TaskReports].self, key: "\(task.id)-report")
//                if let report = report {
//                    taskReports = report[0]
////                    let reportIndex = report[0].reportVersion! - 1
////                    self.report = report[0].reports![reportIndex] ?? ""
////                    images = fetchImages(taskReports?.picture1,taskReports?.picture2,taskReports?.picture3)
//                }
//            }
            
            if let taskReports = taskReports {
                if taskReports.status == ReportStatus.pending {
                    let reportIndex = taskReports.reportVersion! - 1
                    report = taskReports.reports![reportIndex] ?? ""
                }
                images = fetchImages(taskReports.picture1,taskReports.picture2,taskReports.picture3)
            }
        })
    }
    @MainActor
    func repotTask() async throws {
        asyncOperation({ [self] in
            submitAlertProp.isPresented = false
            var baseKey = task.id
            var key: String = ""
            var model = TaskReports(taskID: task.id, reportUserID: userID, status: ReportStatus.pending, reportVersion: (taskReports?.reportVersion ?? 0) + 1)
            if let taskReports = taskReports {
                if let pictureKey = taskReports.pictureKey {
                    baseKey = pictureKey
                } else {
                    // throw
                }
            } else {
                baseKey = baseKey + model.id
            }
            
            if images.count > 0, images[0].isNotEmpty() {
                let image  = images[0]
                key = baseKey + "pic1"
                let url = try await storage.uploadData(image, key: key)
                if alreadyReported {
                    taskReports?.pictureKey = baseKey
                    taskReports?.picture1 = url
                } else {
                    model.pictureKey = baseKey
                    model.picture1 = url
                }
            }
            
            if images.count > 1, images[1].isNotEmpty() {
                let image  = images[1]
                key = baseKey + "pic2"
                let url = try await storage.uploadData(image, key: key)
                if alreadyReported {
                    taskReports?.picture2 = url
                } else {
                    model.picture2 = url
                }
            }
            
            if images.count > 2, images[2].isNotEmpty() {
                let image  = images[2]
                key = baseKey + "pic3"
                let url = try await storage.uploadData(image, key: key)
                if alreadyReported {
                    taskReports?.picture3 = url
                } else {
                    model.picture3 = url
                }
            }
            
            if let taskReports = taskReports {
                var taskReports = taskReports
                if taskReports.status == ReportStatus.pending {
                    taskReports.reports?.removeLast()
                }
                taskReports.reports?.append(report)
                if taskReports.status == ReportStatus.rejected {
                    taskReports.status = .pending
                    let ids = task.rejectedUserIDs?.filter({ $0 != taskReports.reportUserID})
                    task.rejectedUserIDs = ids
                    task.receivingUserIDs?.append(taskReports.reportUserID)
                }
                if taskReports.rejectedComment?.count == taskReports.reportVersion {
                    taskReports.reportVersion = taskReports.reportVersion! + 1
                }
                if images.count < 3 {
                    taskReports.picture3 = nil
                    if images.count < 2 {
                        taskReports.picture2 = nil
                        if images.count < 1 {
                            taskReports.picture1 = nil
                        }
                    }
                }
                if reportPics.count > images.count  {
                    for index in 1...reportPics.count {
                        if images.count < index {
                            try await storage.deleteData(key: baseKey + "pic\(index)")
                        }
                    }
                }
                let newTaskList = try self.apiHandler.decodeUserDefault(modelType: [Tasks].self, key: "\(task.groupID)-tasks")?.filter({$0.id != task.id})
                apiHandler.replaceUserDefault(models: newTaskList ?? [], keyName: "\(task.groupID)-tasks")
                try await apiHandler.update(task, keyName: "\(task.groupID)-tasks")
                
                let newList = try self.apiHandler.decodeUserDefault(modelType: [TaskReports].self, key: "\(task.id)-report")?.filter({$0.id != taskReports.id})
                apiHandler.replaceUserDefault(models: newList ?? [], keyName: "\(task.id)-report")
                try await apiHandler.update(taskReports, keyName: "\(task.id)-report")
            } else {
                model.reports = [report]
                try await apiHandler.create(model, keyName: "\(task.id)-report")
            }
            
            completedSubmitAlertProp.isPresented = true
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
//    
//    @MainActor
//    func deleteTask() async throws {
//        asyncOperation({ [self] in
//            deleteAlertProp.isPresented = false
//            var model = TaskReports(taskID: task.id, reportUserID: userID, status: ReportStatus.pending, reportVersion: (taskReports?.reportVersion ?? 0) + 1)
//            
//            if images.count > 0, images[0].isNotEmpty() {
//                let image  = images[0]
//                let key = task.id + model.id + "pic1"
//                let url = try await self.storage.uploadData(image, key: key)
//                model.picture1 = url
//            }
//            if images.count > 1, images[1].isNotEmpty() {
//                let image  = images[1]
//                let key = task.id + model.id + "pic2"
//                let url = try await self.storage.uploadData(image, key: key)
//                model.picture2 = url
//            }
//            
//            if images.count > 2, images[2].isNotEmpty() {
//                let image  = images[2]
//                let key = task.id + model.id + "pic3"
//                let url = try await self.storage.uploadData(image, key: key)
//                model.picture3 = url
//            }
//            
//            if let taskReports = taskReports {
//                model.reports = taskReports.reports
//                model.reports?.append(report)
//                var newList = try self.apiHandler.decodeUserDefault(modelType: [TaskReports].self, key: "\(task.id)-report")?.filter({$0.id != model.id})
//                apiHandler.replaceUserDefault(models: newList ?? [], keyName: "\(task.id)-report")
//                try await apiHandler.update(model, keyName: "\(task.id)-report")
//            } else {
//                model.reports = [report]
//                try await apiHandler.create(model, keyName: "\(task.id)-report")
//            }
//            completedSubmitAlertProp.isPresented = true
//        }, apiErrorHandler: { apiError in
//            self.setErrorMessage(apiError)
//        }, errorHandler: { error in
//            self.setErrorMessage(error)
//        })
//    }
}
