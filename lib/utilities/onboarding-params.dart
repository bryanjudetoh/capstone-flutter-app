class OnboardingParams {
  final String? fbUserId;
  final String? fbAccessToken;
  final String? firstName;
  final String? lastName;
  final String email;
  final String? imageUrl;
  final bool isFbLogin;

  OnboardingParams(
      {this.fbUserId,
      this.fbAccessToken,
      this.firstName,
      this.lastName,
      this.imageUrl,
      required this.email,
      required this.isFbLogin
      });
}