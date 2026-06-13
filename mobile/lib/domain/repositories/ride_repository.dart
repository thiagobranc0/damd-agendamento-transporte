import '../entities/ride.dart';

abstract class RideRepository {
  Future<Ride> create({
    required String userId,
    required String origin,
    required String destination,
    required DateTime scheduledAt,
  });

  Future<List<Ride>> listByUser(String userId);

  Future<Ride> getById(String id);
}
