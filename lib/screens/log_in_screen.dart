import 'package:flutter/material.dart';

class LogInScreen extends StatefulWidget {
	const LogInScreen({super.key});

	@override
	State<LogInScreen> createState() => _LogInScreenState();
}

class _LogInScreenState extends State<LogInScreen> {
	final _formKey = GlobalKey<FormState>();
	final _emailController = TextEditingController();
	final _passwordController = TextEditingController();
	bool _obscurePassword = true;
	bool _rememberMe = true;

	static const brand = Color(0xFF493252);
	static const accent = Color(0xFFF2B880);
	static const background = Color(0xFFF7F4F8);
	static const muted = Color(0xFF8E8792);

	@override
	void dispose() {
		_emailController.dispose();
		_passwordController.dispose();
		super.dispose();
	}

	void _submit() {
		if (!(_formKey.currentState?.validate() ?? false)) return;
		ScaffoldMessenger.of(context).showSnackBar(
			const SnackBar(
				content: Text('تم التحقق من البيانات بنجاح'),
				backgroundColor: brand,
			),
		);
	}

	@override
	Widget build(BuildContext context) {
		return Directionality(
			textDirection: TextDirection.rtl,
			child: Scaffold(
				backgroundColor: background,
				body: SafeArea(
					child: LayoutBuilder(
						builder: (context, constraints) => SingleChildScrollView(
							child: ConstrainedBox(
								constraints: BoxConstraints(minHeight: constraints.maxHeight),
								child: Column(
									children: [
										_WelcomeHeader(compact: constraints.maxHeight < 720),
										_LoginForm(
											formKey: _formKey,
											emailController: _emailController,
											passwordController: _passwordController,
											obscurePassword: _obscurePassword,
											rememberMe: _rememberMe,
											onTogglePassword: () => setState(() {
												_obscurePassword = !_obscurePassword;
											}),
											onRememberChanged: (value) => setState(() {
												_rememberMe = value ?? false;
											}),
											onSubmit: _submit,
										),
									],
								),
							),
						),
					),
				),
			),
		);
	}
}

class _WelcomeHeader extends StatelessWidget {
	const _WelcomeHeader({required this.compact});

	final bool compact;

	@override
	Widget build(BuildContext context) {
		return Container(
			width: double.infinity,
			padding: EdgeInsets.fromLTRB(28, compact ? 22 : 34, 28, compact ? 74 : 94),
			decoration: const BoxDecoration(
				color: _LogInScreenState.brand,
				borderRadius: BorderRadius.vertical(bottom: Radius.circular(44)),
			),
			child: Stack(
				children: [
					Positioned(
						top: -55,
						left: -55,
						child: Transform.rotate(
							angle: -0.25,
							child: Container(width: 210, height: 270, color: Color(0xFF604663)),
						),
					),
					Column(
						crossAxisAlignment: CrossAxisAlignment.end,
						children: [
							Row(
								mainAxisAlignment: MainAxisAlignment.spaceBetween,
								children: [
									const Text(
										'⋮⋮⋮',
										textDirection: TextDirection.ltr,
										style: TextStyle(color: Colors.white, fontSize: 21, fontWeight: FontWeight.bold),
									),
									Row(
										children: [
											const Text(
												'Vector',
												textDirection: TextDirection.ltr,
												style: TextStyle(color: Colors.white, fontSize: 22, fontWeight: FontWeight.w700),
											),
											const SizedBox(width: 12),
											Container(
												width: 62,
												height: 62,
												padding: const EdgeInsets.all(10),
												decoration: BoxDecoration(color: _LogInScreenState.accent, borderRadius: BorderRadius.circular(17)),
												child: Image.asset('assets/logo/vector-app-icon-1024.png'),
											),
										],
									),
								],
							),
							const SizedBox(height: 38),
							const Text('أهلًا بعودتك', style: TextStyle(color: Colors.white, fontSize: 35, fontWeight: FontWeight.w700)),
							const SizedBox(height: 10),
							const Text('سجّل دخولك وشوف الفُرق اللي تنتظر مهاراتك.', style: TextStyle(color: Color(0xFFD5CBD7), fontSize: 16)),
							const SizedBox(height: 28),
							Container(
								padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
								decoration: BoxDecoration(
									color: Colors.white.withValues(alpha: 0.1),
									borderRadius: BorderRadius.circular(30),
									border: Border.all(color: Colors.white.withValues(alpha: 0.18)),
								),
								child: const Row(
									mainAxisSize: MainAxisSize.min,
									children: [
										Text('▲', style: TextStyle(color: _LogInScreenState.accent, fontSize: 13)),
										SizedBox(width: 9),
										Text('٣ دعوات جديدة تنتظرك', style: TextStyle(color: Color(0xFFE0D7E2), fontSize: 15)),
									],
								),
							),
						],
					),
				],
			),
		);
	}
}

class _LoginForm extends StatelessWidget {
	const _LoginForm({
		required this.formKey,
		required this.emailController,
		required this.passwordController,
		required this.obscurePassword,
		required this.rememberMe,
		required this.onTogglePassword,
		required this.onRememberChanged,
		required this.onSubmit,
	});

	final GlobalKey<FormState> formKey;
	final TextEditingController emailController;
	final TextEditingController passwordController;
	final bool obscurePassword;
	final bool rememberMe;
	final VoidCallback onTogglePassword;
	final ValueChanged<bool?> onRememberChanged;
	final VoidCallback onSubmit;

	InputDecoration _decoration(String label) => InputDecoration(
				labelText: label,
				labelStyle: const TextStyle(color: _LogInScreenState.muted, fontSize: 14),
				filled: true,
				fillColor: Colors.white,
				contentPadding: const EdgeInsets.symmetric(horizontal: 22, vertical: 18),
				border: OutlineInputBorder(borderRadius: BorderRadius.circular(18), borderSide: BorderSide.none),
				enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(18), borderSide: BorderSide.none),
				focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(18), borderSide: const BorderSide(color: _LogInScreenState.brand, width: 1.5)),
				errorBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(18), borderSide: const BorderSide(color: Colors.redAccent)),
			);

	@override
	Widget build(BuildContext context) {
		return Transform.translate(
			offset: const Offset(0, -38),
			child: Container(
				width: double.infinity,
				padding: const EdgeInsets.fromLTRB(28, 42, 28, 20),
				decoration: const BoxDecoration(
					color: _LogInScreenState.background,
					borderRadius: BorderRadius.vertical(top: Radius.circular(46)),
				),
				child: Form(
					key: formKey,
					child: Column(
						children: [
							TextFormField(
								controller: emailController,
								keyboardType: TextInputType.emailAddress,
								textDirection: TextDirection.ltr,
								textAlign: TextAlign.right,
								decoration: _decoration('البريد الإلكتروني'),
								validator: (value) {
									if (value == null || value.trim().isEmpty) return 'أدخل بريدك الإلكتروني';
									if (!value.contains('@')) return 'أدخل بريدًا إلكترونيًا صحيحًا';
									return null;
								},
							),
							const SizedBox(height: 18),
							TextFormField(
								controller: passwordController,
								obscureText: obscurePassword,
								textAlign: TextAlign.right,
								decoration: _decoration('كلمة المرور').copyWith(
									suffixIcon: TextButton(
										onPressed: onTogglePassword,
										child: const Text('إظهار', style: TextStyle(color: _LogInScreenState.brand)),
									),
								),
								validator: (value) => value == null || value.length < 6 ? 'كلمة المرور قصيرة جدًا' : null,
							),
							const SizedBox(height: 10),
							Row(
								mainAxisAlignment: MainAxisAlignment.spaceBetween,
								children: [
									TextButton(onPressed: () {}, child: const Text('نسيت كلمة المرور؟', style: TextStyle(color: _LogInScreenState.brand, fontSize: 14))),
									Row(
										children: [
											const Text('تذكّرني', style: TextStyle(color: _LogInScreenState.muted, fontSize: 14)),
											Checkbox(value: rememberMe, onChanged: onRememberChanged, activeColor: _LogInScreenState.brand),
										],
									),
								],
							),
							const SizedBox(height: 12),
							SizedBox(
								width: double.infinity,
								height: 62,
								child: ElevatedButton.icon(
									onPressed: onSubmit,
									icon: const Text('◀', style: TextStyle(color: _LogInScreenState.accent, fontSize: 17)),
									label: const Text('تسجيل الدخول', style: TextStyle(fontSize: 23, fontWeight: FontWeight.w700)),
									style: ElevatedButton.styleFrom(
										backgroundColor: _LogInScreenState.brand,
										foregroundColor: Colors.white,
										shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
									),
								),
							),
							const SizedBox(height: 32),
							Row(
								children: [
									const Expanded(child: Divider(color: Color(0xFFE3DEE4))),
									const Padding(
										padding: EdgeInsets.symmetric(horizontal: 16),
										child: Text('أو المتابعة عبر', style: TextStyle(color: _LogInScreenState.muted, fontSize: 14)),
									),
									const Expanded(child: Divider(color: Color(0xFFE3DEE4))),
								],
							),
							const SizedBox(height: 30),
							const Text('الدخول متاح عبر البريد الإلكتروني فقط', style: TextStyle(color: _LogInScreenState.muted, fontSize: 14)),
							const SizedBox(height: 42),
							Row(
								mainAxisAlignment: MainAxisAlignment.center,
								children: [
									TextButton(onPressed: () {}, child: const Text('سجّل الآن', style: TextStyle(color: _LogInScreenState.brand, fontWeight: FontWeight.w700))),
									const Text('ما عندك حساب؟ ', style: TextStyle(color: _LogInScreenState.muted, fontSize: 15)),
								],
							),
							Container(width: 220, height: 5, decoration: BoxDecoration(color: const Color(0xFFC8C4C9), borderRadius: BorderRadius.circular(4))),
						],
					),
				),
			),
		);
	}
}
