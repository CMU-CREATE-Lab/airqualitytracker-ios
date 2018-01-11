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
    
    static let APP_VERSION_NUMBER = "3.1.0"
    
    static let USES_BACKGROUND_SERVICES = true
    
    static let DEFAULT_ADDRESS_PM25_READABLE_VALUE_TYPE = ReadableValueType.nowcast
    
    static let DEFAULT_ADDRESS_OZONE_READABLE_VALUE_TYPE = ReadableValueType.nowcast
    
    static let DEFAULT_SETTINGS: [String:AnyObject] = [
        SettingsKeys.appUsesLocation: true as AnyObject,
        SettingsKeys.userLoggedIn: false as AnyObject,
        SettingsKeys.username: "" as AnyObject,
        SettingsKeys.userId: -1 as AnyObject,
        SettingsKeys.expiresAt:0 as AnyObject,
        SettingsKeys.accessToken: "" as AnyObject,
        SettingsKeys.refreshToken: "" as AnyObject,
        SettingsKeys.blacklistedDevices: [] as AnyObject,
        SettingsKeys.addressLastPosition: 1 as AnyObject,
        SettingsKeys.speckLastPosition: 1 as AnyObject
    ]
    
    // particulate matter channel names
    static let channelNamesPm = [
            "pm2_5", "PM2_5", "pm2_5_1hr",
            "pm2_5_24hr", "PM25B_UG_M3", "PM25_UG_M3",
            "particle_concentration"
    ]
    
    // ozone channel names
    static let channelNamesOzone = [
            "Ozone", "OZONE", "OZONE2_PPM",
            "Ozone_O3", "OZONE_PPM"
    ]
    
    // ozone channel names that use PPB instead of PPM
    static let ppbOzoneNames = [
            "Ozone", "OZONE", "Ozone_O3"
    ]
    
    // humidity channel names (speck only for now)
    static let channelNamesHumidity = [
            "humidity"
    ]
    
    // humidity channel names (speck only for now)
    static let channelNamesTemperature = [
            "temperature"
    ]
    
    // Large particle channel names (dylos)
    static let channelNamesLargeParticles = [
            "Large"
    ]
    
    // Small particle channel names (dylos)
    static let channelNamesSmallParticles = [
            "Small"
    ]

    static let READINGS_MAX_TIME_RANGE: Double = 86400 // 24 hours
    
    static let SPECKS_MAX_TIME_RANGE: Double = 1800  // 30 minutes
    
    static let TWENTY_FOUR_HOURS: Int = 86400
    
    static let ESDR_TOKEN_TIME_TO_UPDATE_ON_REFRESH: Int = TWENTY_FOUR_HOURS
    
    // controls whether or not the code will perform esdr token refresh requests
    static let REFRESHES_ESDR_TOKEN = true
    
    // determines what value we want to iterate over to determine number of dirty days
    static let DIRTY_DAYS_VALUE_TYPE = DayFeedValue.DaysValueType.max
    
    // any day exceeding this AQI value is defined as dirty
    static let DIRTY_DAYS_AQI_THRESHOLD = 50.0
    
    struct ManualOverrides {
        // strongly encouraged to also set REFRESHES_ESDR_TOKEN = false when using this option
        static let MANUAL_ESDR_LOGIN = false;
        static let username = "";
        static let accessToken = "";
        static let refreshToken = "";
        static let userId = 0;
    }
    
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
        static let PARTICLES_PER_CUBIC_FOOT = "p/ft³"
        static let PARTS_PER_MILLION = "ppm";
        static let PARTS_PER_BILLION = "ppb";
        static let AQI = "AQI";
        static let RANGE_MICROGRAMS_PER_CUBIC_METER = "µg/m³    /500";
        static let RANGE_PARTICLES_PER_CUBIC_FOOT = "particles/ft³    /3000";
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
        "HONEYBEE DEVICES",
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
        static let DEFAULT_ADDRESS_DESCRIPTION = "The current AQI for this region is unavailable.";
        static let DEFAULT_DEVICE_DESCRIPTION = "The current value for this device is unavailable."
    }
    
}
