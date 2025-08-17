class SubscriptionEntity {
  final String email;
  final String? city;    
  final bool confirmed;   
  const SubscriptionEntity({required this.email, this.city, this.confirmed = false});
}