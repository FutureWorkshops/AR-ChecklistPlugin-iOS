//
//  ChecklistPlugin.swift
//  ChecklistPlugin
//
//

import Foundation
import MobileWorkflowCore

public struct ChecklistPluginStruct: Plugin {
    public static var allStepsTypes: [StepType] {
        return ChecklistStepType.allCases
    }
}

enum ChecklistStepType: String, StepType, CaseIterable {
    case step1 = "io.app-rail.checklist.checklist"
    
    var typeName: String {
        return self.rawValue
    }
    
    var stepClass: BuildableStep.Type {
        switch self {
        case .step1: return ChecklistStep.self
        }
    }
}

