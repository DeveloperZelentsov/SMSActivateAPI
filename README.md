# SmsActivateAPI Swift Library #

A Swift package for interacting with the [SMS Activate](https://sms-activate.org/?ref=921566) API. This package provides an easy way to manage phone numbers for SMS-based verification services.

## Features ##

* Get account balance and cashback information
* Request a phone number for activation
* Get activation status
* Retrieve active activations
* Set activation status
* Get available operators for a given country
* Retrieve the list of all countries

## Requirements ##

* iOS 15.0+
* Swift 5.6+

## Installation ##

Add the library to your project using Swift Package Manager:

1. Open your project in Xcode.
2. Go to File > Swift Packages > Add Package Dependency.
3. Enter the repository URL `https://github.com/DeveloperZelentsov/SMSActivateAPI` for the SmsActivateAPI library and click Next.
4. Choose the latest available version and click Next.
5. Select the target where you want to use SmsActivateAPI and click Finish.

## Usage ##

### Initialization ###

First, import the **_SmsActivateAPI_** library in your Swift file:

```swift
import SmsHubAPI
```

To start using the library, create an instance of **_SmsActivateAPI_** with your API key:

```swift
let smsActivateAPI = SmsActivateAPI(apiKey: "your_api_key_here")
```

### Get account balance ###

To get the account balance, call the `getBalance(with state: BalanceState)` function:

```swift
do {
    let balance = try await smsActivateAPI.getBalance(with: .balance)
    print("Account balance: \(balance)")
} catch {
    print("Error: \(error)")
}
```

### Request a phone number ###

To request a phone number, create a GetNumberRequest object and call the `getNumber(request: GetNumberRequest)` function:

```swift
do {
    let request = GetNumberRequest(service: "your_service_code", countryId: "your_country_id")
    let (activationId, phoneNumber) = try await smsActivateAPI.getNumber(request: request)
    print("Activation ID: \(activationId), Phone Number: \(phoneNumber)")
} catch {
    print("Error: \(error)")
}
```

### Get activation status ###

To get the activation status, call the `getStatus(id: Int)` function:

```swift
do {
    let activationId = 12345
    let (status, code) = try await smsActivateAPI.getStatus(id: activationId)
    print("Status: \(status), Code: \(String(describing: code))")
} catch {
    print("Error: \(error)")
}
```

### Retrieve active activations ###

To get the list of active activations, call the `getActiveActivations()` function:

```swift
do {
    let activeActivations = try await smsActivateAPI.getActiveActivations()
    print("Active activations: \(activeActivations)")
} catch {
    print("Error: \(error)")
}
```

### Set activation status ###

To set the activation status, create a SetStatusRequest object and call the `setStatus(request: SetStatusRequest)` function:

```swift
do {
    let activationId = 12345
    let setStatus = SetStatus.ready
    let request = SetStatusRequest(id: activationId, status: setStatus)
    let response = try await smsActivateAPI.setStatus(request: request)
    print("Status set response: \(response)")
} catch {
    print("Error: \(error)")
}
```

### Get available operators for a given country ###

To get available operators for a given country, call the `getOperators(countryId: Int?)` function:

```swift
do {
    let countryId = 1
    let operators = try await smsActivateAPI.getOperators(countryId: countryId)
    print("Available operators: \(operators)")
} catch {
    print("Error: \(error)")
}
```

### Retrieve the list of all countries ###

To get the list of all countries, call the `getCountries()` function:

```swift
do {
    let countries = try await smsActivateAPI.getCountries()
    print("Countries: \(countries)")
} catch {
    print("Error: \(error)")
}
```

For more information on the available methods and their parameters, refer to the **_ISmsActivateAPI_** protocol and the library's source code.

## License ##

This project is released under the MIT License.
