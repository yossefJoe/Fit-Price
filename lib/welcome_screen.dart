import 'package:flutter/material.dart';
import 'package:one_shot/custom_gradient.dart';

import 'assets_manager.dart';
import 'button.dart';
import 'colors_manager.dart';
import 'search_page.dart';

class WelcomeScreen extends StatefulWidget {
  const WelcomeScreen({Key? key}) : super(key: key);

  @override
  State<WelcomeScreen> createState() => _WelcomeScreenState();
}

class _WelcomeScreenState extends State<WelcomeScreen>
    with SingleTickerProviderStateMixin {
  bool showActions = false;

  late AnimationController _controller;
  late Animation<double> _scaleAnim;
  late Animation<double> _fadeAnim;

  @override
  void initState() {
    super.initState();

    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 500),
    );

    _scaleAnim = Tween<double>(
      begin: 1,
      end: 0,
    ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeIn));

    _fadeAnim = Tween<double>(
      begin: 1,
      end: 0,
    ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeOut));
  }

  void onCartPressed() async {
    await _controller.forward();
    setState(() => showActions = true);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black26,
      body: CustomGradient(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            showActions
                ? AnimatedSwitcher(
                  duration: const Duration(milliseconds: 500),
                  child:
                      showActions
                          ? Row(
                            mainAxisAlignment: MainAxisAlignment.spaceAround,
                            children: [
                              TypeButton(text: 'Search by Image'),
                              TypeButton(text: 'Search by Text'),
                            ],
                          )
                          : const SizedBox(),
                )
                : SizedBox.shrink(),
            Container(
              height: MediaQuery.of(context).size.height * 0.5,
              width: MediaQuery.of(context).size.width,
              decoration: BoxDecoration(
                image: DecorationImage(
                  image: AssetImage(
                    showActions
                        ? AssetsManager.chooseImage
                        : AssetsManager.welcome,
                  ),
                  fit: BoxFit.cover,
                ),
              ),
            ),

            const SizedBox(height: 40),

            /// 🛒 Cart Button Animation
            if (!showActions)
              FadeTransition(
                opacity: _fadeAnim,
                child: ScaleTransition(
                  scale: _scaleAnim,
                  child: GestureDetector(
                    onTap: onCartPressed,
                    child: Container(
                      padding: const EdgeInsets.all(20),
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: ColorsManager.primary,
                        boxShadow: [
                          BoxShadow(
                            color: ColorsManager.primary.withOpacity(0.4),
                            blurRadius: 20,
                          ),
                        ],
                      ),
                      child: const Icon(
                        Icons.shopping_cart_outlined,
                        color: Colors.white,
                        size: 32,
                      ),
                    ),
                  ),
                ),
              ),

            /// 🔘 Buttons appear
          ],
        ),
      ),
    );
  }
}
