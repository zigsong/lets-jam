import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:lets_jam/controllers/session_controller.dart';
import 'package:lets_jam/utils/color_seed_enum.dart';
import 'package:lets_jam/utils/custom_snackbar.dart';
import 'package:lets_jam/widgets/text_input.dart';
import 'package:lets_jam/widgets/wide_button.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class EmailAuthScreen extends StatefulWidget {
  const EmailAuthScreen({super.key});

  @override
  State<EmailAuthScreen> createState() => _EmailAuthScreenState();
}

class _EmailAuthScreenState extends State<EmailAuthScreen> {
  final SessionController sessionController = Get.find<SessionController>();

  bool _isSignUpMode = true;
  bool _isLoading = false;

  String _email = '';
  String _password = '';
  String _passwordConfirm = '';

  bool _obscurePassword = true;
  bool _obscurePasswordConfirm = true;

  String? _emailError;
  String? _passwordError;
  String? _passwordConfirmError;

  bool _validate() {
    bool hasError = false;
    setState(() {
      _emailError = null;
      _passwordError = null;
      _passwordConfirmError = null;
    });

    final emailRegex = RegExp(r'^[^@]+@[^@]+\.[^@]+');
    if (_email.trim().isEmpty || !emailRegex.hasMatch(_email.trim())) {
      _emailError = '올바른 이메일 형식이 아니에요';
      hasError = true;
    }
    if (_password.length < 6) {
      _passwordError = '비밀번호는 6자 이상이어야 해요';
      hasError = true;
    }
    if (_isSignUpMode && _password != _passwordConfirm) {
      _passwordConfirmError = '비밀번호가 일치하지 않아요';
      hasError = true;
    }

    if (hasError) setState(() {});
    return !hasError;
  }

  Future<void> _submit() async {
    if (!_validate()) return;

    setState(() => _isLoading = true);
    try {
      if (_isSignUpMode) {
        await sessionController.signUpWithEmail(_email.trim(), _password);
      } else {
        await sessionController.signInWithEmail(_email.trim(), _password);
      }
      if (mounted) {
        Navigator.popUntil(context, (route) => route.isFirst);
      }
    } on AuthException catch (e) {
      if (!mounted) return;
      String message;
      if (e.message.contains('already registered') ||
          e.message.contains('User already registered')) {
        message = '이미 사용 중인 이메일이에요';
      } else if (e.message.contains('Invalid login credentials') ||
          e.message.contains('invalid_credentials')) {
        message = '이메일 또는 비밀번호를 확인해주세요';
      } else {
        message = '오류가 발생했어요. 잠시 후 다시 시도해주세요';
      }
      ScaffoldMessenger.of(context).showSnackBar(customSnackbar(message));
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context)
          .showSnackBar(customSnackbar('오류가 발생했어요. 잠시 후 다시 시도해주세요'));
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  void _switchMode() {
    setState(() {
      _isSignUpMode = !_isSignUpMode;
      _emailError = null;
      _passwordError = null;
      _passwordConfirmError = null;
    });
  }

  Widget _buildPasswordField({
    required String placeholder,
    required bool obscure,
    required VoidCallback onToggleObscure,
    required void Function(String) onChanged,
    String? errorText,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        TextFormField(
          obscureText: obscure,
          style: const TextStyle(fontSize: 13),
          decoration: InputDecoration(
            hintText: placeholder,
            hintStyle: TextStyle(color: ColorSeed.meticulousGrayMedium.color),
            focusedBorder: OutlineInputBorder(
              borderSide: BorderSide(
                  color: ColorSeed.meticulousGrayLight.color, width: 1),
              borderRadius: BorderRadius.circular(6),
            ),
            enabledBorder: OutlineInputBorder(
              borderSide: BorderSide(
                  color: ColorSeed.meticulousGrayLight.color, width: 1),
              borderRadius: BorderRadius.circular(6),
            ),
            contentPadding:
                const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
            suffixIcon: IconButton(
              icon: Icon(
                obscure
                    ? Icons.visibility_off_outlined
                    : Icons.visibility_outlined,
                size: 18,
                color: ColorSeed.meticulousGrayMedium.color,
              ),
              onPressed: onToggleObscure,
            ),
          ),
          cursorColor: ColorSeed.meticulousGrayLight.color,
          onChanged: onChanged,
          onTapOutside: (_) => FocusManager.instance.primaryFocus?.unfocus(),
        ),
        if (errorText != null)
          Padding(
            padding: const EdgeInsets.only(top: 6, left: 4),
            child: Row(
              children: [
                SizedBox(
                  width: 13.5,
                  height: 13.5,
                  child: Image.asset('assets/icons/info.png'),
                ),
                const SizedBox(width: 7),
                Text(
                  errorText,
                  style: const TextStyle(color: Colors.red, fontSize: 12),
                ),
              ],
            ),
          ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        iconTheme: IconThemeData(color: ColorSeed.boldOrangeStrong.color),
        title: Text(
          _isSignUpMode ? '회원가입' : '로그인',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w500,
            color: ColorSeed.boldOrangeStrong.color,
          ),
        ),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              TextInput(
                label: '이메일',
                placeholder: 'example@email.com',
                errorText: _emailError,
                keyboardType: TextInputType.emailAddress,
                onChanged: (v) => setState(() {
                  _email = v;
                  _emailError = null;
                }),
              ),
              const SizedBox(height: 20),
              _buildPasswordField(
                placeholder: '비밀번호 (6자 이상)',
                obscure: _obscurePassword,
                onToggleObscure: () =>
                    setState(() => _obscurePassword = !_obscurePassword),
                onChanged: (v) => setState(() {
                  _password = v;
                  _passwordError = null;
                }),
                errorText: _passwordError,
              ),
              if (_isSignUpMode) ...[
                const SizedBox(height: 20),
                _buildPasswordField(
                  placeholder: '비밀번호 확인',
                  obscure: _obscurePasswordConfirm,
                  onToggleObscure: () => setState(
                      () => _obscurePasswordConfirm = !_obscurePasswordConfirm),
                  onChanged: (v) => setState(() {
                    _passwordConfirm = v;
                    _passwordConfirmError = null;
                  }),
                  errorText: _passwordConfirmError,
                ),
              ],
              const SizedBox(height: 32),
              WideButton(
                text: _isSignUpMode ? '회원가입' : '로그인',
                onPressed: _isLoading ? null : _submit,
                disabled: _isLoading,
              ),
              const SizedBox(height: 24),
              Center(
                child: TextButton(
                  onPressed: _switchMode,
                  child: RichText(
                    text: TextSpan(
                      style: TextStyle(
                        fontSize: 14,
                        color: ColorSeed.meticulousGrayMedium.color,
                      ),
                      children: [
                        TextSpan(
                          text: _isSignUpMode
                              ? '이미 계정이 있나요? '
                              : '아직 계정이 없나요? ',
                        ),
                        TextSpan(
                          text: _isSignUpMode ? '로그인' : '회원가입',
                          style: TextStyle(
                            fontWeight: FontWeight.w700,
                            color: ColorSeed.organizedBlackMedium.color,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
