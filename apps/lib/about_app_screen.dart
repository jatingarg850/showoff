import 'package:flutter/material.dart';

class AboutAppScreen
    extends
        StatelessWidget {
  const AboutAppScreen({
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
          'About App',
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
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            // App Logo and Name
            Container(
              width: 100,
              height: 100,
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [
                    Color(
                      0xFF8B5CF6,
                    ),
                    Color(
                      0xFF7C3AED,
                    ),
                  ],
                ),
                borderRadius: BorderRadius.circular(
                  20,
                ),
              ),
              child: const Center(
                child: Text(
                  'SO',
                  style: TextStyle(
                    fontSize: 36,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
              ),
            ),

            const SizedBox(
              height: 16,
            ),

            const Text(
              'ShowOff.life',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: Colors.black,
              ),
            ),

            const SizedBox(
              height: 8,
            ),

            const Text(
              'Version 1.0.0',
              style: TextStyle(
                fontSize: 16,
                color: Colors.grey,
              ),
            ),

            const SizedBox(
              height: 32,
            ),

            Container(
              padding: const EdgeInsets.all(
                20,
              ),
              decoration: BoxDecoration(
                color: const Color(
                  0xFFE9D5FF,
                ),
                borderRadius: BorderRadius.circular(
                  16,
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'About ShowOff.life',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w600,
                      color: Colors.black,
                    ),
                  ),
                  const SizedBox(
                    height: 12,
                  ),
                  Text(
                    'ShowOff.life is a revolutionary platform that combines social networking with rewarding experiences. Share your talents, connect with communities, and earn coins through our innovative referral system.',
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.grey[700],
                      height: 1.5,
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(
              height: 24,
            ),

            _buildInfoItem(
              Icons.star,
              'Features',
              'Community engagement, referral rewards, digital wallet, and content sharing',
            ),

            _buildInfoItem(
              Icons.security,
              'Security',
              'Your data is protected with industry-standard encryption and security measures',
            ),

            _buildInfoItem(
              Icons.support,
              'Support',
              '24/7 customer support to help you with any questions or issues',
            ),

            _buildInfoItem(
              Icons.update,
              'Updates',
              'Regular updates with new features and improvements to enhance your experience',
            ),

            const SizedBox(
              height: 32,
            ),

            // App Information Card
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(
                20,
              ),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    const Color(
                      0xFF8B5CF6,
                    ).withValues(
                      alpha: 0.05,
                    ),
                    const Color(
                      0xFF7C3AED,
                    ).withValues(
                      alpha: 0.05,
                    ),
                  ],
                ),
                borderRadius: BorderRadius.circular(
                  16,
                ),
                border: Border.all(
                  color:
                      const Color(
                        0xFF8B5CF6,
                      ).withValues(
                        alpha: 0.2,
                      ),
                  width: 1.5,
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(
                          8,
                        ),
                        decoration: BoxDecoration(
                          color: const Color(
                            0xFF8B5CF6,
                          ),
                          borderRadius: BorderRadius.circular(
                            8,
                          ),
                        ),
                        child: const Icon(
                          Icons.info_outline,
                          color: Colors.white,
                          size: 20,
                        ),
                      ),
                      const SizedBox(
                        width: 12,
                      ),
                      const Text(
                        'App Information',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: Color(
                            0xFF8B5CF6,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(
                    height: 20,
                  ),
                  _buildDetailRow(
                    'Version',
                    '1.0.0',
                  ),
                  const Divider(
                    height: 24,
                  ),
                  _buildDetailRow(
                    'Build',
                    '100',
                  ),
                  const Divider(
                    height: 24,
                  ),
                  _buildDetailRow(
                    'Release Date',
                    'October 2025',
                  ),
                  const Divider(
                    height: 24,
                  ),
                  _buildDetailRow(
                    'Platform',
                    'iOS & Android',
                  ),
                  const Divider(
                    height: 24,
                  ),
                  _buildDetailRow(
                    'Developer',
                    'ShowOff Team',
                  ),
                ],
              ),
            ),

            const SizedBox(
              height: 32,
            ),

            // Footer Section
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(
                24,
              ),
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [
                    Color(
                      0xFF8B5CF6,
                    ),
                    Color(
                      0xFF7C3AED,
                    ),
                  ],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(
                  16,
                ),
                boxShadow: [
                  BoxShadow(
                    color:
                        const Color(
                          0xFF8B5CF6,
                        ).withValues(
                          alpha: 0.3,
                        ),
                    blurRadius: 12,
                    offset: const Offset(
                      0,
                      4,
                    ),
                  ),
                ],
              ),
              child: Column(
                children: [
                  const Icon(
                    Icons.favorite,
                    color: Colors.white,
                    size: 32,
                  ),
                  const SizedBox(
                    height: 12,
                  ),
                  const Text(
                    'Made with ❤️',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                  const SizedBox(
                    height: 8,
                  ),
                  const Text(
                    'ShowOff Team ',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: Colors.white,
                    ),
                  ),
                  const SizedBox(
                    height: 4,
                  ),
                  Text(
                    '',
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.white.withValues(
                        alpha: 0.9,
                      ),
                    ),
                  ),
                  const SizedBox(
                    height: 16,
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 8,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.white.withValues(
                        alpha: 0.2,
                      ),
                      borderRadius: BorderRadius.circular(
                        20,
                      ),
                    ),
                    child: const Text(
                      '© 2025 ShowOff.life',
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.white,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(
              height: 20,
            ),
          ],
        ),
      ),
    );
  }

  Widget
  _buildInfoItem(
    IconData icon,
    String title,
    String description,
  ) {
    return Container(
      margin: const EdgeInsets.only(
        bottom: 16,
      ),
      padding: const EdgeInsets.all(
        16,
      ),
      decoration: BoxDecoration(
        color: Colors.grey[50],
        borderRadius: BorderRadius.circular(
          12,
        ),
        border: Border.all(
          color: Colors.grey[200]!,
        ),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(
              8,
            ),
            decoration: BoxDecoration(
              color:
                  const Color(
                    0xFF8B5CF6,
                  ).withValues(
                    alpha: 0.1,
                  ),
              borderRadius: BorderRadius.circular(
                8,
              ),
            ),
            child: Icon(
              icon,
              color: const Color(
                0xFF8B5CF6,
              ),
              size: 20,
            ),
          ),
          const SizedBox(
            width: 16,
          ),
          Expanded(
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
                  height: 4,
                ),
                Text(
                  description,
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.grey[600],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget
  _buildDetailRow(
    String label,
    String value,
  ) {
    return Container(
      margin: const EdgeInsets.only(
        bottom: 12,
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: TextStyle(
              fontSize: 14,
              color: Colors.grey[600],
            ),
          ),
          Text(
            value,
            style: const TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: Colors.black,
            ),
          ),
        ],
      ),
    );
  }
}
