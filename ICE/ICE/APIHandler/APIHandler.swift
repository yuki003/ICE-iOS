//
//  APIHandler.swift
//  ICE
//
//  Created by 佐藤友貴 on 2023/10/19.
//

import Foundation
import Amplify

class APIHandler: ObservableObject {
    static let shared = APIHandler()
    let jsonEncoder = JSONEncoder()
    let jsonDecoder = JSONDecoder()
    var userDefaultKeys: [String] = []
    let defaults = UserDefaults.standard
    func create<ModelType: Model>(_ model: ModelType, keyName: String = "") async throws {
        do {
            var keyName = keyName
            if keyName.isEmpty {
                keyName = model.modelName
            }
            let result = try await Amplify.API.mutate(request: .create(model))
            switch result {
            case .success(let data):
                print("Successfully created the model: \(data)")
                appendUserDefault(model: model, keyName: keyName)
            case .failure(let graphQLError):
                print("Failed to create graphql \(graphQLError)")
                throw APIError.createFailed
            }
        } catch let error as APIError {
            print("Failed to create a model: ", error)
            throw error
        } catch {
            print("Unexpected error: \(error)")
            throw error
        }
    }

    
    func get<ModelType: Model>(_ modelType: ModelType.Type, byId id: String, keyName: String = "") async throws -> ModelType {
        do {
            var keyName = keyName
            if keyName.isEmpty {
                keyName = modelType.modelName
            }
            let result = try await Amplify.API.query(request: .get(modelType, byId: id))

            switch result {
            case .success(let model):
                guard let model = model else {
                    print("Could not find model")
                    throw APIError.notFound
                }
                print("Successfully retrieved model: \(model)")
                guard let data = try? jsonEncoder.encode(model) else {
                    return model
                }
                defaults.set(data, forKey: "\(keyName)")
                if !userDefaultKeys.contains(where: { value in
                    value == keyName
                }) {
                    userDefaultKeys.append(keyName)
                }
                return model
            case .failure(let error):
                print("Got failed result with \(error.errorDescription)")
                throw error
            }
        } catch let error as APIError {
            print("Failed to query model: ", error)
            throw error
        } catch {
            print("Unexpected error: \(error)")
            throw error
        }
    }

    func list<M: Model>(_ modelType: M.Type, where predicate: QueryPredicate? = nil, keyName: String = "") async throws -> [M] {
        do {
            var keyName = keyName
            if keyName.isEmpty {
                keyName = modelType.modelName
            }
            let request = GraphQLRequest<M>.list(modelType, where: predicate, limit: 1000)
            let result = try await Amplify.API.query(request: request)
            switch result {
            case .success(let models):
                print("Successfully retrieved list of \(modelType): \(models)")
                setUserDefault(models: models.elements, keyName: keyName)
                return models.elements
            case .failure(let error):
                print("Got failed result with \(error.errorDescription)")
                throw error
            }
        } catch {
            print("Unexpected error: \(error)")
            throw error
        }
    }
    
    func update<ModelType: Model>(_ model: ModelType, keyName: String = "") async throws {
        do {
            var keyName = keyName
            if keyName.isEmpty {
                keyName = model.modelName
            }
            let result = try await Amplify.API.mutate(request: .update(model))
            switch result {
            case .success(let updatedModel):
                print("Successfully updated model: \(updatedModel)")
                appendUserDefault(model: updatedModel, keyName: keyName)
            case .failure(let error):
                print("Got failed result with \(error.errorDescription)")
                throw APIError.updateFailed
            }
        } catch let error as APIError {
            print("Failed to update model: ", error)
            throw error
        } catch {
            print("Unexpected error: \(error)")
            throw error
        }
    }
    
    func delete<ModelType: Model>(_ model: ModelType) async throws {
        do {
            let result = try await Amplify.API.mutate(request: .delete(model))
            switch result {
            case .success:
                print("Successfully delete")
            case .failure(let error):
                print("Got failed result with \(error.errorDescription)")
                throw APIError.deleteFailed
            }
        } catch let error as APIError {
            print("Failed to update model: ", error)
            throw error
        } catch {
            print("Unexpected error: \(error)")
            throw error
        }
    }
    
    func appendUserDefault<ModelType: Model>(model: ModelType, keyName: String) {
        if let savedData = defaults.data(forKey: keyName),
           var structArray = try? jsonDecoder.decode([ModelType].self, from: savedData) {
            // 新しいデータを配列に追加
            structArray.append(model)
            
            // 配列を再度エンコードし、UserDefaultsに保存
            if let encodedData = try? jsonEncoder.encode(structArray) {
                defaults.set(encodedData, forKey: keyName)
            } else {
                print("Failed to encode data")
            }
        } else {
            // 既存のデータがない場合は新しい配列を作成
            let newArray = [model]
            if let encodedData = try? jsonEncoder.encode(newArray) {
                defaults.set(encodedData, forKey: keyName)
            } else {
                print("Failed to encode data")
            }
        }
        if !userDefaultKeys.contains(where: { value in
            value == keyName
        }) {
            userDefaultKeys.append(keyName)
        }
    }
    
    func replaceUserDefault<M: Model>(models: [M], keyName: String) {
        if let savedData = defaults.data(forKey: keyName) {
            UserDefaults.standard.removeObject(forKey: keyName)
            
            guard let data = try? jsonEncoder.encode(models) else {
                return
            }
            defaults.set(data, forKey: "\(keyName)")
        }
    }
    
    func setUserDefault<M: Model>(models: [M], keyName: String) {
        guard let data = try? jsonEncoder.encode(models) else {
            return
        }
        defaults.set(data, forKey: "\(keyName)")
        if !userDefaultKeys.contains(where: { value in
            value == keyName
        }) {
            userDefaultKeys.append(keyName)
        }
    }
    
    func decodeUserDefault<T: Decodable>(modelType: T.Type, key: String) throws -> T? {
        let keyList = userDefaultKeys.filter({ $0.elementsEqual(key)})
        if keyList.count > 1 {
            throw DeveloperError.userDefaultKeyDuplicated
        }
        guard !keyList.isEmpty else { return nil }
        guard let data = UserDefaults.standard.data(forKey: keyList[0]),
              let dataModel = try? jsonDecoder.decode(modelType, from: data) else {
            return nil
        }
        return dataModel
    }
    
    func isRunFetch(userDefaultKey: String) -> Bool {
        print(userDefaultKeys)
        return !userDefaultKeys.contains(userDefaultKey)
    }
}
