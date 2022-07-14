//
//  GCDBlackBox.swift
//  OnTheMap
//
//  Created on 1/26/17.
//

import Foundation

func performUIUpdatesOnMain(_ updates: @escaping () -> Void) {
    DispatchQueue.main.async {
        updates()
    }
}
