//
// StatusIcon.swift
// Apple Juice
// https://github.com/raphaelhanneken/apple-juice
//

import Cocoa

final class StatusBarItem: NSObject {

    ///  The applications status bar item.
    private let item: NSStatusItem!

    ///  The icon to display in the battery status bar item.
    private var icon: StatusBarIcon?

    ///  Creates a new battery status bar item object.
    ///
    ///  - Parameters:
    ///    - action: The action to be triggered, when the user clicks on the status bar item.
    ///    - target: The target that implements the supplied action.
    init(forBattery battery: BatteryService?, withAction action: Selector?, forTarget target: AnyObject?) {
        item = NSStatusBar.system.statusItem(withLength: NSStatusItem.variableLength)
        item.target = target
        item.action = action

        self.icon = StatusBarIcon()
        super.init()
    }

    ///  Creates a status bar item object for a specific error.
    ///
    ///  - Parameters:
    ///    - error: The error that occured.
    ///    - action: The action to be triggered, when the user clicks on the status bar item.
    ///    - target: The target that implements the supplied action.
    convenience init(forError error: BatteryError?, withAction action: Selector?, forTarget target: AnyObject?) {
        self.init(forBattery: nil, withAction: action, forTarget: target)

        guard let btn = item.button else {
            return
        }
        btn.image = icon?.drawBatteryImage(forError: error)
    }

    ///  Update the status bar items title and icon.
    ///
    ///  - parameter battery: The battery object, to update the status bar item for.
    public func update(batteryInfo battery: BatteryService?) {
        setBatteryIcon(battery)
        setTitle(battery)
    }

    ///  Displays the supplied menu object when the user clicks on the status bar item.
    ///
    ///  - parameter menu: The menu object to display to the user.
    public func popUpMenu(_ menu: NSMenu) {
        item.popUpMenu(menu)
    }

    ///  Sets the status bar item's battery icon.
    ///
    ///  - parameter batter: The battery to render the status bar icon for.
    private func setBatteryIcon(_ battery: BatteryService?) {
        guard let batteryState = battery?.state,
              let button = item.button
        else {
            return
        }

        if UserPreferences.hideBatteryIcon {
            button.image = nil
        } else {
            button.image = icon?.drawBatteryImage(forStatus: batteryState)
            button.imagePosition = .imageRight
        }
    }

    ///  Sets the status bar item's title
    ///
    ///  - parameter battery: The battery to build the status bar title for.
    private func setTitle(_ battery: BatteryService?) {
        guard let button = item.button,
              let percentage = battery?.percentageFormatted,
              let timeRemaining = battery?.timeRemainingFormatted,
              let batteryState = battery?.state
        else {
            return
        }

        let titleAttributes = [NSAttributedString.Key.font: NSFont.menuBarFont(ofSize: 11.0)]

        button.attributedTitle = NSAttributedString(string: percentage, attributes: titleAttributes)
        if UserPreferences.hideMenubarInfo || batteryState == .chargedAndPlugged {
            button.attributedTitle = NSAttributedString(string: "")
        } else if UserPreferences.showTime {
            button.attributedTitle = NSAttributedString(string: timeRemaining, attributes: titleAttributes)
        }
    }

}
