//
//  WeatherWidgetProviderLiveActivity.swift
//  WeatherWidgetProvider
//
//  Created by Chris KOUASSI on 05/04/2026.
//

import ActivityKit
import WidgetKit
import SwiftUI

struct WeatherWidgetProviderAttributes: ActivityAttributes {
    public struct ContentState: Codable, Hashable {
        // Dynamic stateful properties about your activity go here!
        var emoji: String
    }

    // Fixed non-changing properties about your activity go here!
    var name: String
}

struct WeatherWidgetProviderLiveActivity: Widget {
    var body: some WidgetConfiguration {
        ActivityConfiguration(for: WeatherWidgetProviderAttributes.self) { context in
            // Lock screen/banner UI goes here
            VStack {
                Text("Hello \(context.state.emoji)")
            }
            .activityBackgroundTint(Color.cyan)
            .activitySystemActionForegroundColor(Color.black)

        } dynamicIsland: { context in
            DynamicIsland {
                // Expanded UI goes here.  Compose the expanded UI through
                // various regions, like leading/trailing/center/bottom
                DynamicIslandExpandedRegion(.leading) {
                    Text("Leading")
                }
                DynamicIslandExpandedRegion(.trailing) {
                    Text("Trailing")
                }
                DynamicIslandExpandedRegion(.bottom) {
                    Text("Bottom \(context.state.emoji)")
                    // more content
                }
            } compactLeading: {
                Text("L")
            } compactTrailing: {
                Text("T \(context.state.emoji)")
            } minimal: {
                Text(context.state.emoji)
            }
            .widgetURL(URL(string: "http://www.apple.com"))
            .keylineTint(Color.red)
        }
    }
}

extension WeatherWidgetProviderAttributes {
    fileprivate static var preview: WeatherWidgetProviderAttributes {
        WeatherWidgetProviderAttributes(name: "World")
    }
}

extension WeatherWidgetProviderAttributes.ContentState {
    fileprivate static var smiley: WeatherWidgetProviderAttributes.ContentState {
        WeatherWidgetProviderAttributes.ContentState(emoji: "😀")
     }
     
     fileprivate static var starEyes: WeatherWidgetProviderAttributes.ContentState {
         WeatherWidgetProviderAttributes.ContentState(emoji: "🤩")
     }
}

#Preview("Notification", as: .content, using: WeatherWidgetProviderAttributes.preview) {
   WeatherWidgetProviderLiveActivity()
} contentStates: {
    WeatherWidgetProviderAttributes.ContentState.smiley
    WeatherWidgetProviderAttributes.ContentState.starEyes
}
