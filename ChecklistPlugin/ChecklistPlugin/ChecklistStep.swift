//
//  ChecklistStep.swift
//  ChecklistPlugin
//
//

import Foundation
import MobileWorkflowCore
import SwiftUI

// MARK: - Step properties configuration

public struct ChecklistChecklistItem: Codable, Identifiable {
	enum CodingKeys: String, CodingKey {
		case id
		case text
	}
	
	public let id: String
	public let text: String

	public static func checklistChecklistItem(id: String, text: String) -> ChecklistChecklistItem {
		ChecklistChecklistItem(
			id: id,
			text: text
		)
	}
}
 /// Method used to details the configuration of a ChecklistStep to be used in the app.
/// - Parameters:
///   - id: String used to represent this step further in the configuration. For example, to use as target on links
///   - title: Title of the step
///   - items: Items. 
///   - next: The next step in the flow, if any. This can be configured by using `.push(target: \"next_step_id\")`
///   - links: If the step can present modals or uses conditional push navigations, the links can be listed on this array`
public class ChecklistChecklistMetadata: StepMetadata {
	enum CodingKeys: String, CodingKey {
		case items
	}

	/// Items. 
	let items: [ChecklistChecklistItem]

	/// Method used to details the configuration of a ChecklistStep to be used in the app.
	/// - Parameters:
	///   - id: String used to represent this step further in the configuration. For example, to use as target on links
	///   - title: Title of the step
	///   - items: Items. 
	///   - next: The next step in the flow, if any. This can be configured by using `.push(target: \"next_step_id\")`
	///   - links: If the step can present modals or uses conditional push navigations, the links can be listed on this array`
	/// - Returns: ChecklistChecklist fully configured for use
	init(id: String, title: String, items: [ChecklistChecklistItem], next: PushLinkMetadata?, links: [LinkMetadata]) {
		self.items = items
		super.init(id: id, type: "io.app-rail.checklist.checklist", title: title, next: next, links: links)
	}

    public required init(from decoder: Decoder) throws {
        /// The `init(from:)` method is necessary to be able to correctly load the properties into your `ObservableStep`.
        /// Here, it is also possible to build complex types from lower level types. For example: `self.sfSymbol = UIImage(systemName: try container.decode(String.self, forKey: .sfSymbolName))`
        /// When adding a new property to the step, please, remember to also decode it here. Otherwise, the configuration may be lost on translation.
		let container = try decoder.container(keyedBy: CodingKeys.self)
		self.items = try container.decode([ChecklistChecklistItem].self, forKey: .items)
        try super.init(from: decoder)
    }

	public override func encode(to encoder: Encoder) throws {
        /// The `encode(to:)` method is necessary to correctly export the configuration into the App Rail coordinator.
        /// Here, it is also possible to convert complext types (like UIImage or NSURL) into lower level types.
        /// When adding a new property to the step, please, remember to also encode it here. Otherwise, the configuration may be lost on translation.
		var container = encoder.container(keyedBy: CodingKeys.self)
		try container.encode(self.items, forKey: .items)
		try super.encode(to: encoder)
	}
}

public extension StepMetadata {
	/// Method used to details the configuration of a ChecklistStep to be used in the app.
	/// - Parameters:
	///   - id: String used to represent this step further in the configuration. For example, to use as target on links
	///   - title: Title of the step
	///   - items: Items. 
	///   - next: The next step in the flow, if any. This can be configured by using `.push(target: \"next_step_id\")`
	///   - links: If the step can present modals or uses conditional push navigations, the links can be listed on this array`
	/// - Returns: ChecklistChecklist fully configured for use
	static func checklistChecklist(id: String, title: String, items: [ChecklistChecklistItem], next: PushLinkMetadata? = nil, links: [LinkMetadata] = []) -> ChecklistChecklistMetadata {
		ChecklistChecklistMetadata(
			id: id,
			title: title,
			items: items,
			next: next,
            links: links
		)
        /**
        * The checklistChecklist is the configuration method used by the App Rail platform to export the user made configuration into the App.swift configuration file.
        * It is expected that this function have its parameters following the order: 
        *   - id
        *   - title
        *   - required properties sorted alphabetically
        *   - optional properties sorted alphabetically
        *   - next
        *   - links
        * When adding or removing a property manually, please ensure to follow the definition above to avoid compilation issues when exporting an app configuration using the platform.
        **/ 
	}
}

// MARK: - Step support declaration

/// The `ChecklistStep` is an `ObservableObject` subclass of `ObservableStep` that can be used as a ViewModel to interact with App Rail system and functionalities.
/// - Parameters:
///   - properties: ChecklistChecklistMetadata with the information configured in the `App.swift` file
///   - session:    `Session` object that collects the previous answers of the flow. It can be used to integrate with other steps in the app
///   - services:   `StepServices` that can be used to perform background tasks using App Rail's services, like the Rest service
/// Examples of this interaction are:
///   - Perform GET request using App Rail session: `let cities: [Cities] = try await step.get(path: "/cities")`
///   - Fetch session properties as string: `step.resolve("{step_id.answer}")`
///   - Use localisation tables to translate strings: `step.resolve("Reload")`
///   - Continue into the next step: `step.navigator.continue()`
///   - Continue into the next step providing an answer to be stored in the session: `step.navigator.continue(storing: "Agreed")`
public class ChecklistStep: ObservableStep, BuildableStepWithMetadata {
    public let properties: ChecklistChecklistMetadata

    required public init(properties: ChecklistChecklistMetadata, session: Session, services: StepServices) {
        self.properties = properties
        super.init(identifier: properties.id, session: session, services: services)
    }

    public override func instantiateViewController() -> StepViewController {
        ChecklistStepViewController(step: self)
    }
}

public class ChecklistStepViewController: MWStepViewController {
    public override var titleMode: StepViewControllerTitleMode { .smallTitle }
    var checklistStep: ChecklistStep { self.step as! ChecklistStep }
    
        public override func viewDidLoad() {
            super.viewDidLoad()
            let items = checklistStep.properties.items
            let checked = items.map({ _ in false})
            self.addCovering(childViewController: UIHostingController(
                rootView: ChecklistStepContentView(content: items).environmentObject(self.checklistStep)
        ))
    }
    
}

struct ChecklistStepContentView: View {
    @EnvironmentObject var step: ChecklistStep
    var navigator: Navigator { step.navigator }
    @State var content: [ChecklistChecklistItem]
    
    var body: some View {
        List(content) { item in
            ChecklistStepListItemView(step: step, item: item)
        }
    }
}

struct ChecklistStepListItemView: View {
    var step: ChecklistStep
    var item: ChecklistChecklistItem
    @AppStorage var checked: Bool
    
    init(step: ChecklistStep, item: ChecklistChecklistItem) {
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
            .init(id: "1", text: "Milk"),
            .init(id: "2", text: "Cheese")
        ]
        ).environmentObject(
            ChecklistStep(
                properties: .init(
                    id: "",
                    title: "",
                    items: [],
                    next: nil,
                    links: []
                ),
                session: Session.buildEmptySession(),
                services: StepServices.buildEmptyServices()
            )
        )
    }
}

