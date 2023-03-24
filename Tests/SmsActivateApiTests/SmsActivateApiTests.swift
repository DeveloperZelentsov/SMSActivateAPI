
import XCTest
@testable import SmsActivateApi

final class SmsActivateApiTests: XCTestCase {
    private var smsActivateAPI: SmsActivateAPI!
    private var expectation: XCTestExpectation!
    private let apiKey = ""
    
    override func setUp() {
        super.setUp()
        let configuration = URLSessionConfiguration.default
        configuration.protocolClasses = [MockURLProtocol.self]
        let urlSession = URLSession(configuration: configuration)
        smsActivateAPI = SmsActivateAPI(apiKey: apiKey, urlSession: urlSession)
        expectation = expectation(description: "Expectation")
    }
    
    override func tearDown() {
        smsActivateAPI = nil
        super.tearDown()
    }
    
    func testGetBalanceSuccess() async throws {
        let mockResponse = "ACCESS_BALANCE:100"
        let responseData = mockResponse.data(using: .utf8)!

        MockURLProtocol.requestHandler = { request in
            let response = HTTPURLResponse(url: request.url!, statusCode: 200, httpVersion: nil, headerFields: nil)!
            return (response, responseData)
        }

        // Call API
        do {
            let balance = try await smsActivateAPI.getBalance(with: .onlyBalance)
            XCTAssertEqual(balance, "100", "Expected balance to be 100")
            expectation.fulfill()
        } catch {
            XCTFail("Error occurred: \(error)")
            expectation.fulfill()
        }
        
        wait(for: [expectation], timeout: 1.0)
    }
    
    func testGetNumber() async throws {
        let mockResponse = "ACCESS_NUMBER:12345:123456789"
        let responseData = mockResponse.data(using: .utf8)!

        MockURLProtocol.requestHandler = { request in
            let response = HTTPURLResponse(url: request.url!, statusCode: 200, httpVersion: nil, headerFields: nil)!
            return (response, responseData)
        }
        
        // Call API
        let request = GetNumberRequest(service: .a9a)
        Task {
            do {
                let (id, phone) = try await smsActivateAPI.getNumber(request: request)
                XCTAssertEqual(id, 12345, "Expected ID to be 12345")
                XCTAssertEqual(phone, 123456789, "Expected Phone to be 123456789")
                self.expectation.fulfill()
            } catch {
                XCTFail("Error should not be thrown.")
                self.expectation.fulfill()
            }
        }
        
        wait(for: [expectation], timeout: 1.0)
    }
    
    func testGetOperators() async throws {
        let mockResponse = """
            {
                "status": "success",
                "countryOperators": {
                    "0": [
                        "beeline",
                        "megafon",
                        "mts",
                        "sber"]
                }
            }
            """
        let responseData = mockResponse.data(using: .utf8)!
        
        MockURLProtocol.requestHandler = { request in
            let response = HTTPURLResponse(url: request.url!, statusCode: 200, httpVersion: nil, headerFields: nil)!
            return (response, responseData)
        }
        
        // Call API
        Task {
            do {
                let operators = try await smsActivateAPI.getOperators(countryId: 1)
                XCTAssertEqual(operators["0"], ["beeline", "megafon", "mts", "sber"], "Expected operators to match the mock response")
                self.expectation.fulfill()
            } catch {
                XCTFail("Error should not be thrown.")
                self.expectation.fulfill()
            }
        }
        
        wait(for: [expectation], timeout: 1.0)
    }
    
    func testGetCountries() async throws {
        let mockResponse: [String: CountryResponse] = [
            "0": CountryResponse(id: 0, rus: "Россия", eng: "Russia", chn: "俄罗斯", visible: true, retry: true, rent: true, multiService: true),
            "1": CountryResponse(id: 1, rus: "Украина", eng: "Ukraine", chn: "乌克兰", visible: true, retry: true, rent: true, multiService: true),
            "2": CountryResponse(id: 2, rus: "Казахстан", eng: "Kazakhstan", chn: "哈萨克斯坦", visible: true, retry: true, rent: true, multiService: true),
        ]
        let responseData = try JSONEncoder().encode(mockResponse)
        
        MockURLProtocol.requestHandler = { request in
            let response = HTTPURLResponse(url: request.url!, statusCode: 200, httpVersion: nil, headerFields: nil)!
            return (response, responseData)
        }
        
        Task {
            do {
                let countries = try await smsActivateAPI.getCountries()
                let sortedMockCountries = Array(mockResponse.values).sorted { $0.id < $1.id }
                let sortedCountries = countries.sorted { $0.id < $1.id }
                XCTAssertEqual(sortedCountries, sortedMockCountries, "Expected countries to be equal")
                self.expectation.fulfill()
            } catch {
                XCTFail("Error should not be thrown.")
                self.expectation.fulfill()
            }
        }
        
        wait(for: [expectation], timeout: 1.0)
    }
    
    func testGetStatus() async throws {
        let mockResponse = "STATUS_OK:123456"
        let responseData = mockResponse.data(using: .utf8)!
        
        MockURLProtocol.requestHandler = { request in
            let response = HTTPURLResponse(url: request.url!, statusCode: 200, httpVersion: nil, headerFields: nil)!
            return (response, responseData)
        }
        
        // Call API
        let id = 12345
        Task {
            do {
                let (status, code) = try await smsActivateAPI.getStatus(id: id)
                XCTAssertEqual(status, GetStatus.ok, "Expected ActivationStatus to be .ready")
                XCTAssertEqual(code, "123456", "Expected code to be 123456")
                self.expectation.fulfill()
            } catch {
                XCTFail("Error should not be thrown.")
                self.expectation.fulfill()
            }
        }
        
        wait(for: [expectation], timeout: 1.0)
    }
    
    func testGetActiveActivations() async throws {
        let mockResponse = ActiveActivationsResponse(status: "success", activeActivations: [
            ActiveActivation(activationId: "1361626267", serviceCode: "rd", phoneNumber: "79682066869", activationCost: "10.00", activationStatus: "4", smsCode: nil, smsText: nil, activationTime: "2023-03-24 21:09:51", discount: "0", repeated: "0", countryCode: "0", countryName: "Russia", canGetAnotherSms: "1"),
            ActiveActivation(activationId: "1361626268", serviceCode: "rd", phoneNumber: "79682098576", activationCost: "10.00", activationStatus: "4", smsCode: nil, smsText: nil, activationTime: "2023-03-24 21:09:51", discount: "0", repeated: "0", countryCode: "0", countryName: "Russia", canGetAnotherSms: "1"),
            ActiveActivation(activationId: "1361626250", serviceCode: "rd", phoneNumber: "79682098000", activationCost: "10.00", activationStatus: "4", smsCode: "3245", smsText: "Hello", activationTime: "2023-03-24 21:09:51", discount: "0", repeated: "0", countryCode: "0", countryName: "Russia", canGetAnotherSms: "1")
        ], error: nil)
        let responseData = try JSONEncoder().encode(mockResponse)
        
        MockURLProtocol.requestHandler = { request in
            let response = HTTPURLResponse(url: request.url!, statusCode: 200, httpVersion: nil, headerFields: nil)!
            return (response, responseData)
        }
        
        Task {
            do {
                let activeActivations = try await smsActivateAPI.getActiveActivations()
                let sortedMockActivations = mockResponse.activeActivations!.sorted { $0.activationId < $1.activationId }
                let sortedActivations = activeActivations.sorted { $0.activationId < $1.activationId }
                XCTAssertEqual(sortedActivations, sortedMockActivations, "Expected active activations to be equal")
                self.expectation.fulfill()
            } catch {
                XCTFail("Error should not be thrown.")
                self.expectation.fulfill()
            }
        }
        wait(for: [expectation], timeout: 1.0)
    }
    
    func testSetStatus() async throws {
        let mockResponse = "ACCESS_ACTIVATION"
        let responseData = mockResponse.data(using: .utf8)!
        
        MockURLProtocol.requestHandler = { request in
            let response = HTTPURLResponse(url: request.url!, statusCode: 200, httpVersion: nil, headerFields: nil)!
            return (response, responseData)
        }
        
        // Call API
        let setStatusRequest = SetStatusRequest(id: "34134", status: .cancelActivation)
        Task {
            do {
                let response = try await smsActivateAPI.setStatus(request: setStatusRequest)
                XCTAssertEqual(response, SetStatusResponse.accessActivation, "Expected response to be .accessActivation")
                self.expectation.fulfill()
            } catch {
                XCTFail("Error should not be thrown.")
                self.expectation.fulfill()
            }
        }
        
        wait(for: [expectation], timeout: 1.0)
    }
    
}
