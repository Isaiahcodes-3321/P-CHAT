// post service
String baseUrl = 'https://chatpdf-9ih9.onrender.com';
String registerEndpoint = '$baseUrl/api/v1/auth/signup';
String verifyOTPEndpoint = '$baseUrl/api/v1/auth/verify-OTP';
String resendVerifyEmailEndpoint =
    '$baseUrl/api/v1/auth/resend-verification-email';
String loginEndpoint = '$baseUrl/api/v1/auth/login';
String forgotPasswordEndpoint = '$baseUrl/api/v1/auth/forgot-password';
String refreshTokenEndpoint = '$baseUrl/api/v1/auth/refresh-token';
String uploadPdfEndpoint = '$baseUrl/api/v1/chat/upload';

// path service
String resetPasswordEndpoint = '$baseUrl/api/v1/auth/reset-password';

//chat endpoint
String chatEndpoint = 'ws://chatpdf-9ih9.onrender.com/api/v1/chat/ws/';
