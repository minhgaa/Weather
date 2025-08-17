import "package:weather_app/domain/entities/subscription_entity.dart";

abstract class SubscriptionRepo {
  Future<void> subscribe (SubscriptionEntity sub);
  Future<void> unsubscribe (String email);
}