//
//  APIHandler.swift
//  ICE
//
//  Created by 佐藤友貴 on 2023/10/19.
//

import Foundation
import Amplify

class APIHandler: ObservableObject {
    func create<ModelType: Model>(_ model: ModelType) async throws {
        do {
            Amplify.API
            let result = try await Amplify.API.mutate(request: .create(model))
            switch result {
            case .success(let data):
                print("Successfully created the model: \(data)")
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

    
    func get<ModelType: Model>(_ modelType: ModelType.Type, byId id: String) async throws -> Model {
        do {
            let result = try await Amplify.API.query(request: .get(modelType, byId: id))

            switch result {
            case .success(let model):
                guard let model = model else {
                    print("Could not find model")
                    throw APIError.notFound
                }
                print("Successfully retrieved model: \(model)")
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

    func list<M: Model>(_ modelType: M.Type, where predicate: QueryPredicate? = nil) async throws -> [M] {
        do {
            let request = GraphQLRequest<M>.list(modelType, where: predicate, limit: 1000)
            let result = try await Amplify.API.query(request: request)
            switch result {
            case .success(let models):
                print("Successfully retrieved list of \(modelType): \(models)")
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
    
    func update<ModelType: Model>(_ model: ModelType) async throws {
        do {
            let result = try await Amplify.API.mutate(request: .update(model))
            switch result {
            case .success(let updatedModel):
                print("Successfully updated model: \(updatedModel)")
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
}
