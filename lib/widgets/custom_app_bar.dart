import 'package:flutter/material.dart';
import 'package:seat_booking_app/utils/app_colors.dart';

class CustomAppBar extends StatelessWidget implements PreferredSizeWidget {
  final String title;

  const CustomAppBar({
    super.key,
    required this.title,
  });

  @override
  Widget build(BuildContext context) {
    return AppBar(
      leadingWidth: 100,
      automaticallyImplyLeading: false,
      flexibleSpace: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [
              AppColors.appBarGradientStart,
              AppColors.appBarGradientEnd,
            ],
            begin: Alignment.bottomCenter,
            end: Alignment.topCenter,
          ),
        ),
      ),
      elevation: 0,
      scrolledUnderElevation: 0,
      leading: Builder(
        builder: (context) => GestureDetector(
          onTap: () => Scaffold.of(context).openDrawer(),
          child: Container(
            width: 100,
            height: 40,
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [AppColors.appBarGradientStart, AppColors.appBarGradientEnd],
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
              ),
              border: const Border(
                top: BorderSide(color: Colors.white, width: 1),
                right: BorderSide(color: Colors.white, width: 1),
                bottom: BorderSide(color: Colors.white, width: 1),
              ),
              borderRadius: const BorderRadius.only(
                topRight: Radius.circular(12.0),
                bottomRight: Radius.circular(12.0),
              ),
            ),
            child: const Icon(
              Icons.arrow_forward,
              color: Colors.white,
              size: 35,
            ),
          ),
        ),
      ),
      title: const Text(''),
      actions: [
        Padding(
          padding: const EdgeInsets.only(right: 16.0, top: 6, bottom: 6),
          child: Container(
            width: 120,
            decoration: BoxDecoration(
              color: AppColors.accent,
              borderRadius: BorderRadius.circular(12),
            ),
          ),
        ),
      ],
      bottom: PreferredSize(
        preferredSize: const Size.fromHeight(80.0),
        child: Padding(
          padding: const EdgeInsets.fromLTRB(0, 0, 0, 12.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.end,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              const Divider(color: Colors.white54, thickness: 1.5),
              const SizedBox(height: 12.0),
              Padding(
                padding: const EdgeInsets.only(left: 16.0),
                child: Text(
                  title,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 32,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
      toolbarHeight: 65,
    );
  }

  @override
  Size get preferredSize => const Size.fromHeight(65 + 80);
}
