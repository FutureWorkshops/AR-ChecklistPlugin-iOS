//
//  ChecklistStep.swift
//  ChecklistPlugin
//
//

import Foundation
import MobileWorkflowCore
import SwiftUI

public struct ChecklistItem: Codable, Identifiable {
    public let id: String
    public let text: String
}
 

public class ChecklistStep: ObservableStep {
    let items: [ChecklistItem]

    public init(identifier: String, items: [ChecklistItem], session: Session, services: StepServices) {
        self.items = items
        super.init(identifier: identifier, session: session, services: services)
    }

    public override func instantiateViewController() -> StepViewController {
        ChecklistStepViewController(step: self)
    }
}

extension ChecklistStep: BuildableStep {

    public static var mandatoryCodingPaths: [CodingKey] {
        ["items"]
    }

    public static func build(stepInfo: StepInfo, services: StepServices) throws -> Step {
        guard let items = stepInfo.data.content["items"] as? [[String: Any]] else {
            throw ParseError.invalidStepData(cause: "Mandatory items property not found")
        }

        let checklistItems: [ChecklistItem] = try items.map {
            return try makeChecklistItem(with: $0)
        }
        
        return ChecklistStep(identifier: stepInfo.data.identifier, items: checklistItems, session: stepInfo.session, services: services)
    }
    
    private static func makeChecklistItem(with item: [String: Any]) throws -> ChecklistItem {
        guard let id = item.getString(key: "id") else {
            throw ParseError.invalidStepData(cause: "Invalid id for step")
        }
        
        guard let text = item["text"] as? String else {
            throw ParseError.invalidStepData(cause: "Invalid text for step")
        }
        
        return ChecklistItem(id: id, text: text)
    }
}

public class ChecklistStepViewController: MWStepViewController {
    public override var titleMode: StepViewControllerTitleMode { .smallTitle }
    var checklistStep: ChecklistStep { self.step as! ChecklistStep }
    
        public override func viewDidLoad() {
            super.viewDidLoad()
            let checked = checklistStep.items.map({ _ in false})
            self.addCovering(childViewController: UIHostingController(
            rootView: ChecklistStepContentView(content: checklistStep.items).environmentObject(self.checklistStep)
        ))
    }
    
}

struct ChecklistStepContentView: View {
    @EnvironmentObject var step: ChecklistStep
    var navigator: Navigator { step.navigator }
    @State var content: [ChecklistItem]
    
    var body: some View {
        List(content) { item in
            ChecklistStepListItemView(step: step, item: item)
        }
    }
}

struct ChecklistStepListItemView: View {
    var step: ChecklistStep
    var item: ChecklistItem
    @AppStorage var checked: Bool
    
    init(step: ChecklistStep, item: ChecklistItem) {
        self.step = step
        self.item = item
        self._checked = AppStorage(wrappedValue: false, item.id)
    }
    
    var body: some View {
        HStack() {
            Image(systemName: checked ? "checkmark.circle.fill" : "circle")
                .foregroundColor(Color(step.theme.primaryTintColor))
            Text(item.text)
                .frame(maxWidth: .infinity, alignment: .leading)
                
        }
        .contentShape(Rectangle())
        .onTapGesture {
            checked = !checked
        }
    }
}

struct ChecklistStepContentViewPreviews: PreviewProvider {
    static var previews: some View {
        ChecklistStepContentView(content: [
            ChecklistItem(id: "1", text: "Milk"),
            ChecklistItem(id: "2", text: "Cheese")
        ]
        ).environmentObject(ChecklistStep(
            identifier: "",
            items: [],
            session: Session.buildEmptySession(),
            services: StepServices.buildEmptyServices()
        ))
    }
}

