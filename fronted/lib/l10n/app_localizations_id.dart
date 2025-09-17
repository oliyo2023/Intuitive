// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Indonesian (`id`).
class AppLocalizationsId extends AppLocalizations {
  AppLocalizationsId([String locale = 'id']) : super(locale);

  @override
  String get appName => 'Artisan AI';

  @override
  String get authTitle => 'Autentikasi';

  @override
  String get emailLabel => 'Email';

  @override
  String get passwordLabel => 'Kata Sandi';

  @override
  String get emailHint => 'Silakan masukkan email Anda';

  @override
  String get passwordHint => 'Silakan masukkan kata sandi Anda';

  @override
  String get invalidEmail => 'Format email tidak valid';

  @override
  String get passwordTooShort => 'Kata sandi minimal 6 karakter';

  @override
  String get loginButton => 'Masuk';

  @override
  String get registerButton => 'Daftar';

  @override
  String get noAccount => 'Belum punya akun? Daftar';

  @override
  String get hasAccount => 'Sudah punya akun? Masuk';

  @override
  String get authFailed => 'Autentikasi Gagal';

  @override
  String get homeTitle => 'Artisan AI';

  @override
  String get logoutButton => 'Keluar';

  @override
  String get credits => 'Kredit';

  @override
  String get generateImage => 'Hasilkan Gambar';

  @override
  String get promptHint =>
      'Jelaskan gambar yang ingin Anda hasilkan...\\nContoh: \"Kucing lucu duduk di atas pelangi\"';

  @override
  String get emptyStateTitle => 'Mulai buat gambar AI Anda';

  @override
  String get emptyStateSubtitle =>
      'Masukkan deskripsi agar AI menghasilkan gambar unik untuk Anda';

  @override
  String get insufficientCreditsTitle => 'Kredit Habis';

  @override
  String get insufficientCreditsContent =>
      'Kredit pembuatan gambar Anda telah habis. Silakan beli paket untuk melanjutkan.';

  @override
  String get cancel => 'Batal';

  @override
  String get rechargeNow => 'Isi Ulang Sekarang';

  @override
  String get subscriptionTitle => 'Langganan';
}
