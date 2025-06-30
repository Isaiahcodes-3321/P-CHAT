// post service
String autBaseUrl = 'https://chatpdf-9ih9.onrender.com';
String registerEndpoint = '$autBaseUrl/api/v1/auth/signup';
String verifyOTPEndpoint = '$autBaseUrl/api/v1/auth/verify-OTP';
String resendVerifyEmailEndpoint =
    '$autBaseUrl/api/v1/auth/resend-verification-email';
String loginEndpoint = '$autBaseUrl/api/v1/auth/login';
String forgotPasswordEndpoint = '$autBaseUrl/api/v1/auth/forgot-password';
String refreshTokenEndpoint = '$autBaseUrl/api/v1/auth/refresh-token';
String uploadPdfEndpoint = '$autBaseUrl/api/v1/chats/upload';

//Delete endpoint
String deleteEndpoint = '$autBaseUrl/api/v1/chats/';

// path service
String resetPasswordEndpoint = '$autBaseUrl/api/v1/auth/reset-password';

//chat endpoint
String chatWebsocketBaseUrl = 'ws://chatpdf-9ih9.onrender.com/api/v1/chats/ws/';
