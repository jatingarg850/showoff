require('dotenv').config();
const mongoose = require('mongoose');
const TermsAndConditions = require('../models/TermsAndConditions');

const connectDatabase = async () => {
  try {
    await mongoose.connect(process.env.MONGODB_URI || 'mongodb://localhost:27017/showoff');
    console.log('✅ Connected to MongoDB');
  } catch (error) {
    console.error('❌ MongoDB connection error:', error);
    process.exit(1);
  }
};

const defaultTermsContent = `SHOWOFF.LIFE – TERMS & CONDITIONS
Last Updated: 23 December 2025

Welcome to ShowOff.life ("Platform", "ShowOff", "we", "us", "our").

The Platform is owned and operated by:
- ShowOff Ventures Private Limited, incorporated in India, and
- ShowOff Ventures Inc., incorporated in the State of Delaware, United States of America,
(together referred to as the "Company").

ShowOff.life is a digital talent-showcasing platform that allows individuals of all ages to display their skills, creativity, and performances.

By accessing or using ShowOff.life, you agree to be legally bound by these Terms & Conditions ("Terms").
If you do not agree, please do not use the Platform.

1. DEFINITIONS
- User: Any person accessing or using ShowOff.life
- Minor: Any individual below 18 years of age
- Guardian: Parent or legal guardian of a Minor
- User Content: Any video, image, audio, text, or other material uploaded
- Platform / Company: ShowOff.life and its owning entities

2. ELIGIBILITY & AGE POLICY
- ShowOff.life allows talent showcasing by users of all ages, including children and minors.
- Minors cannot create or operate accounts independently.
- Any account or content involving a Minor must be created, managed, and controlled by a Parent or Legal Guardian.
- The Guardian shall be treated as the legal user for all content involving a Minor.

3. CHILD CONTENT UPLOAD & GUARDIAN RESPONSIBILITY POLICY

3.1 Guardian-Managed Uploads (Mandatory)
By uploading content featuring a Minor, the Guardian confirms that:
- They are the lawful parent or legal guardian
- They have full authority and consent to upload such content
- They accept full legal responsibility for the content

3.2 Transfer of Responsibility
- All responsibility for content involving Minors rests solely with the Guardian.
- ShowOff.life bears no responsibility or liability for such content.

4. USER CONTENT – OWNERSHIP & LIABILITY
- Users retain ownership of their content.
- All User Content is uploaded entirely at the user's own risk.
- ShowOff.life acts solely as an online intermediary.
- Users are fully responsible for ensuring their content is lawful and non-infringing.

5. COPYRIGHT & INTELLECTUAL PROPERTY POLICY
- Users must not upload content that infringes any copyright, trademark, or intellectual property.
- Content may be uploaded only if the user owns the rights or has valid permission.
- By uploading content, the user declares that ShowOff.life is not responsible for any infringement.
- The Company may remove content without notice upon complaint or legal requirement.

6. PROHIBITED CONTENT
No user may upload content that is adult, obscene, abusive, illegal, exploitative, misleading, or infringing.
🚫 NO ADULT CONTENT IS PERMITTED ON SHOWOFF.LIFE

7. UPLOAD DISCLAIMER
By uploading content, you confirm that you are legally authorized to do so and accept full responsibility.
ShowOff.life shall not be liable for such content.

8. CONTENT MODERATION & PLATFORM RIGHTS
The Company may remove content or suspend accounts at its discretion without assuming liability.

9. KYC, AML & USER VERIFICATION
- KYC and AML verification is mandatory for withdrawals.
- The Company may delay, suspend, or cancel withdrawals for compliance or security reasons.

10. WITHDRAWAL ELIGIBILITY & HOLDING PERIOD
- Minimum coin requirement must be met.
- A mandatory 30-day onboarding period applies.
- Payments are processed in the next payout cycle after eligibility.

11. PAYMENT MODE – INITIAL SOFFT TOKEN ONLY
All initial payouts shall be made only in SOFFT Tokens due to liquidity and compliance reasons.

12. SOFFT PAY WALLET
All payments shall be credited only to the SOFFT Pay Wallet.

13. SOFFT TOKEN LOCK-IN
All SOFFT Tokens are subject to a 6-month lock-in period.

14. POST-LIQUIDITY CONVERSION
Once liquidity is sufficient, users may convert SOFFT Tokens to USDT or other supported assets via approved mechanisms.

15. INTERNATIONAL USERS
Users are responsible for compliance with local laws in their jurisdiction.

16. NO GUARANTEE OF TOKEN VALUE
SOFFT Tokens are not legal tender and may fluctuate in value.
The Company bears no liability for such fluctuations.

17. LIMITATION OF LIABILITY
Maximum liability, if any, shall not exceed INR 1,000 or the amount paid by the user, whichever is lower.

18. INDEMNITY
Users agree to indemnify the Company against all claims arising from their content or actions.

19. TERMINATION
The Company may terminate or suspend accounts without notice and without liability.

20. GOVERNING LAW & JURISDICTION
- These Terms shall be governed by the laws of India.
- Courts at Delhi, India shall have exclusive jurisdiction.

21. CONTACT DETAILS
📧 Email: support@showoff.life
🌐 Website: https://www.showoffventures.com

22. FINAL CLAUSE – CHANGE OF TERMS
These Terms & Conditions may be amended or updated at any time as per Company policy. Continued use of ShowOff.life constitutes acceptance of such changes.`;

const seedTermsAndConditions = async () => {
  try {
    // Check if T&C already exists
    const existingTerms = await TermsAndConditions.findOne({ version: 1 });
    
    if (existingTerms) {
      console.log('⚠️  Terms & Conditions version 1 already exists');
      console.log('   ID:', existingTerms._id);
      console.log('   Active:', existingTerms.isActive);
      console.log('   Last Updated:', existingTerms.lastUpdated);
      
      // Ask if user wants to update
      console.log('\n📝 To update, use the admin panel at: http://localhost:3000/admin/terms-and-conditions');
      return;
    }

    // Create new T&C
    const termsAndConditions = await TermsAndConditions.create({
      version: 1,
      title: 'SHOWOFF.LIFE – TERMS & CONDITIONS',
      content: defaultTermsContent,
      isActive: true,
      lastUpdated: new Date('2025-12-23'),
    });

    console.log('✅ Terms & Conditions seeded successfully!');
    console.log('   Version:', termsAndConditions.version);
    console.log('   Title:', termsAndConditions.title);
    console.log('   Active:', termsAndConditions.isActive);
    console.log('   ID:', termsAndConditions._id);
    console.log('   Created At:', termsAndConditions.createdAt);
    console.log('\n📝 Access admin panel at: http://localhost:3000/admin/terms-and-conditions');
    console.log('📱 T&C will appear in signup flow');
  } catch (error) {
    console.error('❌ Error seeding Terms & Conditions:', error);
    process.exit(1);
  }
};

const main = async () => {
  console.log('🌱 Seeding Terms & Conditions...\n');
  await connectDatabase();
  await seedTermsAndConditions();
  await mongoose.connection.close();
  console.log('\n✅ Seed completed and database connection closed');
};

main();
