class AuthConfig {
  const AuthConfig({
    required this.baseUrl,
    this.useMock = false,
    this.loginPath = '/auth/login',
    this.signupPath = '/auth/register',
    this.forgotPasswordPath = '/auth/forgot-password',
    this.otpVerifyPath = '/auth/otp/verify',
    this.otpResendPath = '/auth/otp/resend',
  });

  final String baseUrl;
  final bool useMock;
  final String loginPath;
  final String signupPath;
  final String forgotPasswordPath;
  final String otpVerifyPath;
  final String otpResendPath;

  String get loginUrl {
    final normalizedBase = baseUrl.endsWith('/')
        ? baseUrl.substring(0, baseUrl.length - 1)
        : baseUrl;
    final normalizedPath = loginPath.startsWith('/') ? loginPath : '/$loginPath';
    return '$normalizedBase$normalizedPath';
  }

  String get signupUrl {
    final normalizedBase = baseUrl.endsWith('/')
        ? baseUrl.substring(0, baseUrl.length - 1)
        : baseUrl;
    final normalizedPath =
        signupPath.startsWith('/') ? signupPath : '/$signupPath';
    return '$normalizedBase$normalizedPath';
  }

  String get forgotPasswordUrl {
    final normalizedBase = baseUrl.endsWith('/')
        ? baseUrl.substring(0, baseUrl.length - 1)
        : baseUrl;
    final normalizedPath = forgotPasswordPath.startsWith('/')
        ? forgotPasswordPath
        : '/$forgotPasswordPath';
    return '$normalizedBase$normalizedPath';
  }

  String get otpVerifyUrl {
    final normalizedBase = baseUrl.endsWith('/')
        ? baseUrl.substring(0, baseUrl.length - 1)
        : baseUrl;
    final normalizedPath =
        otpVerifyPath.startsWith('/') ? otpVerifyPath : '/$otpVerifyPath';
    return '$normalizedBase$normalizedPath';
  }

  String get otpResendUrl {
    final normalizedBase = baseUrl.endsWith('/')
        ? baseUrl.substring(0, baseUrl.length - 1)
        : baseUrl;
    final normalizedPath =
        otpResendPath.startsWith('/') ? otpResendPath : '/$otpResendPath';
    return '$normalizedBase$normalizedPath';
  }
}

const authConfig = AuthConfig(
  baseUrl: 'https://smart-bike-rental-backend.onrender.com/api',
  useMock: false,
  loginPath: '/auth/login',
  signupPath: '/auth/register',
  forgotPasswordPath: '/auth/forgot-password',
  otpVerifyPath: '/auth/otp/verify',
  otpResendPath: '/auth/otp/resend',
);
