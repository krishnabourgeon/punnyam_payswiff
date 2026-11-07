import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class SliverPaginationLoader extends StatelessWidget {
  final bool async;
  const SliverPaginationLoader({Key? key, required this.async})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return SliverToBoxAdapter(
      child: AnimatedSwitcher(
        duration: const Duration(microseconds: 300),
        child: async
            ? SizedBox(
                height: 70.h,
                child: const CircularProgressIndicator(),
              )
            : const SizedBox(),
      ),
    );
  }
}
