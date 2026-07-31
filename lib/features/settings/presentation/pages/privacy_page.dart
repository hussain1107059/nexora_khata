import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/config/theme/app_spacing.dart';
import '../../../../core/widgets/app_text.dart';

class PrivacyPage extends ConsumerWidget {
  const PrivacyPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      appBar: AppBar(
        title: const AppText('গোপনীয়তা নীতি', type: AppTextType.subtitle2),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: AppSpacing.screenPadding,
        child: const Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            AppText(
              'আমরা আপনার গোপনীয়তাকে অত্যন্ত গুরুত্ব দেই। এই গোপনীয়তা নীতিটি ব্যাখ্যা করে যে নেক্সোরা খাতা কীভাবে আপনার তথ্য সংগ্রহ, ব্যবহার এবং সুরক্ষিত করে।',
              type: AppTextType.body2,
            ),
            AppSpacing.boxLG,
            AppText('আমরা কী তথ্য সংগ্রহ করি', type: AppTextType.subtitle2),
            AppSpacing.boxSM,
            AppText(
              '• আমরা আপনার ডিভাইসে স্থানীয়ভাবে আপনার হিসাব সংক্রান্ত তথ্য (যেমন আয়, ব্যয়, লেনদেন) সংরক্ষণ করি।\n'
              '• আমরা কোনো ব্যক্তিগত শনাক্তকারী তথ্য যেমন নাম, ঠিকানা, ফোন নম্বর সংগ্রহ করি না, '
              'যদি না আপনি স্বেচ্ছায় প্রদান করেন।\n'
              '• অ্যাপ ব্যবহার সংক্রান্ত কিছু মৌলিক তথ্য যেমন অ্যাপ সংস্করণ এবং ডিভাইসের ধরন আমরা সংগ্রহ করতে পারি।',
              type: AppTextType.body2,
            ),
            AppSpacing.boxLG,
            AppText('কীভাবে তথ্য ব্যবহার করি', type: AppTextType.subtitle2),
            AppSpacing.boxSM,
            AppText(
              '• আপনার তথ্য শুধুমাত্র অ্যাপের কার্যকারিতা নিশ্চিত করতে এবং আপনার হিসাব সংরক্ষণ ও পরিচালনা করতে ব্যবহৃত হয়।\n'
              '• আমরা কোনো তৃতীয় পক্ষের সাথে আপনার তথ্য শেয়ার করি না।\n'
              '• আপনার তথ্য সর্বদা আপনার ডিভাইসেই সংরক্ষিত থাকে এবং কখনো আমাদের সার্ভারে পাঠানো হয় না।',
              type: AppTextType.body2,
            ),
            AppSpacing.boxLG,
            AppText('তথ্যের নিরাপত্তা', type: AppTextType.subtitle2),
            AppSpacing.boxSM,
            AppText(
              '• আপনার ডেটা আপনার ডিভাইসে স্থানীয়ভাবে সংরক্ষিত থাকে।\n'
              '• আমরা আপনার ডেটা সুরক্ষিত রাখতে যথাযথ নিরাপত্তা ব্যবস্থা গ্রহণ করি।\n'
              '• কোনো তৃতীয় পক্ষ আপনার ডেটা অ্যাক্সেস করতে পারে না।',
              type: AppTextType.body2,
            ),
            AppSpacing.boxLG,
            AppText('আপনার অধিকার', type: AppTextType.subtitle2),
            AppSpacing.boxSM,
            AppText(
              '• আপনি যেকোনো সময় আপনার ডেটা ব্যাকআপ, এক্সপোর্ট বা ডিলিট করতে পারেন।\n'
              '• আপনি অ্যাপের সেটিংস থেকে সমস্ত ডেটা মুছে ফেলতে পারেন।\n'
              '• আপনার ডেটা সম্পূর্ণরূপে আপনার নিয়ন্ত্রণে থাকে।',
              type: AppTextType.body2,
            ),
            AppSpacing.boxLG,
            AppText('যোগাযোগ', type: AppTextType.subtitle2),
            AppSpacing.boxSM,
            AppText(
              'যদি আপনার এই গোপনীয়তা নীতি সম্পর্কে কোনো প্রশ্ন থাকে, তাহলে আমাদের সাথে যোগাযোগ করুন: '
              'badhonbyte@email.com',
              type: AppTextType.body2,
            ),
            AppSpacing.boxXXL,
          ],
        ),
      ),
    );
  }
}
