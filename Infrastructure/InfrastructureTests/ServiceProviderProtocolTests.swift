//
//  InfrastructureTests.swift
//  InfrastructureTests
//
//  Created by Hélio Mesquita on 08/12/19.
//  Copyright © 2019 Hélio Mesquita. All rights reserved.
//

import Quick
import Nimble

@testable import Infrastructure
@testable import PromiseKit

typealias DataCompletion = (Data?, URLResponse?, Error?) -> Void

class ServiceProvider: ServiceProviderProtocol {

    var customURLSession: URLSession

    var urlSession: URLSession {
        return customURLSession
    }

    init(customURLSession: URLSession) {
        self.customURLSession = customURLSession
    }

}

class ServiceProviderProtocolTests: QuickSpec {

    struct BodyParser: RequestDecodable {
        let body: String

        init() {
            body = ""
        }
    }

    struct InvalidParser: RequestDecodable {
        let corpo: String

        init() {
            corpo = ""
        }
    }

    let jsonData = """
        {
          "body": "body123"
        }
    """.data(using: .utf8)!

    var subject: ServiceProviderProtocol!

    override func spec() {
        super.spec()
        PromiseKit.conf.Q.map = nil
        PromiseKit.conf.Q.return = nil

        describe("#execute") {
            context("when successful request") {
                beforeEach {
                    let mockURLSession = MockURLSession(data: self.jsonData, statusCode: 200)
                    self.subject = ServiceProvider(customURLSession: mockURLSession)
                }

                context("with a correct parser") {
                    it("returns body response parsed") {
                        self.subject.execute(request: MockProvider(), parser: BodyParser.self).done { response in
                            expect(response.body).to(equal("body123"))
                        }.catch { _ in
                            XCTFail()
                        }
                    }
                }
                context("with a invalid parser") {
                    it("returns a error invalid parser") {
                        self.subject.execute(request: MockProvider(), parser: InvalidParser.self).done { _ in
                            XCTFail()
                        }.catch { error in
                            expect((error as? RequestError)).to(equal(RequestError.invalidParser))
                        }
                    }
                }
            }

            context("when unsuccessful request") {
                context("with known error") {
                    beforeEach {
                        let mockURLSession = MockURLSession(data: self.jsonData, statusCode: 401)
                        self.subject = ServiceProvider(customURLSession: mockURLSession)
                    }

                    it("returns specific error") {
                        self.subject.execute(request: MockProvider(), parser: BodyParser.self).done { _ in
                            XCTFail()
                        }.catch { error in
                            expect((error as? RequestError)).to(equal(RequestError.unauthorized))
                        }
                    }
                }

                context("with unknown error") {
                    beforeEach {
                        let mockURLSession = MockURLSession(data: self.jsonData, statusCode: 999)
                        self.subject = ServiceProvider(customURLSession: mockURLSession)
                    }

                    it("returns specific error") {
                        self.subject.execute(request: MockProvider(), parser: BodyParser.self).done { _ in
                            XCTFail()
                        }.catch { error in
                            expect((error as? RequestError)).to(equal(RequestError.unknownError))
                        }
                    }
                }

            }
        }
    }

}
