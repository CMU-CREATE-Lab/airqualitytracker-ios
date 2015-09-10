//
//  MapGeometry.swift
//  AirPrototype
//
//  Created by mtasota on 7/16/15.
//  Copyright (c) 2015 CMU Create Lab. All rights reserved.
//

// AN IMPORTANT NOTE ABOUT CALCULATING DISTANCES ON EARTH
//
// No method is perfect. However, Haversine's Formula is
// better for smaller distances and is therefore the best
// option for computing shorter distances on the Great
// Circle, which is what we are doing in this application
// (as long as your bounding box for points doesn't span
// across half of the Great Circle, AKA Earth). From
// Wikipedia:
//
//     "Although this formula is accurate for most
//     distances on a sphere, it too suffers from
//     rounding errors for the special (and somewhat
//     unusual) case of antipodal points (on opposite
//     ends of the sphere)."
//
// About the Earth's radius constant:
//
//     "the 'Earth radius' R varies from 6356.752 km
//     at the poles to 6378.137 km at the equator.
//     More importantly, the radius of curvature of
//     a north-south line on the earth's surface is
//     1% greater at the poles (≈6399.594 km) than
//     at the equator (≈6335.439 km)— so the haversine
//     formula and law of cosines can't be guaranteed
//     correct to better than 0.5%. More accurate
//     methods that consider the Earth's ellipticity
//     are given by Vincenty's formulae and the other
//     formulas in the geographical distance article."

import Foundation

class MapGeometry {
    // implementation of the haversine function using sine
    static func haversine(theta: Double) -> Double {
        let temp = sin(theta / 2.0)
        return temp * temp
    }


    // the inverse of the haversine function
    // ASSERT: value is in range [0,1]
    static func archaversine(value: Double) -> Double {
        return 2 * asin( sqrt(value) )
    }


    // calculates distance between two points on a Great Sphere
    static func getDistance(from: Location, to: Location) -> Double {
        // convert units from degrees to radians
        let p1 = from.latitude * MATH_PI / 180.0
        let p2 = to.latitude * MATH_PI / 180.0
        let l1 = from.longitude * MATH_PI / 180.0
        let l2 = to.longitude * MATH_PI / 180.0

        // Taken from the haversine formula: hsin(d/r) = hsine(p2-p1) + cos(p1)*cos(p2)*hsin(l2-l1)
        // where hsin(t) = sin^2(t/2)
        var result = haversine(p2-p1) + cos(p2)*cos(p1)*haversine(l2-l1)
        result = Constants.MapGeometry.RADIUS_EARTH * archaversine(result)
        return result
    }


    static func getDistanceFromFeedToAddress(simpleAddress: SimpleAddress, feed: Feed) -> Double {
        return getDistance(simpleAddress.location, to: feed.location)
    }


    static func getClosestFeedToAddress(simpleAddress: SimpleAddress, feeds: Array<Feed>) -> Feed? {
        var closestFeed: Feed? = nil
        var distance: Double? = nil

        for feed in feeds {
            if (closestFeed == nil) {
                distance = getDistanceFromFeedToAddress(simpleAddress, feed: feed);
                closestFeed = feed;
            } else {
                let temp = getDistanceFromFeedToAddress(simpleAddress, feed: feed);
                if (temp < distance) {
                    distance = temp;
                    closestFeed = feed;
                }
                if (temp < 0) {
                    NSLog("Distance from address=\(simpleAddress._id!) to feed=\(feed.feed_id) has negative distance \(temp)")
                }
            }
        }
        if (closestFeed == nil) {
            NSLog("getClosestFeedToAddress returning null.")
        }
        else {
            NSLog("FEED=\(closestFeed?.feed_id) has closest distance=\(distance)")
        }
        return closestFeed
    }
    
}