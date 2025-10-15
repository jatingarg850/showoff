import 'package:flutter/material.dart';

class TermsConditionsScreen
    extends
        StatelessWidget {
  const TermsConditionsScreen({
    super.key,
  });

  @override
  Widget
  build(
    BuildContext context,
  ) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(
            Icons.arrow_back,
            color: Colors.black,
          ),
          onPressed: () => Navigator.pop(
            context,
          ),
        ),
        title: const Text(
          'Terms & Condition',
          style: TextStyle(
            color: Color(
              0xFF8B5CF6,
            ),
            fontSize: 20,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(
          20,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              padding: const EdgeInsets.all(
                16,
              ),
              decoration: BoxDecoration(
                color: const Color(
                  0xFFE9D5FF,
                ),
                borderRadius: BorderRadius.circular(
                  12,
                ),
              ),
              child: Row(
                children: [
                  const Icon(
                    Icons.info_outline,
                    color: Color(
                      0xFF8B5CF6,
                    ),
                    size: 24,
                  ),
                  const SizedBox(
                    width: 12,
                  ),
                  Expanded(
                    child: Text(
                      'Last updated: October 15, 2025',
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.grey[700],
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(
              height: 24,
            ),

            _buildSection(
              '1. Acceptance of Terms',
              'By accessing and using ShowOff.life, you accept and agree to be bound by the terms and provision of this agreement. If you do not agree to abide by the above, please do not use this service.',
            ),

            _buildSection(
              '2. User Accounts',
              'When you create an account with us, you must provide information that is accurate, complete, and current at all times. You are responsible for safeguarding the password and for all activities that occur under your account.',
            ),

            _buildSection(
              '3. Referral Program',
              'Our referral program allows users to earn coins by inviting friends. Referral rewards are subject to our monthly limits and tier system. Abuse of the referral system may result in account suspension.',
            ),

            _buildSection(
              '4. Virtual Currency',
              'Coins earned through our platform are virtual currency with no real-world monetary value. Coins can be used within the app for various features and cannot be exchanged for real money.',
            ),

            _buildSection(
              '5. Content Guidelines',
              'Users are responsible for the content they upload. Content must not be offensive, illegal, or violate intellectual property rights. We reserve the right to remove content that violates our guidelines.',
            ),

            _buildSection(
              '6. Privacy Policy',
              'Your privacy is important to us. Our Privacy Policy explains how we collect, use, and protect your information when you use our service.',
            ),

            _buildSection(
              '7. Prohibited Uses',
              'You may not use our service for any unlawful purpose, to spam, harass other users, or attempt to gain unauthorized access to our systems.',
            ),

            _buildSection(
              '8. Termination',
              'We may terminate or suspend your account immediately, without prior notice, for conduct that we believe violates these Terms of Service.',
            ),

            _buildSection(
              '9. Changes to Terms',
              'We reserve the right to modify these terms at any time. We will notify users of any changes by posting the new Terms of Service on this page.',
            ),

            _buildSection(
              '10. Contact Information',
              'If you have any questions about these Terms of Service, please contact us at support@showoff.life',
            ),

            const SizedBox(
              height: 32,
            ),

            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(
                16,
              ),
              decoration: BoxDecoration(
                color: const Color(
                  0xFFE9D5FF,
                ),
                borderRadius: BorderRadius.circular(
                  12,
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Need Help?',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: Colors.black,
                    ),
                  ),
                  const SizedBox(
                    height: 8,
                  ),
                  Text(
                    'If you have any questions about these terms, please contact our support team through the Help and Support section.',
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.grey[700],
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget
  _buildSection(
    String title,
    String content,
  ) {
    return Container(
      margin: const EdgeInsets.only(
        bottom: 24,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: Colors.black,
            ),
          ),
          const SizedBox(
            height: 8,
          ),
          Text(
            content,
            style: TextStyle(
              fontSize: 14,
              color: Colors.grey[700],
              height: 1.5,
            ),
          ),
        ],
      ),
    );
  }
}
