//
//  ServiceProviderProtocol.swift
//  Infrastructure
//
//  Created by Hélio Mesquita on 14/12/19.
//  Copyright © 2019 Hélio Mesquita. All rights reserved.
//

import Foundation
import PromiseKit

public protocol ServiceProviderProtocol {
    func execute<T: Decodable>(request: RequestProviderProtocol, parser: T.Type) -> Promise<T>
}

extension ServiceProviderProtocol {

    public func execute<T: Decodable>(request: RequestProviderProtocol, parser: T.Type) -> Promise<T> {
        return Promise<T> { seal in
            URLSession.shared.dataTask(with: request.asURLRequest) { (data, response, _) in

                let statusCode = (response as? HTTPURLResponse)?.statusCode ?? 0
                if 200...299 ~= statusCode {
                    let data = data ?? Data()

                    do {
                        let model = try JSONDecoder().decode(T.self, from: data)
                        seal.fulfill(model)
                    } catch {
                        seal.reject(error)
                    }

                } else {
                    seal.reject(self.identify(statusCode: statusCode))
                }
            }.resume()
        }
    }

    fileprivate func identify(statusCode: Int) -> RequestError {
        switch statusCode {
        case 400:
            return .badRequest
        case 401:
            return .unauthorized
        case 404:
            return .notFound
        default:
            return .unknownError
        }
    }

}