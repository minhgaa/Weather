import 'package:weather_app/domain/entities/subscription_entity.dart';
import 'package:weather_app/domain/repositories/subcripstion_repo.dart';

class Subscribe {
  final SubscriptionRepo repo;
  Subscribe(this.repo);
  Future<void> call(SubscriptionEntity sub) => repo.subscribe(sub);
}

class Unsubscribe {
  final SubscriptionRepo repo;
  Unsubscribe(this.repo);
  Future<void> call(String email) => repo.unsubscribe(email);
}