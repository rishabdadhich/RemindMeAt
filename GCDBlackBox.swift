//
//  GCDBlackBox.swift
//  Remind Me At
//
//  Created by Rishabh on 03/07/1939 Saka.
//  Copyright © 1939 Saka rishi. All rights reserved.
//

import Foundation

func performUIUpdatesOnMain(_ updates: @escaping () -> Void) {
    DispatchQueue.main.async {
        updates()
    }
}
