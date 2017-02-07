//
//  String+Encryption.swift
//  ReserveMe
//
//  Created by user on 8/14/16.
//  Copyright © 2016 user. All rights reserved.
//

import Foundation


extension String {
	func sha1() -> String {
		let data = self.data(using: String.Encoding.utf8)!
		var digest = [UInt8](repeating: 0, count: Int(CC_SHA1_DIGEST_LENGTH))
		CC_SHA1((data as NSData).bytes, CC_LONG(data.count), &digest)
		let hexBytes = digest.map() { String(format: "%02hhx", $0) }
		return hexBytes.joined(separator: "")
	}
}
