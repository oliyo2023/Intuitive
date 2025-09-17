// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Chinese (`zh`).
class AppLocalizationsZh extends AppLocalizations {
  AppLocalizationsZh([String locale = 'zh']) : super(locale);

  @override
  String get appName => '创图神器';

  @override
  String get authTitle => '认证';

  @override
  String get emailLabel => '邮箱';

  @override
  String get passwordLabel => '密码';

  @override
  String get emailHint => '请输入邮箱';

  @override
  String get passwordHint => '请输入密码';

  @override
  String get invalidEmail => '邮箱格式无效';

  @override
  String get passwordTooShort => '密码至少6位';

  @override
  String get loginButton => '登录';

  @override
  String get registerButton => '注册';

  @override
  String get noAccount => '没有账户？注册';

  @override
  String get hasAccount => '已有账户？登录';

  @override
  String get authFailed => '认证失败';

  @override
  String get homeTitle => '创图神器';

  @override
  String get logoutButton => '登出';

  @override
  String get credits => '次数';

  @override
  String get generateImage => '生成图像';

  @override
  String get promptHint => '描述你想要生成的图像...\\n例如: \"一只可爱的小猫坐在彩虹上\"';

  @override
  String get emptyStateTitle => '开始创作你的AI图像';

  @override
  String get emptyStateSubtitle => '输入描述文字，让AI为你生成独特的图像';

  @override
  String get insufficientCreditsTitle => '次数已用完';

  @override
  String get insufficientCreditsContent => '您的图片生成次数已经用完，请购买套餐以继续使用。';

  @override
  String get cancel => '取消';

  @override
  String get rechargeNow => '立即充值';

  @override
  String get subscriptionTitle => '订阅会员';
}
