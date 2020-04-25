import 'dart:math';

extension Precision on num {
  num toPrecision(int fractionDigits) {
    num mod = pow(10, fractionDigits.toDouble());
    return ((this * mod).round().toDouble() / mod);
  }
}

/// this provides the distance given a rssi value
/// Note: the txpower value is an assumption
num getDistanceByRSSI (var RSSI ) {
  const txPower = 100;
  return pow(10,((-69 - (RSSI))/txPower)).toPrecision(3);
}