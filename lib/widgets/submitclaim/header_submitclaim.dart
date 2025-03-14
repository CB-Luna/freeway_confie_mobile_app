import 'package:flutter/material.dart';

class SubmitClaimHeader extends StatelessWidget {
  const SubmitClaimHeader({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 16),
      decoration: const BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Color(0x0A111111),
            offset: Offset(0, 4),
            blurRadius: 8,
          ),
        ],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          GestureDetector(
            onTap: () => Navigator.pop(context),
            child: const Row(
              children: [
                Icon(
                  Icons.arrow_back_ios,
                  color: Color(0xFF0047BB),
                  size: 20,
                ),
                SizedBox(width: 4),
                Text(
                  'Back',
                  style: TextStyle(
                    color: Color(0xFF0047BB),
                    fontSize: 16,
                    fontFamily: 'Open Sans',
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),
          Image.asset(
            'assets/auth/freeway_logo.png',
            height: 40,
          ),
          Row(
            children: [
              const Icon(
                Icons.notifications_none,
                color: Color(0xFF0047BB),
                size: 24,
              ),
              const SizedBox(width: 16),
              GestureDetector(
                onTap: () {
                  Navigator.pushNamed(context, '/profile');
                },
                child: const CircleAvatar(
                  radius: 16,
                  backgroundImage:
                      AssetImage('assets/profile/human_avatar.png'),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
