abstract final class AssetPaths {
  AssetPaths._();

  static const String _image = 'assets/images';
  static const String _icon = 'assets/icons';
  static const String _font = 'assets/fonts';
  static const String _lottie = 'assets/animations';

  static const String logo = '$_image/logo.png';
  static const String logoWhite = '$_image/logo_white.png';
  static const String emptyState = '$_image/empty_state.svg';
  static const String errorState = '$_image/error_state.svg';
  static const String noInternet = '$_image/no_internet.svg';

  static const String appIcon = '$_icon/app_icon.png';
  static const String notification = '$_icon/notification.svg';
  static const String search = '$_icon/search.svg';

  static const String notoSansBengali = '$_font/NotoSansBengali.ttf';

  static const String loadingAnimation = '$_lottie/loading.json';
  static const String successAnimation = '$_lottie/success.json';
}
