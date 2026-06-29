import '../entities/ride.dart';

abstract class RideRepository {
  Future<List<Ride>> listPending();
  Future<List<Ride>> listByDriver(String driverId);
  Future<Ride> getById(String id);
  Future<Ride> updateStatus(String id, RideStatus status, {String? driverId});
}
