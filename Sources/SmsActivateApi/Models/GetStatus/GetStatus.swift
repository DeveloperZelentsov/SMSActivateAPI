//
//  File.swift
//  
//
//  Created by Alexey on 24.03.2023.
//

import Foundation

public enum GetStatus: String, Codable {
    case waitCode = "STATUS_WAIT_CODE"
    case waitRetry = "STATUS_WAIT_RETRY"
    case waitResend = "STATUS_WAIT_RESEND"
    case cancel = "STATUS_CANCEL"
    case ok = "STATUS_OK"
}
