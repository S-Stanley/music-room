import geoip from 'geoip-lite';
import geolib from 'geolib';

export const getLocationFromIpAddr = (ip_addr) => {
  try {
    const loc = geoip.lookup(ip_addr);
    if (!loc || !loc.ll || loc.ll.length !== 2){
      throw new Error("Unfound location:", loc);
    }
    return ({
      latitude: loc.ll[0] || null,
      longitude: loc.ll[1] || null,
    })
  } catch (e) {
    console.error(e);
    return ({
      latitude: null,
      longitude: null,
    })
  }
};

export const computeDistanceBetweenTwoLocations = (first, second) => {
  return geolib.getDistance(parseFloat(first), parseFloat(second));
};
