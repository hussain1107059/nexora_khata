import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/config/theme/app_spacing.dart';
import '../../../../core/widgets/app_text.dart';

class TermsPage extends ConsumerWidget {
  const TermsPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      appBar: AppBar(
        title: const AppText('শর্তাবলী', type: AppTextType.subtitle2),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: AppSpacing.screenPadding,
        child: const Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            AppText(
              'নেক্সোরা খাতা অ্যাপ ব্যবহার করার মাধ্যমে আপনি নিম্নলিখিত শর্তাবলী মেনে চলতে বাধ্য।',
              type: AppTextType.body2,
            ),
            AppSpacing.boxLG,
            AppText('সেবার শর্তাবলী', type: AppTextType.subtitle2),
            AppSpacing.boxSM,
            AppText(
              '• নেক্সোরা খাতা একটি ব্যক্তিগত হিসাব সংরক্ষণ অ্যাপ্লিকেশন যা আপনার আয়-ব্যয় ট্র্যাক করতে সাহায্য করে।\n'
              '• এই অ্যাপটি "যেমন আছে তেমন" ভিত্তিতে প্রদান করা হয়।\n'
              '• যেকোনো সময় পূর্ব ঘোষণা ছাড়াই সেবার শর্ত পরিবর্তনের অধিকার আমরা সংরক্ষণ করি।',
              type: AppTextType.body2,
            ),
            AppSpacing.boxLG,
            AppText('ব্যবহারকারীর দায়িত্ব', type: AppTextType.subtitle2),
            AppSpacing.boxSM,
            AppText(
              '• আপনি আপনার অ্যাকাউন্টের তথ্য এবং পাসওয়ার্ডের গোপনীয়তা বজায় রাখার জন্য দায়ী।\n'
              '• আপনি অ্যাপটির মাধ্যমে কোনো বেআইনি কার্যকলাপ করবেন না।\n'
              '• আপনি সঠিক এবং আপ-টু-ডেট তথ্য প্রদান করবেন।\n'
              '• অ্যাপের অপব্যবহার থেকে বিরত থাকা আপনার দায়িত্ব।',
              type: AppTextType.body2,
            ),
            AppSpacing.boxLG,
            AppText('অ্যাকাউন্ট নীতিমালা', type: AppTextType.subtitle2),
            AppSpacing.boxSM,
            AppText(
              '• অ্যাপটি ব্যবহারের জন্য আপনার বয়স ১৩ বছর বা তার বেশি হতে হবে।\n'
              '• একটি একাউন্টে একাধিক ডিভাইস থেকে লগইন করা যাবে না।\n'
              '• কোনো প্রকার দুর্ব্যবহার বা অপব্যবহার আপনার অ্যাকাউন্ট বাতিলের কারণ হতে পারে।',
              type: AppTextType.body2,
            ),
            AppSpacing.boxLG,
            AppText('দাবিত্যাগ', type: AppTextType.subtitle2),
            AppSpacing.boxSM,
            AppText(
              '• নেক্সোরা খাতা কোনো আর্থিক উপদেশ প্রদান করে না।\n'
              '• অ্যাপের তথ্যের যথার্থতা নিশ্চিত করতে আমরা সর্বোচ্চ চেষ্টা করি, তবে কোনো ভুল বা ক্ষতির জন্য আমরা দায়ী নই।\n'
              '• অ্যাপ ব্যবহারের ফলে কোনো আর্থিক ক্ষতি হলে আমরা দায়ী থাকবো না।',
              type: AppTextType.body2,
            ),
            AppSpacing.boxLG,
            AppText('সীমাবদ্ধতা', type: AppTextType.subtitle2),
            AppSpacing.boxSM,
            AppText(
              '• কোনো অবস্থাতেই নেক্সোরা খাতা বা BadhonByte আপনার কোনো প্রত্যক্ষ, পরোক্ষ, আকস্মিক বা ফলস্বরূপ ক্ষতির জন্য দায়ী থাকবে না।\n'
              '• আমাদের দায়িত্ব অ্যাপটির মূল্যের মধ্যে সীমাবদ্ধ।\n'
              '• স্থানীয় আইনের অধীনে যেসব অধিকার বাদ দেওয়া যায় না, সেগুলো এই শর্তাবলী দ্বারা প্রভাবিত হবে না।',
              type: AppTextType.body2,
            ),
            AppSpacing.boxLG,
            AppText('যোগাযোগ', type: AppTextType.subtitle2),
            AppSpacing.boxSM,
            AppText(
              'শর্তাবলী সম্পর্কে কোনো প্রশ্ন থাকলে আমাদের সাথে যোগাযোগ করুন: '
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
