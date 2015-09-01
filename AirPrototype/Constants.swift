//
//  Constants.swift
//  AirPrototype
//
//  Created by mtasota on 7/13/15.
//  Copyright (c) 2015 CMU Create Lab. All rights reserved.
//

import Foundation

let MATH_PI = 3.14159265358979

class Constants {
    struct CellReuseIdentifiers {
        static let ADDRESS_LIST = "reuseAddressList"
        static let ADDRESS_SEARCH = "reuseAddressSearch"
    }

    struct Esdr {
        static let API_URL = "https://esdr.cmucreatelab.org";
        static let GRANT_TYPE_TOKEN = "password";
        static let GRANT_TYPE_REFRESH = "refresh_token";
        // TODO placeholder for actual Client information (don't push to git)
        static let CLIENT_ID = "client_id";
        static let CLIENT_SECRET = "this should never work";
    }


    struct MapGeometry {
        // Distance from central point, in kilometers (box dimension will be 2x larger)
        static let BOUNDBOX_HEIGHT = 20.0;
        // Distance from central point, in kilometers (box dimension will be 2x larger)
        static let BOUNDBOX_LENGTH = 20.0;
        // radius of Earth (in kilometers)
        static let RADIUS_EARTH = 6371.0;
        // ASSERT these values will be less than 90.0
        static let BOUNDBOX_LAT = BOUNDBOX_HEIGHT / ( RADIUS_EARTH * 2 * MATH_PI ) * 360.0;
        static let BOUNDBOX_LONG = BOUNDBOX_LENGTH / ( RADIUS_EARTH * 2 * MATH_PI ) * 360.0;
    }
}
