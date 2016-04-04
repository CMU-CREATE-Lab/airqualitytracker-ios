//
//  Constants.swift
//  AirPrototype
//
//  Created by mtasota on 7/13/15.
//  Copyright (c) 2015 CMU Create Lab. All rights reserved.
//

import Foundation
import UIKit

let MATH_PI = 3.14159265358979

class Constants {
    
    static let APP_VERSION_NUMBER = "2.3"
    
    static let USES_BACKGROUND_SERVICES = true
    
    static let DEFAULT_SETTINGS: [String:AnyObject] = [
        SettingsKeys.appUsesLocation: true,
        SettingsKeys.userLoggedIn: false,
        SettingsKeys.username: "",
        SettingsKeys.userId: -1,
        SettingsKeys.expiresAt:0,
        SettingsKeys.accessToken: "",
        SettingsKeys.refreshToken: "",
        SettingsKeys.blacklistedDevices: [],
        SettingsKeys.addressLastPosition: 1,
        SettingsKeys.speckLastPosition: 1
    ]

    // these are the channel names that we want our feeds to report
    static let channelNames = [
            "pm2_5", "PM2_5", "pm2_5_1hr",
            "pm2_5_24hr", "PM25B_UG_M3", "PM25_UG_M3",
            "particle_concentration"
    ]
    
    // This should be either INSTANTCAST or NOWCAST
    static let DEFAULT_ADDRESS_READABLE_VALUE_TYPE: Feed.ReadableValueType = Feed.ReadableValueType.NOWCAST

    static let READINGS_MAX_TIME_RANGE: Double = 86400 // 24 hours
    
    static let SPECKS_MAX_TIME_RANGE: Double = 1800  // 30 minutes
    
    static let ESDR_TOKEN_TIME_TO_UPDATE_ON_REFRESH: Int = 86400 // 24 hours
    
    struct AppSecrets {
        // placeholder for actual Client information (don't push to git)
        static let ESDR_CLIENT_ID = "client_id"
        static let ESDR_CLIENT_SECRET = "this should never work"
        static let AIR_NOW_API_KEY = "this-is-your-airnow-key-dont-push"
    }
    
    struct SettingsKeys {
        static let appUsesLocation = "app_uses_location"
        static let userLoggedIn = "user_logged_in"
        static let username = "username"
        static let userId = "user_id"
        static let expiresAt = "expires_at"
        static let accessToken = "access_token"
        static let refreshToken = "refresh_token"
        static let blacklistedDevices = "blacklisted_devices"
        static let addressLastPosition = "address_last_position"
        static let speckLastPosition = "speck_last_position"
    }

    struct Location {
        static let LOCATION_REQUEST_INTERVAL: Double = 600000 // 10 minutes
        static let LOCATION_REQUEST_FASTEST_INTERVAL: Double = 60000 // 1 minute
    }

    struct Units {
        static let MICROGRAMS_PER_CUBIC_METER = "µg/m³";
        static let AQI = "AQI";
        static let RANGE_MICROGRAMS_PER_CUBIC_METER = "µg/m³    /500";
        static let RANGE_AQI = "AQI    /500";
    }
    
    struct Esdr {
        static let API_URL = "https://esdr.cmucreatelab.org";
        static let GRANT_TYPE_TOKEN = "password";
        static let GRANT_TYPE_REFRESH = "refresh_token";
    }
    
    struct AirNow {
        static let API_URL = "http://www.airnowapi.org"
    }
    
    struct MapGeometry {
        // Distance from central point, in kilometers (box dimension will be 2x larger)
        static let BOUNDBOX_HEIGHT = 40.0;
        // Distance from central point, in kilometers (box dimension will be 2x larger)
        static let BOUNDBOX_LENGTH = 40.0;
        // radius of Earth (in kilometers)
        static let RADIUS_EARTH = 6371.0;
        // ASSERT these values will be less than 90.0
        static let BOUNDBOX_LAT = BOUNDBOX_HEIGHT / ( RADIUS_EARTH * 2 * MATH_PI ) * 360.0;
        static let BOUNDBOX_LONG = BOUNDBOX_LENGTH / ( RADIUS_EARTH * 2 * MATH_PI ) * 360.0;
    }
    
    // Interface-related tags
    
    static let HEADER_TITLES = [
        "SPECK DEVICES",
        "CITIES"
    ]
    
    struct CellReuseIdentifiers {
        static let ADDRESS_LIST = "reuseAddressList"
        static let ADDRESS_SEARCH = "reuseAddressSearch"
    }
    
    // Content for Readable
    
    struct DefaultReading {
        static let DEFAULT_LOCATION = "N/A";
        static let DEFAULT_COLOR_BACKGROUND = UIColor(red: 64.0/255.0, green: 64.0/255.0, blue: 65.0/255.0, alpha: 1.0)
        static let DEFAULT_TITLE = "Unavailable";
        static let DEFAULT_DESCRIPTION = "The current AQI for this region is unavailable.";
    }
    
    
    struct SpeckReading {
        // TODO replace with speck descriptions?
        static let descriptions = [
                "Air quality is considered Good.",
                "Air quality is considered Moderate.",
                "Air quality is considered Slightly Elevated.",
                "Air quality is considered Elevated.",
                "Air quality is considered High.",
                "Air quality is considered Very High."
        ]
        static let normalColors = [
            UIColor(red: 26.0/255.0, green: 152.0/255.0, blue: 80.0/255.0, alpha: 1.0),
            UIColor(red: 145.0/255.0, green: 207.0/255.0, blue: 96.0/255.0, alpha: 1.0),
            UIColor(red: 217.0/255.0, green: 239.0/255.0, blue: 139.0/255.0, alpha: 1.0),
            UIColor(red: 254.0/255.0, green: 224.0/255.0, blue: 139.0/255.0, alpha: 1.0),
            UIColor(red: 252.0/255.0, green: 141.0/255.0, blue: 89.0/255.0, alpha: 1.0),
            UIColor(red: 215.0/255.0, green: 48.0/255.0, blue: 39.0/255.0, alpha: 1.0)
        ]
        static let colorblindColors = [
                "#4575b4", "#91bfdb", "#e0f3f8",
                "#fee090", "#fc8d59", "#d73027"
        ]
        static let titles = [
                "Good", "Moderate", "Slightly Elevated",
                "Elevated", "High", "Very High"
        ]
        // ranges measured in ug/m^3
        static let ranges: [Double] = [
            21, 41, 81,
            161, 321
        ]

        static func getIndexFromReading(reading: Double) -> Int {
            if reading < 0 {
                return -1
            }
            var index: Int
            for index = 0; index < ranges.count; index++ {
                if reading < ranges[index] {
                    return index
                }
            }
            return -1
        }

        static func getRangeFromIndex(index: Int) -> String {
            if (index < 0) {
                NSLog("getRangeFromIndex received index < 0.")
                return ""
            } else if index == 0 {
                return "0-\(ranges[0])"
            } else if index == 5 {
                return "\(ranges[4])+"
            } else {
                return "\(ranges[index-1])-\(ranges[index])"
            }
        }
    }

    
    struct AqiReading {
        static let descriptions = [
                "Air quality is considered satisfactory, and air pollution poses little or no risk.",
                "Air quality is acceptable; however, for some pollutants there may be a moderate health concern for a very small number of people. For example, people who are unusually sensitive to ozone may experience respiratory symptoms.",
                "Although general public is not likely to be affected at this AQI range, people with lung disease, older adults and children are at a greater risk from exposure to ozone, whereas persons with heart and lung disease, older adults and children are at greater risk from the presence of particles in the air.",
                "Everyone may begin to experience some adverse health effects, and members of the sensitive groups may experience more serious effects.",
                "This would trigger a health alert signifying that everyone may experience more serious health effects.",
                "This would trigger a health warning of emergency conditions. The entire population is more likely to be affected."
        ]
        static let titles = [
                "Good", "Moderate", "Unhealthy for Sensitive Groups",
                "Unhealthy", "Very Unhealthy", "Hazardous"
        ]
        static let aqiColors = [
            UIColor(red: 163.0/255.0, green: 186.0/255.0, blue: 92.0/255.0, alpha: 1.0),
            UIColor(red: 233.0/255.0, green: 182.0/255.0, blue: 66.0/255.0, alpha: 1.0),
            UIColor(red: 233.0/255.0, green: 140.0/255.0, blue: 55.0/255.0, alpha: 1.0),
            UIColor(red: 226.0/255.0, green: 79.0/255.0, blue: 54.0/255.0, alpha: 1.0),
            UIColor(red: 181.0/255.0, green: 67.0/255.0, blue: 130.0/255.0, alpha: 1.0),
            UIColor(red: 178.0/255.0, green: 38.0/255.0, blue: 81.0/255.0, alpha: 1.0)
        ]
        static let aqiFontColors = [
            UIColor(red: 25.0/255.0, green: 32.0/255.0, blue: 21.0/255.0, alpha: 1.0),
            UIColor(red: 42.0/255.0, green: 30.0/255.0, blue: 17.0/255.0, alpha: 1.0),
            UIColor(red: 38.0/255.0, green: 23.0/255.0, blue: 5.0/255.0, alpha: 1.0),
            UIColor(red: 51.0/255.0, green: 0.0/255.0, blue: 4.0/255.0, alpha: 1.0),
            UIColor(red: 45.0/255.0, green: 13.0/255.0, blue: 24.0/255.0, alpha: 1.0),
            UIColor(red: 40.0/255.0, green: 6.0/255.0, blue: 11.0/255.0, alpha: 1.0)
        ]
        static let aqiGradientColorStart = [
            UIColor(red: 163.0/255.0, green: 186.0/255.0, blue: 92.0/255.0, alpha: 1.0).CGColor,
            UIColor(red: 233.0/255.0, green: 182.0/255.0, blue: 66.0/255.0, alpha: 1.0).CGColor,
            UIColor(red: 233.0/255.0, green: 140.0/255.0, blue: 55.0/255.0, alpha: 1.0).CGColor,
            UIColor(red: 226.0/255.0, green: 79.0/255.0, blue: 54.0/255.0, alpha: 1.0).CGColor,
            UIColor(red: 181.0/255.0, green: 67.0/255.0, blue: 130.0/255.0, alpha: 1.0).CGColor,
            UIColor(red: 178.0/255.0, green: 38.0/255.0, blue: 81.0/255.0, alpha: 1.0).CGColor
        ]
        static let aqiGradientColorEnd = [
            UIColor(red: 122.0/255.0, green: 144.0/255.0, blue: 85.0/255.0, alpha: 1.0).CGColor,
            UIColor(red: 193.0/255.0, green: 143.0/255.0, blue: 53.0/255.0, alpha: 1.0).CGColor,
            UIColor(red: 180.0/255.0, green: 76.0/255.0, blue: 38.0/255.0, alpha: 1.0).CGColor,
            UIColor(red: 173.0/255.0, green: 34.0/255.0, blue: 39.0/255.0, alpha: 1.0).CGColor,
            UIColor(red: 153.0/255.0, green: 42.0/255.0, blue: 104.0/255.0, alpha: 1.0).CGColor,
            UIColor(red: 140.0/255.0, green: 23.0/255.0, blue: 57.0/255.0, alpha: 1.0).CGColor
        ]
        static let ranges: [Double] = [
                50, 100, 150,
                200, 300
        ]

        static func getIndexFromReading(reading: Double) -> Int {
            if reading < 0 {
                return -1;
            }
            var index: Int
            for index = 0; index < ranges.count; index++ {
                if reading < ranges[index] {
                    return index
                }
            }
            return -1
        }

        static func getRangeFromIndex(index: Int) -> String {
            if (index < 0) {
                NSLog("getRangeFromIndex received index < 0.")
                return ""
            } else if index == 0 {
                return "0-\(ranges[0])"
            } else if index == 5 {
                return "\(ranges[4])+"
            } else {
                return "\(ranges[index-1])-\(ranges[index])"
            }
        }
    }
    
}
