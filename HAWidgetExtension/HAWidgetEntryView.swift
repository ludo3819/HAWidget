import WidgetKit
import SwiftUI

/// Vue affichée par le widget
struct HAWidgetEntryView: View {
    var entry: HAWidgetProvider.Entry
    @Environment(\.widgetFamily) var widgetFamily
    
    var body: some View {
        ZStack {
            ContainerBackground(for: .widget) {
                Color.clear
            }
            
            VStack(spacing: 12) {
                HStack {
                    Image(systemName: "homekit")
                        .font(.system(size: 16, weight: .semibold))
                    
                    Text("Home Assistant")
                        .font(.system(size: 14, weight: .semibold))
                    
                    Spacer()
                }
                .foregroundColor(.blue)
                
                if let error = entry.error {
                    VStack(spacing: 8) {
                        Image(systemName: "exclamationmark.circle.fill")
                            .font(.system(size: 28))
                            .foregroundColor(.red)
                        
                        Text(error)
                            .font(.caption)
                            .foregroundColor(.secondary)
                    }
                    .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .center)
                } else if entry.isLoading {
                    ProgressView()
                        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .center)
                } else if entry.entities.isEmpty {
                    VStack(spacing: 8) {
                        Image(systemName: "square.and.pencil")
                            .font(.system(size: 28))
                            .foregroundColor(.gray)
                        
                        Text("Aucune entité")
                            .font(.caption)
                            .foregroundColor(.secondary)
                    }
                    .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .center)
                } else {
                    widgetContent
                }
                
                Spacer()
            }
            .padding(.vertical, 10)
            .padding(.horizontal, 12)
        }
    }
    
    @ViewBuilder
    private var widgetContent: some View {
        switch widgetFamily {
        case .systemSmall:
            smallWidget
        case .systemMedium:
            mediumWidget
        case .systemLarge:
            largeWidget
        default:
            mediumWidget
        }
    }
    
    private var smallWidget: some View {
        let switchEntities = entry.entities.filter { $0.type == .switch || $0.type == .light }
        let firstEntity = switchEntities.first
        
        return VStack(spacing: 8) {
            if let entity = firstEntity {
                VStack(alignment: .leading, spacing: 4) {
                    Text(entity.friendlyName)
                        .font(.system(size: 12, weight: .semibold))
                        .lineLimit(1)
                    
                    HStack {
                        Circle()
                            .fill(entity.isOn ? Color.green : Color.gray)
                            .frame(width: 8, height: 8)
                        
                        Text(entity.isOn ? "ON" : "OFF")
                            .font(.caption)
                            .foregroundColor(.secondary)
                    }
                }
            }
            
            Spacer()
        }
    }
    
    private var mediumWidget: some View {
        let switchEntities = entry.entities.filter { $0.type == .switch || $0.type == .light }.prefix(2)
        
        return VStack(spacing: 8) {
            ForEach(switchEntities, id: \.id) { entity in
                HStack {
                    VStack(alignment: .leading, spacing: 2) {
                        Text(entity.friendlyName)
                            .font(.system(size: 12, weight: .semibold))
                            .lineLimit(1)
                        
                        Text(entity.entityId)
                            .font(.system(size: 10))
                            .foregroundColor(.secondary)
                            .lineLimit(1)
                    }
                    
                    Spacer()
                    
                    HStack(spacing: 4) {
                        Circle()
                            .fill(entity.isOn ? Color.green : Color.gray)
                            .frame(width: 8, height: 8)
                        
                        Text(entity.isOn ? "ON" : "OFF")
                            .font(.system(size: 10, weight: .semibold))
                            .foregroundColor(entity.isOn ? .green : .gray)
                    }
                }
                .padding(.vertical, 6)
                .padding(.horizontal, 8)
                .background(Color(.systemGray6))
                .cornerRadius(6)
            }
            
            Spacer()
        }
    }
    
    private var largeWidget: some View {
        let switchEntities = entry.entities.filter { $0.type == .switch || $0.type == .light }.prefix(4)
        let coverEntities = entry.entities.filter { $0.type == .cover }.prefix(2)
        
        return VStack(spacing: 8) {
            if !switchEntities.isEmpty {
                Text("Interrupteurs")
                    .font(.system(size: 10, weight: .semibold))
                    .foregroundColor(.secondary)
                    .frame(maxWidth: .infinity, alignment: .leading)
                
                ForEach(switchEntities, id: \.id) { entity in
                    HStack {
                        Text(entity.friendlyName)
                            .font(.system(size: 11, weight: .semibold))
                            .lineLimit(1)
                        
                        Spacer()
                        
                        Circle()
                            .fill(entity.isOn ? Color.green : Color.gray)
                            .frame(width: 6, height: 6)
                        
                        Text(entity.isOn ? "ON" : "OFF")
                            .font(.system(size: 9))
                            .foregroundColor(.secondary)
                    }
                }
            }
            
            if !coverEntities.isEmpty {
                Divider()
                    .padding(.vertical, 4)
                
                Text("Stores")
                    .font(.system(size: 10, weight: .semibold))
                    .foregroundColor(.secondary)
                    .frame(maxWidth: .infinity, alignment: .leading)
                
                ForEach(coverEntities, id: \.id) { entity in
                    HStack {
                        Text(entity.friendlyName)
                            .font(.system(size: 11, weight: .semibold))
                            .lineLimit(1)
                        
                        Spacer()
                        
                        Text(entity.state.capitalized)
                            .font(.system(size: 9))
                            .foregroundColor(.secondary)
                    }
                }
            }
            
            Spacer()
        }
    }
}

#Preview(as: .systemMedium) {
    HAWidget()
} timeline: {
    HAWidgetEntry(
        date: Date(),
        entities: [
            Entity(
                id: "switch.lampe_killian",
                entityId: "switch.lampe_killian",
                friendlyName: "Lampe Killian",
                state: "on",
                attributes: [:],
                lastChanged: Date(),
                lastUpdated: Date()
            ),
            Entity(
                id: "cover.amie",
                entityId: "cover.amie",
                friendlyName: "Store Amis",
                state: "open",
                attributes: [:],
                lastChanged: Date(),
                lastUpdated: Date()
            )
        ],
        error: nil,
        isLoading: false
    )
}
